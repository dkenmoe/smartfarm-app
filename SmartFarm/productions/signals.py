#productions/signals.py
from django.db import transaction
from django.db.models.signals import post_save
from django.dispatch import receiver
from productions.models import AcquisitionRecord, AnimalInventory, BirthRecord, DiedRecord

@receiver(post_save, sender=BirthRecord)
def increase_inventory_on_birth(sender, instance, created, **kwargs):
    if created:
        with transaction.atomic():
            inventory, _ = AnimalInventory.objects.get_or_create(
                animal_type=instance.animal.animal_type,
                breed=instance.animal.breed,
                farm=instance.farm,  # added farm to the lookup
                defaults={"quantity": 0}
            )
            inventory.quantity += instance.number_of_male + instance.number_of_female - instance.number_of_died
            inventory.save()

@receiver(post_save, sender=AcquisitionRecord)
def increase_inventory_on_acquisition(sender, instance, created, **kwargs):
    if created:
        with transaction.atomic():
            inventory, _ = AnimalInventory.objects.get_or_create(
                animal_type=instance.animal_type,
                breed=instance.breed,
                farm=instance.farm,  # added farm to the lookup
                defaults={"quantity": 0}
            )
            inventory.quantity += instance.quantity
            inventory.save()

@receiver(post_save, sender=DiedRecord)
def decrease_inventory_on_death(sender, instance, created, **kwargs):
    if created:
        with transaction.atomic():
            try:
                inventory = AnimalInventory.objects.get(
                    animal_type=instance.animal_type,
                    breed=instance.breed,
                    farm=instance.farm  # added farm to the lookup
                )
                inventory.quantity = max(0, inventory.quantity - instance.quantity)
                inventory.save()
            except AnimalInventory.DoesNotExist:
                pass
