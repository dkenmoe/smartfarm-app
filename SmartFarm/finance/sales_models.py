from django.conf import settings
from django.db import models
from django.core.exceptions import ValidationError
from django.utils.translation import gettext_lazy as _

from finance.models import PaymentMethod
from productions.models import Animal, AnimalGroup, AnimalType
from account.models import Customer, Farm

class Sale(models.Model):
    farm = models.ForeignKey(Farm, on_delete=models.CASCADE, related_name="sales")
    customer = models.ForeignKey(
        Customer,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        help_text=_("Optional customer; leave blank for walk-in or unknown buyers.")
    )
    invoice_number = models.CharField(max_length=50, unique=True)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    amount_paid = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    payment_method = models.ForeignKey(PaymentMethod, on_delete=models.SET_NULL, null=True, blank=True)
    sale_date = models.DateField(auto_now_add=True)
    notes = models.TextField(blank=True, null=True)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    @property
    def balance_due(self):
        return max(self.total_amount - self.amount_paid, 0)

    def __str__(self):
        return f"Invoice {self.invoice_number} - {self.sale_date}"

class SaleItem(models.Model):
    sale = models.ForeignKey(Sale, on_delete=models.CASCADE, related_name='items')
    animal = models.ForeignKey(Animal, on_delete=models.SET_NULL, null=True, blank=True)
    animal_group = models.ForeignKey(AnimalGroup, on_delete=models.SET_NULL, null=True, blank=True)
    animal_type = models.ForeignKey(AnimalType, on_delete=models.SET_NULL, null=True, blank=True)
    quantity = models.PositiveIntegerField(default=1)
    unit_price = models.DecimalField(max_digits=10, decimal_places=2)

    @property
    def subtotal(self):
        return self.quantity * self.unit_price

    def clean(self):
        if not any([self.animal, self.animal_group, self.animal_type]):
            raise ValidationError("At least one of animal, animal group, or animal type must be specified.")

    def __str__(self):
        if self.animal:
            return f"Animal: {self.animal.tracking_id} - {self.unit_price}"
        elif self.animal_group:
            return f"Group: {self.animal_group.id} - {self.unit_price}"
        elif self.animal_type:
            return f"{self.quantity} x {self.animal_type.name} - {self.unit_price}"
        return f"Sale item - {self.unit_price}"
