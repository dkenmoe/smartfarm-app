# accounts/admin.py
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, Role, Country, City, Address

class AddressInline(admin.StackedInline):
    model = Address
    extra = 0

class CustomUserAdmin(UserAdmin):
    # Add our custom fields to the fieldsets
    fieldsets = UserAdmin.fieldsets + (
        ('Profile Information', {
            'fields': ('profile_picture', 'phone_number', 'address'),
        }),
        ('Roles', {
            'fields': ('roles',),
        }),
    )
    
    # Add our custom fields to the add_fieldsets for creating users
    add_fieldsets = UserAdmin.add_fieldsets + (
        ('Profile Information', {
            'fields': ('profile_picture', 'phone_number', 'address'),
        }),
        ('Roles', {
            'fields': ('roles',),
        }),
    )
    
    list_display = UserAdmin.list_display + ('phone_number', 'get_roles')
    search_fields = UserAdmin.search_fields + ('phone_number',)
    
    def get_roles(self, obj):
        return ", ".join([role.name for role in obj.roles.all()])
    get_roles.short_description = 'Roles'

class RoleAdmin(admin.ModelAdmin):
    filter_horizontal = ('permissions',)
    list_display = ('name', 'description')
    search_fields = ('name', 'description')

class CountryAdmin(admin.ModelAdmin):
    list_display = ('name', 'code')
    search_fields = ('name', 'code')

class CityAdmin(admin.ModelAdmin):
    list_display = ('name', 'country')
    list_filter = ('country',)
    search_fields = ('name', 'country__name')

class AddressAdmin(admin.ModelAdmin):
    list_display = ('street', 'city', 'country', 'postal_code')
    list_filter = ('city', 'country')
    search_fields = ('street', 'city__name', 'country__name', 'postal_code')

# Register models
admin.site.register(CustomUser, CustomUserAdmin)
admin.site.register(Role, RoleAdmin)
admin.site.register(Country, CountryAdmin)
admin.site.register(City, CityAdmin)
admin.site.register(Address, AddressAdmin)