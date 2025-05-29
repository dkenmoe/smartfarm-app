from django_filters import rest_framework as filters
from django_filters.widgets import RangeWidget
from django.db.models import Q, F

from finance.models import Expense, ExpenseCategory, Supplier, PaymentMethod
from productions.models import AnimalType, AnimalBreed
from finance.sales_models import Customer, Sale, SaleItem
from utilities.filters import BaseFarmFilter, BasePeriodFilter

class ExpenseFilter(BaseFarmFilter, BasePeriodFilter):
    """Filter for Expense with period, category, animal type, breed, supplier, payment method"""
    
    # Period filters
    period = filters.ChoiceFilter(
        method='filter_expense_period',
        label='Period',
        choices=[
            ('week', 'This Week'),
            ('month', 'This Month'),
            ('year', 'This Year'),
            ('last_week', 'Last Week'),
            ('last_month', 'Last Month'),
            ('last_year', 'Last Year'),
        ]
    )
    
    # Date range filter
    date_range = filters.DateFromToRangeFilter(
        field_name='date',
        widget=RangeWidget(attrs={'type': 'date'})
    )
    
    # Category, animal type, breed, supplier, payment method filters
    category = filters.ModelChoiceFilter(queryset=ExpenseCategory.objects.all())
    animal_type = filters.ModelChoiceFilter(queryset=AnimalType.objects.all())
    animal_breed = filters.ModelChoiceFilter(queryset=AnimalBreed.objects.all())
    supplier = filters.ModelChoiceFilter(queryset=Supplier.objects.all())
    payment_method = filters.ModelChoiceFilter(queryset=PaymentMethod.objects.all())
    
    # Additional filters
    amount_min = filters.NumberFilter(field_name='amount', lookup_expr='gte')
    amount_max = filters.NumberFilter(field_name='amount', lookup_expr='lte')
    status = filters.ChoiceFilter(choices=[
        ('pending', 'En attente'),
        ('completed', 'Complétée'),
        ('cancelled', 'Annulée')
    ])
    
    # Text search
    search = filters.CharFilter(method='filter_search')
    
    def filter_search(self, queryset, name, value):
        if value:
            return queryset.filter(
                Q(description__icontains=value) | 
                Q(invoice_number__icontains=value)
            )
        return queryset
    
    def filter_expense_period(self, queryset, name, value):
        return self.filter_period(queryset, name, value, 'date')
    
    class Meta:
        model = Expense
        fields = [
            'category', 'animal_type', 'animal_breed', 'supplier', 'payment_method', 
            'date', 'date_range', 'period', 'amount_min', 'amount_max', 'status',
            'is_recurrent', 'search', 'farm'
        ]
        
class SaleFilter(BaseFarmFilter, BasePeriodFilter):
    """Filter for Sale model with period, customer, payment method"""
    
    # Period filters
    period = filters.ChoiceFilter(
        method='filter_sale_period',
        label='Period',
        choices=[
            ('week', 'This Week'),
            ('month', 'This Month'),
            ('year', 'This Year'),
            ('last_week', 'Last Week'),
            ('last_month', 'Last Month'),
            ('last_year', 'Last Year'),
        ]
    )
    
    # Date range filter
    date_range = filters.DateFromToRangeFilter(
        field_name='date',
        widget=RangeWidget(attrs={'type': 'date'})
    )
    
    # Customer and payment method filters
    customer = filters.ModelChoiceFilter(queryset=Customer.objects.all())
    payment_method = filters.ModelChoiceFilter(queryset=PaymentMethod.objects.all())
    
    # Additional filters
    invoice_number = filters.CharFilter(lookup_expr='icontains')
    status = filters.ChoiceFilter(choices=[
        ('pending', 'En attente'),
        ('completed', 'Complété'),
        ('cancelled', 'Annulé')
    ])
    total_amount_min = filters.NumberFilter(field_name='total_amount', lookup_expr='gte')
    total_amount_max = filters.NumberFilter(field_name='total_amount', lookup_expr='lte')
    paid_amount_min = filters.NumberFilter(field_name='paid_amount', lookup_expr='gte')
    paid_amount_max = filters.NumberFilter(field_name='paid_amount', lookup_expr='lte')
    is_fully_paid = filters.BooleanFilter(method='filter_fully_paid')
    
    # Text search
    search = filters.CharFilter(method='filter_search')
    
    def filter_search(self, queryset, name, value):
        if value:
            return queryset.filter(
                Q(invoice_number__icontains=value) | 
                Q(customer__name__icontains=value) |
                Q(notes__icontains=value)
            )
        return queryset
    
    def filter_fully_paid(self, queryset, name, value):
        # If value is True, filter for fully paid sales
        if value:
            return queryset.filter(paid_amount__gte=F('total_amount'))
        # If value is False, filter for not fully paid sales
        else:
            return queryset.filter(paid_amount__lt=F('total_amount'))
    
    def filter_sale_period(self, queryset, name, value):
        return self.filter_period(queryset, name, value, 'date')
    
    class Meta:
        model = Sale
        fields = [
            'customer', 'payment_method', 'status',
            'date', 'date_range', 'period',
            'invoice_number', 'total_amount_min', 'total_amount_max',
            'paid_amount_min', 'paid_amount_max', 'is_fully_paid',
            'search', 'farm'
        ]
        
class SaleItemFilter(filters.FilterSet):
    """Filter for SaleItem model"""
    
    # Sale filter (already includes farm filtering through Sale)
    sale = filters.NumberFilter()
    
    # Animal, animal type and breed filters
    animal = filters.NumberFilter()
    animal_type = filters.ModelChoiceFilter(queryset=AnimalType.objects.all())
    breed = filters.ModelChoiceFilter(queryset=AnimalBreed.objects.all())
    
    # Additional filters
    quantity_min = filters.NumberFilter(field_name='quantity', lookup_expr='gte')
    quantity_max = filters.NumberFilter(field_name='quantity', lookup_expr='lte')
    unit_price_min = filters.NumberFilter(field_name='unit_price', lookup_expr='gte')
    unit_price_max = filters.NumberFilter(field_name='unit_price', lookup_expr='lte')
    weight_min = filters.NumberFilter(field_name='weight_total', lookup_expr='gte')
    weight_max = filters.NumberFilter(field_name='weight_total', lookup_expr='lte')
    
    class Meta:
        model = SaleItem
        fields = [
            'sale', 'animal', 'animal_type', 'breed',
            'quantity_min', 'quantity_max', 
            'unit_price_min', 'unit_price_max',
            'weight_min', 'weight_max'
        ]
    
    def filter_queryset(self, queryset):
        # Apply parent filter
        queryset = super().filter_queryset(queryset)
        
        # Get farms accessible to user for farm isolation
        user = getattr(self.request, 'user', None)
        if user and user.is_authenticated:
            # Get user's current farm
            current_farm = getattr(self.request, 'current_farm', None)
            if current_farm:
                queryset = queryset.filter(sale__farm=current_farm)
            # Or filter by all farms the user has access to
            elif hasattr(user, 'accessible_farms'):
                queryset = queryset.filter(sale__farm__in=user.accessible_farms.all())
        
        return queryset