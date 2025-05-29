# reports/services/alert_service.py
from datetime import timedelta, date
from django.db.models import Sum, Q
from productions.models import DiedRecord, BirthRecord, Animal
from reports.models import Alert

class AlertService:

    @staticmethod
    def check_mortality_rate(farm, threshold=0.05):
        today = date.today()
        start = today - timedelta(days=7)

        deaths = DiedRecord.objects.filter(farm=farm, date_of_death__range=(start, today)).aggregate(total=Sum('quantity'))['total'] or 0
        active_animals = Animal.objects.filter(farm=farm, status='active').count()
        base = active_animals + deaths if active_animals + deaths else 1

        rate = deaths / base

        if rate > threshold:
            Alert.objects.create(
                farm=farm,
                message=f"High mortality rate this week: {rate:.2%}",
                severity='high'
            )

    @staticmethod
    def check_animals_not_weighed(farm, days_without_weight=30):
        cutoff = date.today() - timedelta(days=days_without_weight)
        animals = Animal.objects.filter(farm=farm, last_weigh_date__lt=cutoff, status='active')
        if animals.exists():
            Alert.objects.create(
                farm=farm,
                message=f"{animals.count()} animals not weighed in the last {days_without_weight} days",
                severity='medium'
            )
