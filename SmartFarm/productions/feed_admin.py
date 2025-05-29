from django.contrib import admin
from productions.feed_models import FeedType, FeedInventory, FeedingRecord

@admin.register(FeedType)
class FeedTypeAdmin(admin.ModelAdmin):
    list_display = ('name', 'supplier', 'cost_per_kg')
    search_fields = ('name',)
    list_filter = ('suitable_for', 'supplier')
    filter_horizontal = ('suitable_for',)

@admin.register(FeedInventory)
class FeedInventoryAdmin(admin.ModelAdmin):
    list_display = ('feed_type', 'quantity_kg', 'batch_number', 'purchase_date', 'expiry_date', 'is_expired', 'purchase_price')
    list_filter = ('feed_type', 'purchase_date', 'expiry_date')
    search_fields = ('batch_number', 'feed_type__name')
    readonly_fields = ('is_expired',)

@admin.register(FeedingRecord)
class FeedingRecordAdmin(admin.ModelAdmin):
    list_display = ('feed_type', 'animal_type', 'get_subject', 'quantity_kg', 'date', 'created_by', 'estimated_cost')
    list_filter = ('date', 'animal_type')
    search_fields = ('feed_type__name', 'animal__tracking_id', 'animal_group__location', 'created_by__username')
    autocomplete_fields = ('feed_type', 'animal', 'animal_group', 'animal_type')
    readonly_fields = ('estimated_cost',)

    def get_subject(self, obj):
        return obj.animal.tracking_id if obj.animal else f"Group({obj.animal_group.id})"
    get_subject.short_description = 'Fed Subject'
