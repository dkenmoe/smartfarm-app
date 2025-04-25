from django.conf import settings
from django.db import models
from django.core.validators import MinValueValidator

from animals.models import AnimalBreed, AnimalType
from core.models import TimestampedModel
from datetime import date

from finance.validators import validate_attachment_extension

class ExpenseCategory(TimestampedModel):
    """Catégories de dépenses: Nourriture, Médicaments, etc."""
    name = models.CharField(max_length=100, unique=True, verbose_name="Nom")
    description = models.TextField(blank=True, null=True, verbose_name="Description")
    icon = models.CharField(max_length=50, blank=True, null=True, verbose_name="Icône")
    color = models.CharField(max_length=20, blank=True, null=True, verbose_name="Couleur")
    
    class Meta:
        verbose_name = "Catégorie de dépense"
        verbose_name_plural = "Catégories de dépenses"
        ordering = ['name']
    
    def __str__(self):
        return self.name

class Supplier(TimestampedModel):
    """Fournisseur"""
    name = models.CharField(max_length=255, verbose_name="Nom")
    contact_person = models.CharField(max_length=255, blank=True, null=True, verbose_name="Personne à contacter")
    email = models.EmailField(blank=True, null=True, verbose_name="Email")
    phone = models.CharField(max_length=20, blank=True, null=True, verbose_name="Téléphone")
    address = models.TextField(blank=True, null=True, verbose_name="Adresse")
    notes = models.TextField(blank=True, null=True, verbose_name="Notes")
    is_active = models.BooleanField(default=True, verbose_name="Actif")
    
    class Meta:
        verbose_name = "Fournisseur"
        verbose_name_plural = "Fournisseurs"
        ordering = ['name']
    
    def __str__(self):
        return self.name

class PaymentMethod(models.Model):
    """Méthode de paiement: Espèces, Chèque, Virement, etc."""
    name = models.CharField(max_length=100, unique=True, verbose_name="Nom")
    description = models.TextField(blank=True, null=True, verbose_name="Description")
    
    class Meta:
        verbose_name = "Méthode de paiement"
        verbose_name_plural = "Méthodes de paiement"
        ordering = ['name']
    
    def __str__(self):
        return self.name
    

class Expense(TimestampedModel):
    category = models.ForeignKey(ExpenseCategory, on_delete=models.PROTECT, related_name="expenses", verbose_name="Catégorie")
    description = models.TextField(blank=True, null=True, verbose_name="Description")
    amount = models.DecimalField(max_digits=12, decimal_places=2, validators=[MinValueValidator(0)], verbose_name="Montant (FCFA)" )
    date = models.DateField(default=date.today, verbose_name="Date")
    
    # Relations optionnelles
    animal_type = models.ForeignKey(AnimalType, on_delete=models.SET_NULL, null=True, blank=True, related_name="expenses", verbose_name="Type d'animal")
    animal_breed = models.ForeignKey(AnimalBreed, on_delete=models.SET_NULL, null=True, blank=True, related_name="expenses", verbose_name="Race")
    supplier = models.ForeignKey(Supplier, on_delete=models.SET_NULL, null=True, blank=True, related_name="expenses", verbose_name="Fournisseur")
    payment_method = models.ForeignKey(PaymentMethod, on_delete=models.SET_NULL, null=True, blank=True, related_name="expenses", verbose_name="Méthode de paiement")
    
    # Utilisateur qui a créé la dépense
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="expenses", verbose_name="Créé par")
    
    # Pièce jointe
    attachment = models.FileField(upload_to='expenses/attachments/%Y/%m/', null=True, blank=True, validators=[validate_attachment_extension],
    verbose_name="Pièce jointe",
    help_text="Image, PDF ou autre fichier justificatif"
)
    
    # Information additionnelle
    invoice_number = models.CharField(max_length=100, blank=True, null=True, verbose_name="Numéro de facture")
    is_recurrent = models.BooleanField(default=False, verbose_name="Dépense récurrente")
    status = models.CharField(max_length=20, choices=[
            ('pending', 'En attente'),
            ('completed', 'Complétée'),
            ('cancelled', 'Annulée')
        ],
        default='completed',
        verbose_name="Statut"
    )
    
    class Meta:
        verbose_name = "Dépense"
        verbose_name_plural = "Dépenses"
        ordering = ['-date', '-created_at']
        indexes = [
            models.Index(fields=['date']),
            models.Index(fields=['category']),
            models.Index(fields=['animal_type']),
        ]
    
    def __str__(self):
        return f"{self.category.name} - {self.amount} FCFA le {self.date}"
    
    def save(self, *args, **kwargs):
        # Validation: animal_breed doit correspondre à animal_type
        if self.animal_breed and self.animal_type and self.animal_breed.animal_type != self.animal_type:
            self.animal_breed = None
        super().save(*args, **kwargs)