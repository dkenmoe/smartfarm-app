from django.db.models import Sum
from animals.models import BirthRecord, DiedRecord, AnimalInventory

def get_production_overview():
    total_births = BirthRecord.objects.aggregate(total=Sum('quantity'))['total'] or 0
    total_deaths = DiedRecord.objects.aggregate(total=Sum('quantity'))['total'] or 0
    total_inventory = AnimalInventory.objects.aggregate(total=Sum('quantity'))['total'] or 0
    mortality_rate = (total_deaths / total_births) if total_births > 0 else 0
    
    return {
        'total_births': total_births,
        'total_deaths': total_deaths,
        'total_inventory': total_inventory,
        'mortality_rate': mortality_rate,
    }
    