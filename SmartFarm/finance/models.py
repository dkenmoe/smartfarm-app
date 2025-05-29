from django.conf import settings
from django.db import models
from django.core.validators import MinValueValidator
from datetime import date

from django.forms import ValidationError

from productions.models import AnimalType, AnimalBreed
from productions.models import Animal, AnimalGroup
from utilities.models import TimestampedModel
from utilities.validators import validate_attachment_extension
from account.models import Farm, Supplier

class ExpenseCategory(TimestampedModel):
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True, null=True)
    icon = models.CharField(max_length=50, blank=True, null=True)
    color = models.CharField(max_length=20, blank=True, null=True)

    class Meta:
        ordering = ['name']
        verbose_name = "Catégorie de dépense"
        verbose_name_plural = "Catégories de dépenses"

    def __str__(self):
        return self.name

class PaymentMethod(models.Model):
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True, null=True)

    class Meta:
        ordering = ['name']
        verbose_name = "Méthode de paiement"
        verbose_name_plural = "Méthodes de paiement"

    def __str__(self):
        return self.name

class Expense(TimestampedModel):
    farm = models.ForeignKey(Farm, on_delete=models.CASCADE, related_name='expenses')
    category = models.ForeignKey(ExpenseCategory, on_delete=models.PROTECT, related_name='expenses')
    amount = models.DecimalField(max_digits=12, decimal_places=2, validators=[MinValueValidator(0)])
    description = models.TextField(blank=True, null=True)
    date = models.DateField(default=date.today)

    # Animal references
    animal_type = models.ForeignKey(AnimalType, on_delete=models.SET_NULL, null=True, blank=True)
    animal_breed = models.ForeignKey(AnimalBreed, on_delete=models.SET_NULL, null=True, blank=True)
    animal = models.ForeignKey(Animal, on_delete=models.SET_NULL, null=True, blank=True)
    animal_group = models.ForeignKey(AnimalGroup, on_delete=models.SET_NULL, null=True, blank=True)

    supplier = models.ForeignKey(Supplier, on_delete=models.SET_NULL, null=True, blank=True)
    payment_method = models.ForeignKey(PaymentMethod, on_delete=models.SET_NULL, null=True, blank=True)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="expenses")

    invoice_number = models.CharField(max_length=100, blank=True, null=True)
    is_recurrent = models.BooleanField(default=False)
    status = models.CharField(max_length=20, choices=[
        ('pending', 'En attente'),
        ('completed', 'Complétée'),
        ('cancelled', 'Annulée')
    ], default='completed')

    attachment = models.FileField(
        upload_to='expenses/attachments/%Y/%m/',
        null=True, blank=True,
        validators=[validate_attachment_extension],
        help_text="Image, PDF ou autre fichier justificatif"
    )

    class Meta:
        ordering = ['-date', '-created_at']
        indexes = [
            models.Index(fields=['date']),
            models.Index(fields=['category']),
            models.Index(fields=['animal_type']),
        ]
        verbose_name = "Dépense"
        verbose_name_plural = "Dépenses"

    def __str__(self):
        return f"{self.category.name} - {self.amount} FCFA le {self.date}"

    def clean(self):
        if self.animal_breed and self.animal_type:
            if self.animal_breed.animal_type != self.animal_type:
                raise ValidationError("La race ne correspond pas au type d'animal sélectionné.")
