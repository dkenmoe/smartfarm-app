from django.contrib.auth.models import AbstractUser, Permission, Group
from django.db import models
from django.utils.translation import gettext_lazy as _
from django.core.validators import RegexValidator

class Role(models.Model):
    name = models.CharField(max_length=50, unique=True)
    description = models.TextField(blank=True, null=True)
    permissions = models.ManyToManyField(Permission, verbose_name=('permissions'), blank=True)
    
    def __str__(self):
        return self.name

class Country(models.Model):
    name = models.CharField(max_length=100, unique=True)
    code = models.CharField(max_length=3, unique=True)
    
    def __str__(self):
        return self.name
    
class City(models.Model):
    name = models.CharField(max_length=100)
    country = models.ForeignKey(Country, on_delete=models.CASCADE, related_name='cities')
    
    def __str__(self):
        return f"{self.name}, {self.country.name}"
    
    class Meta:
        verbose_name_plural = "Cities"
        unique_together = ('name', 'country')
        
class Address(models.Model):
    street = models.CharField(max_length=255)
    street2 = models.CharField(max_length=255, blank=True)
    city = models.ForeignKey(City, on_delete=models.PROTECT, related_name='addresses')
    postal_code = models.CharField(max_length=20)
    country = models.ForeignKey(Country, on_delete=models.PROTECT, related_name='addresses')
    
    def __str__(self):
        return f"{self.street}, {self.city.name}, {self.country.name}"
    
    class Meta:
        verbose_name_plural = "Addresses"

class CustomUser(AbstractUser):    
    # Phone number validation
    phone_regex = RegexValidator(
        regex=r'^\+?1?\d{9,15}$',
        message="Phone number must be entered in the format: '+999999999'. Up to 15 digits allowed."
    )
    
    profile_picture = models.ImageField(upload_to='profile_pictures/', blank=True, null=True)
    phone_number = models.CharField(validators=[phone_regex], max_length=17, blank=True)
    address = models.ForeignKey(Address, on_delete=models.SET_NULL, null=True, blank=True, related_name='users')
    roles = models.ManyToManyField(Role, blank=True, related_name='users')
    
    groups = models.ManyToManyField(
        Group,
        verbose_name=_('groups'),
        blank=True,
        help_text=_(
            'The groups this user belongs to. A user will get all permissions '
            'granted to each of their groups.'
        ),
        related_name="custom_user_set",
        related_query_name="custom_user",
    )
    
    def has_role(self, role_name):
        return self.roles.filter(name=role_name).exists()
    
    def has_permission(self, permission_name):
        if self.user_permissions.filter(codename=permission_name).exists():
            return True
        
        for role in self.roles.all():
            if role.permissions.filter(codename=permission_name).exists():
                return True
                
        for group in self.groups.all():
            if group.permissions.filter(codename=permission_name).exists():
                return True
                
        return False

    def get_address_display(self):
        if self.address:
            return f"{self.address.street}, {self.address.city.name}, {self.address.country.name}"
        return _("No address provided")
    
    def __str__(self):
        return f"{self.username}"
