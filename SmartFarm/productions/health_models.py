from datetime import datetime, timedelta
from django.conf import settings
from django.db import models
from django.forms import ValidationError
from finance.models import Supplier
from account.models import Farm
from productions.models import Animal, AnimalGroup

class HealthIssue(models.Model):
    farm = models.ForeignKey(Farm, on_delete=models.CASCADE, related_name="health_issues")
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, related_name="created_health_issues")
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    symptoms = models.TextField(blank=True, null=True)
    treatments = models.TextField(blank=True, null=True)
    is_contagious = models.BooleanField(default=False)

    def __str__(self):
        return self.name

class MedicationType(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    dosage_instructions = models.TextField(blank=True, null=True)
    withdrawal_period_days = models.PositiveIntegerField(default=0)
    supplier = models.ForeignKey(Supplier, null=True, blank=True, on_delete=models.SET_NULL)

    def __str__(self):
        return self.name

class HealthRecord(models.Model):
    farm = models.ForeignKey(Farm, on_delete=models.CASCADE, related_name="health_records")
    animal = models.ForeignKey(Animal, null=True, blank=True, on_delete=models.SET_NULL, related_name='health_records')
    animal_group = models.ForeignKey(AnimalGroup, null=True, blank=True, on_delete=models.SET_NULL, related_name='group_health_records')
    health_issue = models.ForeignKey(HealthIssue, null=True, blank=True, on_delete=models.SET_NULL)
    symptoms = models.TextField(blank=True, null=True)
    diagnosis = models.TextField(blank=True, null=True)
    start_date = models.DateField(auto_now_add=True)
    end_date = models.DateField(null=True, blank=True)
    is_resolved = models.BooleanField(default=False)
    notes = models.TextField(blank=True, null=True)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)

    def clean(self):
        if self.animal and self.animal_group:
            raise ValidationError("Only one of 'animal' or 'animal_group' can be set, not both.")
        if not self.animal and not self.animal_group:
            raise ValidationError("You must set either 'animal' or 'animal_group'.")

    def __str__(self):
        subject = self.animal.tracking_id if self.animal else f"Group({self.animal_group.id})"
        return f"{subject} - {self.health_issue} ({self.start_date})"

class Treatment(models.Model):
    health_record = models.ForeignKey(HealthRecord, on_delete=models.CASCADE, related_name='treatments')
    medication = models.ForeignKey(MedicationType, on_delete=models.PROTECT)
    date_administered = models.DateField()
    dosage = models.CharField(max_length=100)
    administered_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)
    notes = models.TextField(blank=True, null=True)

    def safe_consumption_date(self):
        return self.date_administered + timedelta(days=self.medication.withdrawal_period_days)

    def __str__(self):
        subject = self.health_record.animal.tracking_id if self.health_record.animal else f"Group({self.health_record.animal_group.id})"
        return f"{self.medication.name} for {subject} on {self.date_administered}"

class AdministeredTreatment(models.Model):
    health_record = models.ForeignKey(HealthRecord, on_delete=models.CASCADE)
    treatment = models.ForeignKey(Treatment, on_delete=models.PROTECT)
    date_administered = models.DateField()
    dosage = models.CharField(max_length=50)
    administered_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)
    notes = models.TextField(blank=True, null=True)

    def __str__(self):
        subject = self.health_record.animal.tracking_id if self.health_record.animal else f"Group({self.health_record.animal_group.id})"
        return f"{self.treatment.medication.name} for {subject} on {self.date_administered}"

class HealthCondition(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    symptoms = models.TextField(blank=True, null=True)
    treatments = models.TextField(blank=True, null=True)
    is_contagious = models.BooleanField(default=False)
    prevention_measures = models.TextField(blank=True, null=True)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)

    def __str__(self):
        return self.name
