from django.conf import settings
from django.db import models
from django.core.exceptions import ValidationError
from imagekit.models import ImageSpecField
from imagekit.processors import ResizeToFill

from account.models import Farm
from utilities.validators import validate_attachment_extension

class AnimalType(models.Model):
    name = models.CharField(max_length=50, unique=True)
    description = models.TextField(blank=True, null=True)
    image = models.ImageField(upload_to='animal_types/', null=True, blank=True)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)
    farms = models.ManyToManyField(Farm, related_name='animal_types', blank=True)

    def __str__(self):
        return self.name

class AnimalBreed(models.Model):
    animal_type = models.ForeignKey(AnimalType, on_delete=models.CASCADE, related_name="breeds")
    name = models.CharField(max_length=50)
    description = models.TextField(blank=True, null=True)
    image = models.ImageField(upload_to='images/animal_breeds/', null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    thumbnail = ImageSpecField(
        source='image',
        processors=[ResizeToFill(250, 250)],
        format='JPEG',
        options={'quality': 85}
    )
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)
    farms = models.ManyToManyField(Farm, related_name='animal_breeds', blank=True)

    def __str__(self):
        return f"{self.name} ({self.animal_type.name})"

class WeightCategory(models.Model):
    min_weight = models.FloatField()
    max_weight = models.FloatField()
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)

    class Meta:
        unique_together = ('min_weight', 'max_weight')

    def clean(self):
        super().clean()
        if self.min_weight < 0 or self.max_weight < 0:
            raise ValidationError("Weights cannot be negative.")
        if self.min_weight >= self.max_weight:
            raise ValidationError("Max weight must be greater than min weight.")

    def save(self, *args, **kwargs):
        self.clean()
        return super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.min_weight}-{self.max_weight} kg"

class AnimalGroup(models.Model):
    animal_type = models.ForeignKey(AnimalType, on_delete=models.PROTECT)
    breed = models.ForeignKey(AnimalBreed, on_delete=models.PROTECT)
    quantity = models.PositiveIntegerField()
    location = models.CharField(max_length=100)
    farm = models.ForeignKey(Farm, on_delete=models.CASCADE, related_name='animal_groups')
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    notes = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"Group of {self.quantity} {self.animal_type.name} - {self.breed.name}"

class Animal(models.Model):
    tracking_id = models.CharField(max_length=50, unique=True)
    animal_type = models.ForeignKey(AnimalType, on_delete=models.PROTECT)
    breed = models.ForeignKey(AnimalBreed, on_delete=models.PROTECT)
    gender = models.CharField(max_length=10, choices=[("Male", "Male"), ("Female", "Female")])
    date_of_birth = models.DateField(null=True, blank=True)
    date_of_acquisition = models.DateField(null=True, blank=True)
    farm = models.ForeignKey(Farm, on_delete=models.CASCADE, related_name='animals')
    birth_record = models.ForeignKey('BirthRecord', null=True, blank=True, on_delete=models.SET_NULL, related_name='animals')
    acquisition_record = models.ForeignKey('AcquisitionRecord', null=True, blank=True, on_delete=models.SET_NULL, related_name='animals')
    death_record = models.ForeignKey('DiedRecord', null=True, blank=True, on_delete=models.SET_NULL, related_name='animals')
    status = models.CharField(max_length=20, choices=[
        ('active', 'Active'),
        ('sold', 'Sold'),
        ('died', 'Died'),
        ('quarantine', 'Quarantine')
    ], default='active')
    initial_weight = models.FloatField(null=True, blank=True)
    current_weight = models.FloatField(null=True, blank=True)
    last_weigh_date = models.DateField(null=True, blank=True)
    notes = models.TextField(blank=True, null=True)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    qr_code = models.ImageField(upload_to='qr_codes/', blank=True, null=True)

    def save(self, *args, **kwargs):
        if not self.id and not self.qr_code:
            super().save(*args, **kwargs)
            self.generate_qr_code()
            super().save(update_fields=['qr_code'])
        else:
            super().save(*args, **kwargs)

    def generate_qr_code(self):
        import qrcode
        from io import BytesIO
        from django.core.files import File

        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_H,
            box_size=10,
            border=4,
        )
        qr.add_data(f"{settings.SITE_URL}/api/animals/{self.id}/")
        qr.make(fit=True)
        img = qr.make_image(fill_color="black", back_color="white")

        buffer = BytesIO()
        img.save(buffer)
        filename = f'qr_animal_{self.tracking_id}.png'
        self.qr_code.save(filename, File(buffer), save=False)
    
    def __str__(self):
        return f"Animal {self.tracking_id}"
    
