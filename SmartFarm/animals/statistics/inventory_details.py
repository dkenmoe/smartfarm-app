from django.db.models import Sum
from animals.models import AnimalInventory

def get_inventory_details(filters=None):
    filters = filters or {}
    inventory = (AnimalInventory.objects.filter(**filters)
                 .values('animal_type__name', 'breed__name', 'gender', 'weight_category__min_weight', 'weight_category__max_weight')
                 .annotate(total_inventory=Sum('quantity'))
                 .order_by('animal_type__name', 'breed__name'))
    return list(inventory)
