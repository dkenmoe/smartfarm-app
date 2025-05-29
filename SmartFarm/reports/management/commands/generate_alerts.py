from django.core.management.base import BaseCommand
from account.models import Farm
from reports.services.alert_service import AlertService

class Command(BaseCommand):
    help = 'Generate alerts for all farms (e.g. mortality, weight gaps)'

    def handle(self, *args, **kwargs):
        for farm in Farm.objects.all():
            self.stdout.write(f"Processing alerts for farm: {farm.name}")
            AlertService.check_mortality_rate(farm)
            AlertService.check_animals_not_weighed(farm)
        self.stdout.write(self.style.SUCCESS("Finished generating alerts for all farms."))