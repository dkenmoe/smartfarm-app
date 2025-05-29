from django_filters import rest_framework as filters

from account.models import Customer
from utilities.filters import BaseFarmFilter
from django.db.models import Q


class CustomerFilter(BaseFarmFilter):
    """Filter for Customer model"""
    
    # Text search
    search = filters.CharFilter(method='filter_search')
    is_active = filters.BooleanFilter()
    
    def filter_search(self, queryset, name, value):
        if value:
            return queryset.filter(
                Q(name__icontains=value) | 
                Q(contact_person__icontains=value) |
                Q(phone__icontains=value) |
                Q(email__icontains=value) |
                Q(address__icontains=value)
            )
        return queryset
    
    class Meta:
        model = Customer
        fields = ['name', 'is_active', 'search', 'farm']