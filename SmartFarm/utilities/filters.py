from django_filters import rest_framework as filters
from django.utils import timezone
import datetime

class BaseFarmFilter(filters.FilterSet):
    farm = filters.NumberFilter(method='filter_farm')

    def filter_farm(self, queryset, name, value):
        if value:
            return queryset.filter(farm=value)

        user = getattr(self.request, 'user', None)
        if user and user.is_authenticated:
            current_farm = getattr(self.request, 'current_farm', None)
            if current_farm:
                return queryset.filter(farm=current_farm)
            if hasattr(user, 'accessible_farms'):
                return queryset.filter(farm__in=user.accessible_farms.all())
        return queryset

class BasePeriodFilter:
    def filter_period(self, queryset, name, value, date_field):
        today = timezone.now().date()

        ranges = {
            'week': today - datetime.timedelta(days=today.weekday()),
            'month': today.replace(day=1),
            'year': today.replace(month=1, day=1),
            'last_week': (today - datetime.timedelta(days=today.weekday() + 7), today - datetime.timedelta(days=today.weekday() + 1)),
            'last_month': (
                (today.replace(day=1) - datetime.timedelta(days=1)).replace(day=1),
                today.replace(day=1) - datetime.timedelta(days=1)
            ),
            'last_year': (today.replace(year=today.year - 1, month=1, day=1), today.replace(month=1, day=1)),
        }

        if value in ['week', 'month', 'year']:
            return queryset.filter(**{f'{date_field}__gte': ranges[value]})
        elif value in ['last_week', 'last_month', 'last_year']:
            start, end = ranges[value]
            return queryset.filter(**{f'{date_field}__range': (start, end)})

        return queryset
