from django.contrib import admin
from django.utils.translation import gettext_lazy as _

from productions.health_models import AdministeredTreatment, HealthCondition, HealthIssue, HealthRecord, MedicationType, Treatment
from .models import (
    AcquisitionRecord, Animal, AnimalType, AnimalBreed, WeightCategory, 
    BirthRecord, AnimalInventory, DiedRecord, AnimalGroup
)

class FarmFilterMixin:
    def get_queryset(self, request):
        qs = super().get_queryset(request)
        if request.user.is_superuser:
            return qs
        if hasattr(request, 'current_farm_id') and request.current_farm_id:
            return qs.filter(farm_id=request.current_farm_id)
        return qs.filter(farm__farmuser__user=request.user)

    def save_model(self, request, obj, form, change):
        if not change and (not hasattr(obj, 'farm_id') or not obj.farm_id):
            if hasattr(request, 'current_farm_id') and request.current_farm_id:
                obj.farm_id = request.current_farm_id
        super().save_model(request, obj, form, change)

@admin.register(AnimalType)
class AnimalTypeAdmin(admin.ModelAdmin, FarmFilterMixin):
    list_display = ('id', 'name', 'description', 'created_by')
    search_fields = ('name', 'description')
    list_filter = ('created_by',)
    readonly_fields = ('created_by',)

    def save_model(self, request, obj, form, change):
        if not change:
            obj.created_by = request.user
        super().save_model(request, obj, form, change)

@admin.register(AnimalBreed)
class AnimalBreedAdmin(admin.ModelAdmin, FarmFilterMixin):
    list_display = ('id', 'name', 'animal_type', 'description', 'created_by')
    search_fields = ('name', 'animal_type__name', 'description')
    list_filter = ('animal_type', 'created_by')
    autocomplete_fields = ('animal_type',)
    readonly_fields = ('created_by', 'thumbnail')

    def save_model(self, request, obj, form, change):
        if not change:
            obj.created_by = request.user
        super().save_model(request, obj, form, change)

@admin.register(WeightCategory)
class WeightCategoryAdmin(admin.ModelAdmin, FarmFilterMixin):
    list_display = ('min_weight', 'max_weight', 'created_by')
    search_fields = ('min_weight', 'max_weight')
    list_filter = ('created_by',)
    readonly_fields = ('created_by',)

    def save_model(self, request, obj, form, change):
        if not change:
            obj.created_by = request.user
        super().save_model(request, obj, form, change)

@admin.register(BirthRecord)
class BirthRecordAdmin(admin.ModelAdmin, FarmFilterMixin):
    list_display = ('id', 'weight', 'number_of_male', 'number_of_female', 'number_of_died', 'date_of_birth', 'created_by', 'farm')
    search_fields = ('notes',)
    list_filter = ('date_of_birth',)
    readonly_fields = ('created_by',)
    autocomplete_fields = ('animal', 'animal_group')

    def save_model(self, request, obj, form, change):
        if not change:
            obj.created_by = request.user
        super().save_model(request, obj, form, change)

@admin.register(AnimalInventory)
class AnimalInventoryAdmin(admin.ModelAdmin, FarmFilterMixin):
    list_display = ('id', 'animal_type', 'breed', 'quantity', 'farm')
    search_fields = ('animal_type__name', 'breed__name')
    list_filter = ('animal_type', 'breed', 'farm')
    readonly_fields = ('quantity',)
    autocomplete_fields = ('animal_type', 'breed')

@admin.register(AcquisitionRecord)
class AcquisitionRecordAdmin(admin.ModelAdmin, FarmFilterMixin):
    list_display = ('id', 'quantity', 'gender', 'unit_preis', 'date_of_acquisition', 'farm', 'created_by')
    search_fields = ('vendor', 'receipt_number', 'notes')
    list_filter = ('gender', 'date_of_acquisition', 'farm')
    readonly_fields = ('created_by',)
    autocomplete_fields = ('animal', 'animal_group')

    def save_model(self, request, obj, form, change):
        if not change:
            obj.created_by = request.user
        super().save_model(request, obj, form, change)

@admin.register(DiedRecord)
class DiedRecordAdmin(admin.ModelAdmin, FarmFilterMixin):
    list_display = ('id', 'weight', 'quantity', 'date_of_death', 'status', 'farm', 'created_by')
    search_fields = ('cause', 'notes')
    list_filter = ('date_of_death', 'status', 'farm')
    readonly_fields = ('created_by',)
    autocomplete_fields = ('animal', 'animal_group')

    def save_model(self, request, obj, form, change):
        if not change:
            obj.created_by = request.user
        super().save_model(request, obj, form, change)

