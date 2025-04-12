from django.contrib import admin
from .models import AnimalType, AnimalBreed, WeightCategory, AnimalPrice, AnimalGroup, BirthRecord, AnimalInventory, DiedRecord

@admin.register(AnimalType)
class AnimalTypeAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'created_by')  # Show these fields in admin panel
    search_fields = ('name',)  # Allow searching by name
    list_filter = ('created_by',)  # Allow filtering by user

@admin.register(AnimalBreed)
class AnimalBreedAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'animal_type', 'created_by')
    search_fields = ('name','animal_type')
    list_filter = ('created_by',)

@admin.register(WeightCategory)   
class WeightCategoryAdmin(admin.ModelAdmin):
    list_display = ('min_weight', 'max_weight', 'created_by')
    search_fields = ('min_weight', 'max_weight' )
    list_filter = ('created_by',)
    
@admin.register(AnimalPrice)   
class AnimalPriceAdmin(admin.ModelAdmin):
    list_display = ('id', 'animal_type', 'breed', 'gender', 'weight_category', 'price', 'created_by')
    search_fields = ('name',)
    list_filter = ('created_by', )
    
@admin.register(AnimalGroup)   
class AnimalGroupAdmin(admin.ModelAdmin):
    list_display = ('id', 'animal_type', 'breed', 'gender', 'quantity', 'birth_date', 'weight', 'weight_category', 'created_by')
    search_fields = ('animal_type', 'breed', 'gender','weight_category',)
    list_filter = ('animal_type', 'breed', 'gender','weight_category',)
    
@admin.register(BirthRecord)   
class BirthRecordAdmin(admin.ModelAdmin):
    list_display = ('id', 'animal_type', 'breed','weight', 'number_of_male', 'number_of_female', 'number_of_died', 'date_of_birth', 'created_by')
    search_fields = ('animal_type', 'breed', 'weight', 'number_of_male', 'number_of_female', 'number_of_died', 'date_of_birth', )
    list_filter = ('animal_type', 'breed', 'weight', 'number_of_male', 'number_of_female', 'number_of_died', 'date_of_birth', )

@admin.register(AnimalInventory)   
class AnimalInventoryAdmin(admin.ModelAdmin):
    list_display = ('id', 'animal_type', 'breed', 'quantity')
    search_fields = ('animal_type', 'breed', 'quantity',)
    list_filter = ('animal_type', 'breed', 'quantity', )

@admin.register(DiedRecord)   
class DiedRecordAdmin(admin.ModelAdmin):
    list_display = ('id', 'animal_type', 'breed', 'weight', 'quantity', 'date_of_death', 'created_by')
    search_fields = ('animal_type', 'breed', 'weight', 'quantity',)
    list_filter = ('animal_type', 'breed', 'weight', 'quantity', )