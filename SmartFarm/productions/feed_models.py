from datetime import date
from django.conf import settings
from django.db import models
from django.core.exceptions import ValidationError

from productions.models import AnimalType
from .models import Animal, AnimalGroup
from finance.models import Supplier

class FeedType(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    nutritional_info = models.TextField(blank=True, null=True)
    suitable_for = models.ManyToManyField(AnimalType, related_name='suitable_feeds')
    cost_per_kg = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    supplier = models.ForeignKey(Supplier, null=True, blank=True, on_delete=models.SET_NULL)

    def __str__(self):
        return self.name

class FeedInventory(models.Model):
    feed_type = models.ForeignKey(FeedType, on_delete=models.CASCADE)
    quantity_kg = models.FloatField()
    batch_number = models.CharField(max_length=100, blank=True, null=True)
    purchase_date = models.DateField()
    expiry_date = models.DateField(null=True, blank=True)
    purchase_price = models.DecimalField(max_digits=10, decimal_places=2)
    notes = models.TextField(blank=True, null=True)

    @property
    def is_expired(self):
        if self.expiry_date:
            return date.today() > self.expiry_date
        return False

    def __str__(self):
        return f"{self.feed_type.name}: {self.quantity_kg}kg (Batch: {self.batch_number})"

class FeedingRecord(models.Model):
    feed_type = models.ForeignKey(FeedType, on_delete=models.CASCADE)
    animal = models.ForeignKey(Animal, null=True, blank=True, on_delete=models.SET_NULL, related_name='feeding_records')
    animal_group = models.ForeignKey(AnimalGroup, null=True, blank=True, on_delete=models.SET_NULL, related_name='feeding_records')
    animal_type = models.ForeignKey(AnimalType, on_delete=models.CASCADE)
    quantity_kg = models.FloatField()
    date = models.DateField(auto_now_add=True)
    notes = models.TextField(blank=True, null=True)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)

    @property
    def estimated_cost(self):
        return self.quantity_kg * self.feed_type.cost_per_kg if self.feed_type.cost_per_kg else None

    def clean(self):
        if self.animal and self.animal_group:
            raise ValidationError("Only one of 'animal' or 'animal_group' should be set.")
        if not self.animal and not self.animal_group:
            raise ValidationError("You must provide either 'animal' or 'animal_group'.")

    def __str__(self):
        subject = self.animal.tracking_id if self.animal else f"Group({self.animal_group.id})"
        return f"{self.feed_type.name} ({self.quantity_kg}kg) for {subject} on {self.date}"

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)