@admin.register(HealthIssue)
class HealthIssueAdmin(admin.ModelAdmin):
    list_display = ('name', 'is_contagious')
    search_fields = ('name', 'description', 'symptoms', 'treatments')
    list_filter = ('is_contagious',)

@admin.register(MedicationType)
class MedicationTypeAdmin(admin.ModelAdmin):
    list_display = ('name', 'withdrawal_period_days', 'supplier')
    search_fields = ('name', 'description', 'dosage_instructions')
    list_filter = ('withdrawal_period_days', 'supplier')
    autocomplete_fields = ('supplier',)

@admin.register(HealthRecord)
class HealthRecordAdmin(admin.ModelAdmin, FarmFilterMixin):
    list_display = ('animal', 'animal_group', 'health_issue', 'start_date', 'end_date', 'is_resolved')
    search_fields = ('symptoms', 'diagnosis', 'notes')
    list_filter = ('is_resolved', 'start_date', 'end_date', 'health_issue')
    autocomplete_fields = ('animal', 'animal_group', 'health_issue')
    readonly_fields = ('created_by',)

    def save_model(self, request, obj, form, change):
        if not change:
            obj.created_by = request.user
        super().save_model(request, obj, form, change)

@admin.register(Treatment)
class TreatmentAdmin(admin.ModelAdmin, FarmFilterMixin):
    list_display = ('health_record', 'medication', 'date_administered', 'dosage', 'administered_by')
    search_fields = ('notes',)
    list_filter = ('date_administered', 'medication', 'administered_by')
    autocomplete_fields = ('health_record', 'medication', 'administered_by')
    readonly_fields = ()

@admin.register(AdministeredTreatment)
class AdministeredTreatmentAdmin(admin.ModelAdmin, FarmFilterMixin):
    list_display = ('health_record', 'treatment', 'date_administered', 'administered_by')
    search_fields = ('notes',)
    list_filter = ('date_administered', 'administered_by')
    autocomplete_fields = ('health_record', 'treatment', 'administered_by')

@admin.register(HealthCondition)
class HealthConditionAdmin(admin.ModelAdmin):
    list_display = ('name', 'is_contagious', 'created_by')
    search_fields = ('name', 'description', 'symptoms', 'treatments', 'prevention_measures')
    list_filter = ('is_contagious', 'created_by')
    readonly_fields = ('created_by',)

    def save_model(self, request, obj, form, change):
        if not change:
            obj.created_by = request.user
        super().save_model(request, obj, form, change)

@admin.register(AnimalGroup)
class AnimalGroupAdmin(admin.ModelAdmin, FarmFilterMixin):
    list_display = ('id', 'animal_type', 'breed', 'quantity', 'location', 'farm', 'created_by')
    search_fields = ('animal_type__name', 'breed__name', 'location')
    list_filter = ('animal_type', 'breed', 'farm')
    autocomplete_fields = ('animal_type', 'breed')
    readonly_fields = ('created_by', 'created_at')

    def save_model(self, request, obj, form, change):
        if not change:
            obj.created_by = request.user
        super().save_model(request, obj, form, change)

@admin.register(Animal)
class AnimalAdmin(admin.ModelAdmin, FarmFilterMixin):
    autocomplete_fields = ('animal_type',)
    list_display = ('id', 'tracking_id', 'animal_type', 'breed', 'gender', 'status', 'current_weight', 'last_weigh_date', 'farm')
    search_fields = ('tracking_id', 'animal_type__name', 'breed__name', 'notes')
    list_filter = ('animal_type', 'breed', 'gender', 'status', 'date_of_birth', 'date_of_acquisition', 'farm')
    autocomplete_fields = ('animal_type', 'breed', 'birth_record', 'acquisition_record', 'death_record')
    readonly_fields = ('qr_code', 'created_by', 'created_at', 'updated_at')

    fieldsets = (
        (None, {'fields': ('tracking_id', 'animal_type', 'breed', 'gender', 'status', 'farm')}),
        ('Dates', {'fields': ('date_of_birth', 'date_of_acquisition')}),
        ('Origin', {'fields': ('birth_record', 'acquisition_record'), 'classes': ('collapse',)}),
        ('Weight Information', {'fields': ('initial_weight', 'current_weight', 'last_weigh_date')}),
        ('Death Information', {'fields': ('death_record',), 'classes': ('collapse',)}),
        ('QR Code', {'fields': ('qr_code',), 'classes': ('collapse',)}),
        ('Additional Information', {'fields': ('notes',), 'classes': ('collapse',)}),
        ('Metadata', {'fields': ('created_by', 'created_at', 'updated_at'), 'classes': ('collapse',)}),
    )
    
    def save_model(self, request, obj, form, change):
        if not change:
            obj.created_by = request.user
        super().save_model(request, obj, form, change)
