from django.db import transaction
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import AcquisitionRecord, AnimalInventory, BirthRecord, DiedRecord

@receiver(post_save, sender=BirthRecord)
def increase_animal_inventory(sender, instance, created, **kwargs):
    if created:
        with transaction.atomic():  # Ensures safe DB operation
            inventory, created = AnimalInventory.objects.get_or_create(
                animal_type=instance.animal_type,
                breed=instance.breed,
                defaults={"quantity": 0}
            )
            inventory.quantity += instance.number_of_male + instance.number_of_female
            inventory.save()

@receiver(post_save, sender=AcquisitionRecord)
def increase_animal_inventory(sender, instance, created, **kwargs):
    if created:
        with transaction.atomic():  # Ensures safe DB operation
            inventory, created = AnimalInventory.objects.get_or_create(
                animal_type=instance.animal_type,
                breed=instance.breed,
                defaults={"quantity": 0}
            )
            inventory.quantity += instance.quantity
            inventory.save()

@receiver(post_save, sender=DiedRecord)
def decrease_animal_inventory(sender, instance, created, **kwargs):
    if created:
        with transaction.atomic():
            try:
                inventory = AnimalInventory.objects.get(
                    animal_type=instance.animal_type,
                    breed=instance.breed,
                )
                inventory.quantity = max(0, inventory.quantity - instance.quantity)  # Prevent negative values
                inventory.save()
            except AnimalInventory.DoesNotExist:
                pass  # Avoid error if no inventory exists
