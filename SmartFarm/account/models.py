from django.conf import settings
from django.contrib.auth.models import AbstractUser, Permission, Group
from django.db import models
from django.utils.translation import gettext_lazy as _
from django.core.validators import RegexValidator
from utilities.models import TimestampedModel


def get_user_roles(user):
    return list(user.roles.values_list('name', flat=True))

def get_user_permissions(user):
    permissions = set(user.user_permissions.values_list('codename', flat=True))
    for role in user.roles.all():
        permissions.update(role.permissions.values_list('codename', flat=True))
    for group in user.groups.all():
        permissions.update(group.permissions.values_list('codename', flat=True))
    return permissions

def get_farm_roles(user, farm_id):
    return Role.objects.filter(farm_users__farm_id=farm_id, farm_users__user=user)

def has_farm_permission(user, farm_id, permission_codename):
    roles = get_farm_roles(user, farm_id)
    return any(role.permissions.filter(codename=permission_codename).exists() for role in roles)


class Role(models.Model):
    name = models.CharField(max_length=50, unique=True)
    description = models.TextField(blank=True, null=True)
    permissions = models.ManyToManyField(Permission, verbose_name='permissions', blank=True)

    def __str__(self):
        return self.name


class AddressFields(models.Model):
    street = models.CharField(max_length=255)
    street2 = models.CharField(max_length=255, blank=True)
    city = models.CharField(max_length=100)
    postal_code = models.CharField(max_length=20)
    country_name = models.CharField(max_length=100)
    country_code = models.CharField(max_length=3)

    class Meta:
        abstract = True  # Pas de table en base

class CustomUser(AddressFields, AbstractUser):
    phone_regex = RegexValidator(
        regex=r'^\+?1?\d{9,15}$',
        message="Phone number must be entered in the format: '+999999999'. Up to 15 digits allowed."
    )
    profile_picture = models.ImageField(upload_to='profile_pictures/', blank=True, null=True)
    phone_number = models.CharField(validators=[phone_regex], max_length=17, blank=True, null=True)

    roles = models.ManyToManyField('Role', blank=True, related_name='users')

    groups = models.ManyToManyField(
        Group,
        verbose_name=_('groups'),
        blank=True,
        help_text=_('The groups this user belongs to. A user will get all permissions granted to each of their groups.'),
        related_name="custom_user_set",
        related_query_name="custom_user",
    )

    def has_role(self, role_name):
        return role_name in get_user_roles(self)

    def has_permission(self, permission_name):
        return permission_name in get_user_permissions(self)

    def __str__(self):
        return self.username

class Farm(AddressFields, TimestampedModel):
    name = models.CharField(max_length=100)
    size_hectares = models.FloatField(null=True, blank=True)
    owner = models.ForeignKey('CustomUser', on_delete=models.SET_NULL, null=True, blank=True, related_name='owned_farms')
    users = models.ManyToManyField('CustomUser', through='FarmUser', related_name='accessible_farms')
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return self.name

class FarmUser(models.Model):
    farm = models.ForeignKey(Farm, on_delete=models.CASCADE)
    user = models.ForeignKey('CustomUser', on_delete=models.CASCADE)
    roles = models.ManyToManyField(Role, blank=True, related_name='farm_users')
    date_joined = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('farm', 'user')
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['farm']),
        ]

    def __str__(self):
        return f"{self.user.username} - {self.farm.name}"


class Supplier(AddressFields, TimestampedModel):
    name = models.CharField(max_length=255, verbose_name="Name")
    contact_person = models.CharField(max_length=255, blank=True, null=True, verbose_name="Contact Person")
    email = models.EmailField(blank=True, null=True, verbose_name="Email")
    phone = models.CharField(max_length=20, blank=True, null=True, verbose_name="Phone")
    notes = models.TextField(blank=True, null=True, verbose_name="Notes")
    is_active = models.BooleanField(default=True, verbose_name="Active")
    farms = models.ManyToManyField('Farm', blank=True, related_name='suppliers')

    def __str__(self):
        return self.name


class Customer(AddressFields, TimestampedModel):
    name = models.CharField(max_length=100)
    phone = models.CharField(max_length=30, blank=True)
    email = models.EmailField(blank=True)
    farm = models.ForeignKey('Farm', on_delete=models.CASCADE, related_name='customers')
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)

    def __str__(self):
        return self.name
