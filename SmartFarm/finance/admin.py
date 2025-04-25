from django.contrib import admin
from .models import Expense, ExpenseCategory, Supplier, PaymentMethod

@admin.register(ExpenseCategory)
class ExpenseCategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'description')
    search_fields = ('name',)  # <-- Ajouté pour support autocomplete

@admin.register(PaymentMethod)
class PaymentMethodAdmin(admin.ModelAdmin):
    list_display = ('name', 'description')
    search_fields = ('name',)  # <-- Ajouté pour support autocomplete

@admin.register(Supplier)
class SupplierAdmin(admin.ModelAdmin):
    list_display = ('name', 'contact_person', 'email', 'phone', 'is_active')
    search_fields = ('name', 'contact_person')

@admin.register(Expense)
class ExpenseAdmin(admin.ModelAdmin):
    list_display = ('category', 'amount', 'date', 'status', 'description')
    list_filter = ('category', 'date', 'status')
    search_fields = ('description', 'invoice_number')
    autocomplete_fields = ('category', 'payment_method', 'supplier')