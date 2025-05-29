from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from account.models import CustomUser, Customer, Farm, FarmUser, Role, Supplier

class CustomUserAdmin(UserAdmin):
    fieldsets = UserAdmin.fieldsets + (
        ('Profile Information', {
            'fields': ('profile_picture', 'phone_number', 'street', 'street2', 'city', 'postal_code', 'country_name', 'country_code'),
        }),
        ('Roles', {
            'fields': ('roles',),
        }),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': (
                'username', 'password1', 'password2', 'email', 'profile_picture', 'phone_number',
                'street', 'street2', 'city', 'postal_code', 'country_name', 'country_code',
                'roles', 'groups',
            ),
        }),
    )
    list_display = UserAdmin.list_display + ('phone_number', 'get_roles')
    search_fields = UserAdmin.search_fields + ('phone_number',)

    def get_roles(self, obj):
        return ", ".join([role.name for role in obj.roles.all()])
    get_roles.short_description = 'Roles'

@admin.register(Farm)
class FarmAdmin(admin.ModelAdmin):
    list_display = ('name', 'owner', 'size_hectares', 'is_active', 'created_at')
    list_filter = ('is_active', 'created_at')
    search_fields = ('name', 'owner__username')
    readonly_fields = ('created_at', 'updated_at')

    def save_model(self, request, obj, form, change):
        if not change and not obj.owner:
            obj.owner = request.user
        super().save_model(request, obj, form, change)

@admin.register(Supplier)
class SupplierAdmin(admin.ModelAdmin):
    list_display = ('name', 'contact_person', 'email', 'phone', 'is_active')
    search_fields = ('name', 'contact_person')
    filter_horizontal = ('farms',)

@admin.register(Customer)
class CustomerAdmin(admin.ModelAdmin):
    list_display = ('name', 'phone', 'email', 'farm', 'created_by', 'created_at')
    search_fields = ('name', 'phone', 'email')
    list_filter = ('farm', 'created_at')
    autocomplete_fields = ('farm', 'created_by')
    readonly_fields = ('created_at',)

    def save_model(self, request, obj, form, change):
        if not change and not obj.created_by:
            obj.created_by = request.user
        super().save_model(request, obj, form, change)

@admin.register(FarmUser)
class FarmUserAdmin(admin.ModelAdmin):
    list_display = ('user', 'farm', 'date_joined')
    search_fields = ('user__username', 'user__email', 'farm__name')
    readonly_fields = ('date_joined',)

@admin.register(Role)
class RoleAdmin(admin.ModelAdmin):
    filter_horizontal = ('permissions',)
    list_display = ('name', 'description')
    search_fields = ('name', 'description')

admin.site.register(CustomUser, CustomUserAdmin)
