from django.db.models import Sum
from animals.models import BirthRecord, DiedRecord

def get_production_by_type(filters=None):
    # If filters is None, use an empty dict
    filters = filters or {}

    births = (BirthRecord.objects.filter(**filters)
              .values('animal_type__name', 'breed__name')
              .annotate(total_births=Sum('quantity'))
              .order_by('animal_type__name', 'breed__name'))

    deaths = (DiedRecord.objects.filter(**filters)
              .values('animal_type__name', 'breed__name')
              .annotate(total_deaths=Sum('quantity'))
              .order_by('animal_type__name', 'breed__name'))

    return {
        'births_by_type': list(births),
        'deaths_by_type': list(deaths),
    }