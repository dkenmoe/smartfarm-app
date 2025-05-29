from django.contrib import admin

from finance.sales_models import Sale, SaleItem
from .models import Expense, ExpenseCategory, PaymentMethod

@admin.register(ExpenseCategory)
class ExpenseCategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'description')
    search_fields = ('name', 'description')


@admin.register(PaymentMethod)
class PaymentMethodAdmin(admin.ModelAdmin):
    list_display = ('name', 'description')
    search_fields = ('name',)


@admin.register(Expense)
class ExpenseAdmin(admin.ModelAdmin):
    list_display = ('category', 'amount', 'date', 'farm', 'status', 'created_by')
    search_fields = ('description', 'invoice_number')
    list_filter = ('category', 'status', 'payment_method', 'farm')
    autocomplete_fields = ('category', 'farm', 'animal', 'animal_group', 'animal_type', 'animal_breed', 'supplier', 'payment_method')
    readonly_fields = ('created_at', 'updated_at')
    
@admin.register(SaleItem)
class SaleItemAdmin(admin.ModelAdmin):
    list_display = ('id', 'sale', 'animal', 'animal_group', 'animal_type', 'quantity', 'unit_price', 'subtotal')
    autocomplete_fields = ('animal', 'animal_group', 'animal_type', 'sale')
    search_fields = ('sale__invoice_number', 'animal__tracking_id')
    readonly_fields = ('subtotal',)

@admin.register(Sale)
class SaleAdmin(admin.ModelAdmin):
    list_display = ('invoice_number', 'customer', 'farm', 'total_amount', 'amount_paid', 'balance_due', 'sale_date')
    search_fields = ('invoice_number', 'customer__name')
    list_filter = ('sale_date', 'payment_method', 'farm')
    autocomplete_fields = ('customer', 'payment_method', 'farm')
    readonly_fields = ('created_by', 'created_at')