class BirthRecord(models.Model):
    animal = models.ForeignKey(Animal, null=True, blank=True, on_delete=models.SET_NULL)
    animal_group = models.ForeignKey(AnimalGroup, null=True, blank=True, on_delete=models.SET_NULL)
    date_of_birth = models.DateField(auto_now_add=True)
    number_of_male = models.PositiveIntegerField(default=0)
    number_of_female = models.PositiveIntegerField(default=0)
    number_of_died = models.PositiveIntegerField(default=0)
    weight = models.FloatField(null=True, blank=True)
    notes = models.TextField(blank=True, null=True)
    attachment = models.FileField(upload_to='expenses/attachments/%Y/%m/', null=True, blank=True, validators=[validate_attachment_extension])
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)
    farm = models.ForeignKey(Farm, on_delete=models.CASCADE, related_name='birth_records')
    created_at = models.DateTimeField(auto_now_add=True)

    def clean(self):
        if self.animal and self.animal_group:
            raise ValidationError("Only one of 'animal' or 'animal_group' can be set, not both.")
        if not self.animal and not self.animal_group:
            raise ValidationError("You must set either 'animal' or 'animal_group'.")
        if self.number_of_male + self.number_of_female + self.number_of_died == 0:
            raise ValidationError("The number of birth must be greater than 0")

class AcquisitionRecord(models.Model):
    animal = models.ForeignKey(Animal, null=True, blank=True, on_delete=models.SET_NULL)
    animal_group = models.ForeignKey(AnimalGroup, null=True, blank=True, on_delete=models.SET_NULL)
    date_of_acquisition = models.DateField(auto_now_add=True)
    quantity = models.PositiveIntegerField()
    weight = models.FloatField(null=True, blank=True)
    gender = models.CharField(max_length=10, choices=[("Male", "Male"), ("Female", "Female")])
    unit_preis = models.DecimalField(max_digits=8, decimal_places=2)
    vendor = models.CharField(max_length=100, blank=True, null=True)
    receipt_number = models.CharField(max_length=50, blank=True, null=True)
    notes = models.TextField(blank=True, null=True)
    attachment = models.FileField(upload_to='expenses/attachments/%Y/%m/', null=True, blank=True, validators=[validate_attachment_extension])
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)
    farm = models.ForeignKey(Farm, on_delete=models.CASCADE, related_name='acquisition_records')

    def clean(self):
        if self.animal and self.animal_group:
            raise ValidationError("Only one of 'animal' or 'animal_group' can be set, not both.")
        if not self.animal and not self.animal_group:
            raise ValidationError("You must set either 'animal' or 'animal_group'.")
        if self.quantity == 0:
            raise ValidationError("The quantity must be greater than 0")
        if self.unit_preis <= 0:
            raise ValidationError("The unit price must be greater than 0")

    @property
    def total_cost(self):
        return self.unit_preis * self.quantity

class DiedRecord(models.Model):
    animal = models.ForeignKey(Animal, null=True, blank=True, on_delete=models.SET_NULL)
    animal_group = models.ForeignKey(AnimalGroup, null=True, blank=True, on_delete=models.SET_NULL)
    date_of_death = models.DateField(auto_now_add=True)
    weight = models.FloatField()
    quantity = models.PositiveIntegerField()
    cause = models.CharField(max_length=200, blank=True, null=True)
    notes = models.TextField(blank=True, null=True)
    status = models.CharField(max_length=10, choices=[("verified", "Verified"), ("recorded", "Recorded"), ("cancelled", "Cancelled")], blank=True, null=True)
    attachment = models.FileField(upload_to='expenses/attachments/%Y/%m/', null=True, blank=True, validators=[validate_attachment_extension])
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)
    farm = models.ForeignKey(Farm, on_delete=models.CASCADE, related_name='died_records')
    created_at = models.DateTimeField(auto_now_add=True)

    def clean(self):
        if self.animal and self.animal_group:
            raise ValidationError("Only one of 'animal' or 'animal_group' can be set, not both.")
        if not self.animal and not self.animal_group:
            raise ValidationError("You must set either 'animal' or 'animal_group'.")

class AnimalInventory(models.Model):
    animal_type = models.ForeignKey(AnimalType, on_delete=models.CASCADE, related_name="inventories")
    breed = models.ForeignKey(AnimalBreed, on_delete=models.CASCADE, related_name="inventories")
    quantity = models.PositiveIntegerField(default=0)
    farm = models.ForeignKey(Farm, on_delete=models.CASCADE, related_name='animal_inventories')

    class Meta:
        unique_together = ('farm', 'animal_type', 'breed')

    def __str__(self):
        return f"{self.animal_type.name} - {self.breed.name} ({self.quantity})"