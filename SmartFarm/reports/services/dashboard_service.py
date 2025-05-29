from datetime import date
from django.db.models import Sum

from finance.models import Expense
from finance.sales_models import Sale
from productions.models import DiedRecord, BirthRecord, AnimalInventory

class DashboardService:
    @staticmethod
    def get_metrics(farm, start_date=None, end_date=None, animal_type_id=None):
        date_range = {}
        if start_date and end_date:
            date_range = {'date__range': [start_date, end_date]}
        else:
            today = date.today()
            date_range = {'date__range': [today, today]}

        filters = {'farm': farm} if farm else {}

        # Inventory
        inventory_qs = AnimalInventory.objects.filter(**filters)
        if animal_type_id:
            inventory_qs = inventory_qs.filter(animal_type_id=animal_type_id)
        total_animals = inventory_qs.aggregate(total=Sum('quantity'))['total'] or 0

        # Sales
        sales_qs = Sale.objects.filter(**filters, sale_date__range=date_range['date__range'])
        sales_total = sales_qs.aggregate(total=Sum('total_amount'))['total'] or 0

        # Expenses
        expenses_qs = Expense.objects.filter(**filters, date__range=date_range['date__range'])
        expenses_total = expenses_qs.aggregate(total=Sum('amount'))['total'] or 0

        # Profit
        profit = sales_total - expenses_total

        # Deaths
        deaths_qs = DiedRecord.objects.filter(**filters, date_of_death__range=date_range['date__range'])
        if animal_type_id:
            deaths_qs = deaths_qs.filter(animal_type_id=animal_type_id)
        deaths = deaths_qs.aggregate(total=Sum('quantity'))['total'] or 0

        total_base = total_animals + deaths if total_animals + deaths else 1
        mortality_rate = round(deaths / total_base, 4)

        # Births
        births_qs = BirthRecord.objects.filter(**filters, date_of_birth__range=date_range['date__range'])
        if animal_type_id:
            births_qs = births_qs.filter(animal_type_id=animal_type_id)
        male = births_qs.aggregate(m=Sum('number_of_male'))['m'] or 0
        female = births_qs.aggregate(f=Sum('number_of_female'))['f'] or 0
        total_births = male + female

        return {
            'total_animals': total_animals,
            'sales_total': sales_total,
            'expenses_total': expenses_total,
            'profit': profit,
            'mortality_rate': mortality_rate,
            'births': total_births
        }
