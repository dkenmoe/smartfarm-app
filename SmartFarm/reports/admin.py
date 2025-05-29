from django.contrib import admin
from reports.models import Alert

@admin.register(Alert)
class AlertAdmin(admin.ModelAdmin):
    list_display = ('message', 'severity', 'is_resolved', 'farm', 'created_at')
    list_filter = ('severity', 'is_resolved', 'farm')
    search_fields = ('message',)
    readonly_fields = ('created_at',)
    autocomplete_fields = ('farm',)