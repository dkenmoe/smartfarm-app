from django_filters import rest_framework as filters
from django_filters.widgets import RangeWidget

from productions.models import Animal, AnimalGroup, BirthRecord, AcquisitionRecord, AnimalInventory, DiedRecord, AnimalType, AnimalBreed
from utilities.filters import BaseFarmFilter, BasePeriodFilter

class BirthRecordFilter(BaseFarmFilter, BasePeriodFilter):
    period = filters.ChoiceFilter(method='filter_birth_period', label='Period', choices=[
        ('week', 'This Week'), ('month', 'This Month'), ('year', 'This Year'),
        ('last_week', 'Last Week'), ('last_month', 'Last Month'), ('last_year', 'Last Year'),
    ])
    date_range = filters.DateFromToRangeFilter(field_name='date_of_birth', widget=RangeWidget(attrs={'type': 'date'}))
    animal = filters.ModelChoiceFilter(queryset=Animal.objects.all(), required=False)
    animal_group = filters.ModelChoiceFilter(queryset=AnimalGroup.objects.all(), required=False)
    weight_min = filters.NumberFilter(field_name='weight', lookup_expr='gte')
    weight_max = filters.NumberFilter(field_name='weight', lookup_expr='lte')
    number_of_male_min = filters.NumberFilter(field_name='number_of_male', lookup_expr='gte')
    number_of_female_min = filters.NumberFilter(field_name='number_of_female', lookup_expr='gte')

    def filter_birth_period(self, queryset, name, value):
        return self.filter_period(queryset, name, value, 'date_of_birth')

    class Meta:
        model = BirthRecord
        fields = ['animal', 'animal_group', 'date_of_birth', 'date_range', 'period',
                  'weight_min', 'weight_max', 'number_of_male_min', 'number_of_female_min',
                  'number_of_died', 'farm']

class AcquisitionRecordFilter(BaseFarmFilter, BasePeriodFilter):
    period = filters.ChoiceFilter(method='filter_acquisition_period', label='Period', choices=[
        ('week', 'This Week'), ('month', 'This Month'), ('year', 'This Year'),
        ('last_week', 'Last Week'), ('last_month', 'Last Month'), ('last_year', 'Last Year'),
    ])
    date_range = filters.DateFromToRangeFilter(field_name='date_of_acquisition', widget=RangeWidget(attrs={'type': 'date'}))
    animal = filters.ModelChoiceFilter(queryset=Animal.objects.all(), required=False)
    animal_group = filters.ModelChoiceFilter(queryset=AnimalGroup.objects.all(), required=False)
    weight_min = filters.NumberFilter(field_name='weight', lookup_expr='gte')
    weight_max = filters.NumberFilter(field_name='weight', lookup_expr='lte')
    quantity_min = filters.NumberFilter(field_name='quantity', lookup_expr='gte')
    gender = filters.ChoiceFilter(choices=[("Male", "Male"), ("Female", "Female")])

    def filter_acquisition_period(self, queryset, name, value):
        return self.filter_period(queryset, name, value, 'date_of_acquisition')

    class Meta:
        model = AcquisitionRecord
        fields = ['animal', 'animal_group', 'date_of_acquisition', 'date_range', 'period',
                  'weight_min', 'weight_max', 'quantity_min', 'gender', 'farm']

class AnimalInventoryFilter(BaseFarmFilter):
    animal_type = filters.ModelChoiceFilter(queryset=AnimalType.objects.all())
    breed = filters.ModelChoiceFilter(queryset=AnimalBreed.objects.all())
    quantity_min = filters.NumberFilter(field_name='quantity', lookup_expr='gte')
    quantity_max = filters.NumberFilter(field_name='quantity', lookup_expr='lte')

    class Meta:
        model = AnimalInventory
        fields = ['animal_type', 'breed', 'quantity_min', 'quantity_max', 'farm']

class DiedRecordFilter(BaseFarmFilter, BasePeriodFilter):
    period = filters.ChoiceFilter(method='filter_died_period', label='Period', choices=[
        ('week', 'This Week'), ('month', 'This Month'), ('year', 'This Year'),
        ('last_week', 'Last Week'), ('last_month', 'Last Month'), ('last_year', 'Last Year'),
    ])
    date_range = filters.DateFromToRangeFilter(field_name='date_of_death', widget=RangeWidget(attrs={'type': 'date'}))
    animal = filters.ModelChoiceFilter(queryset=Animal.objects.all(), required=False)
    animal_group = filters.ModelChoiceFilter(queryset=AnimalGroup.objects.all(), required=False)
    weight_min = filters.NumberFilter(field_name='weight', lookup_expr='gte')
    weight_max = filters.NumberFilter(field_name='weight', lookup_expr='lte')
    quantity_min = filters.NumberFilter(field_name='quantity', lookup_expr='gte')
    status = filters.ChoiceFilter(choices=[("verified", "Verified"), ("recorded", "Recorded"), ("cancelled", "Cancelled")])

    def filter_died_period(self, queryset, name, value):
        return self.filter_period(queryset, name, value, 'date_of_death')

    class Meta:
        model = DiedRecord
        fields = ['animal', 'animal_group', 'date_of_death', 'date_range', 'period',
                  'weight_min', 'weight_max', 'quantity_min', 'status', 'farm']
