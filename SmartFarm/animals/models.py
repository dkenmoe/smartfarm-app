from django.db import models
from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError

User = get_user_model()

class AnimalType(models.Model):
    """Defines the type of animals (e.g., Pigs, Chickens)"""
    name = models.CharField(max_length=50, unique=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    
    def __str__(self):
        return self.name
    
class AnimalBreed(models.Model):
    """Defines different breeds for each animal type (e.g., Large White, Landrace)"""
    animal_type = models.ForeignKey(AnimalType, on_delete=models.CASCADE, related_name="breeds")
    name = models.CharField(max_length=50)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    
    def __str__(self):
        return f"{self.name} ({self.animal_type.name})"
    
class WeightCategory(models.Model):
    """Defines weight categories for animals (e.g., 5-10kg, 11-20kg)"""
    min_weight = models.FloatField()
    max_weight = models.FloatField()
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    
    class Meta:
        unique_together = ('min_weight', 'max_weight')
    
    def clean(self):
        super().clean()        
        if(self.min_weight < 0 or self.max_weight < 0):
            raise ValidationError("Weights cannot be negative.")
        if(self.min_weight >= self.max_weight):
            raise ValidationError("Max weight must be greater than min weight.")
    
    def save(self, *args, **kwargs):
        self.clean()
        return super().save(*args, **kwargs)
    
    def __str__(self):
        return f"{self.min_weight}-{self.max_weight} kg"

class AnimalGroup(models.Model):
    """Represents a group of animals with shared characteristics"""
    animal_type = models.ForeignKey(AnimalType, on_delete=models.CASCADE, related_name="animal_groups")
    breed = models.ForeignKey(AnimalBreed, on_delete=models.CASCADE, related_name="animal_groups")
    gender = models.CharField(max_length=10, choices=[('male', 'Male'), ('female', 'Female')])
    quantity = models.IntegerField()
    birth_date = models.DateField()
    weight = models.FloatField()
    weight_category = models.ForeignKey(WeightCategory, on_delete=models.SET_NULL, null=True, blank=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name="animal_groups")
    
    def save(self, *args, **kwargs):
        """Automatically assigns a weight category"""
        categories = WeightCategory.objects.all()
        for category in categories:
            if category.min_weight <= self.weight <= category.max_weight:
                self.weight_category = category
                break
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.quantity} {self.breed.name} ({self.animal_type.name}) - {self.weight_category}"
    
class BirthRecord(models.Model):
    animal_type = models.ForeignKey(AnimalType, on_delete=models.CASCADE, related_name="birth_records")
    breed = models.ForeignKey(AnimalBreed, on_delete=models.CASCADE, related_name="birth_records")
    weight = models.FloatField(null=True, blank=True)
    number_of_male = models.PositiveIntegerField(default=0)
    number_of_female = models.PositiveIntegerField(default=0)
    number_of_died = models.PositiveIntegerField(default=0)
    date_of_birth = models.DateField(auto_now_add=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)

    def clean(self):
        super().clean()
        if self.breed.animal_type != self.animal_type:
            raise ValidationError("The selected breed does not belong to the specified animal type.")
        
        # if self.number_of_male + self.number_of_female + self.number_of_died == 0:
        #     raise ValidationError("The number of birth must be greather than 0");

    def save(self, *args, **kwargs):
        self.clean()  # Call clean() before saving
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.number_of_male + self.number_of_female} {self.animal_type} ({self.breed}) born on {self.date_of_birth}"

class HealthRecord(models.Model):
    """Tracks the health status of animals"""
    animal = models.ForeignKey(AnimalGroup, on_delete=models.CASCADE, related_name="health_records")
    checkup_date = models.DateField(auto_now_add=True)
    diagnosis = models.TextField()
    treatment = models.TextField()
    veterinarian = models.CharField(max_length=100)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)

    def __str__(self):
        return f"Health Check {self.animal.breed.name} - {self.checkup_date}"

class FeedingRecord(models.Model):
    """Tracks farm resources such as food, water, and medication"""
    name = models.CharField(max_length=100)
    type = models.CharField(max_length=50, choices=[('food', 'Food'), ('water', 'Water'), ('medicine', 'Medicine')])
    stock_quantity = models.FloatField()

    def __str__(self):
        return f"{self.name} - {self.type} ({self.stock_quantity})"
    
class AnimalPrice(models.Model):
    animal_type = models.ForeignKey(AnimalType, on_delete=models.CASCADE, related_name="prices")
    weight_category = models.ForeignKey(WeightCategory, on_delete=models.CASCADE, related_name="prices")
    breed = models.ForeignKey(AnimalBreed, on_delete=models.CASCADE,related_name='prices')
    price = models.DecimalField(max_digits=10, decimal_places=2)
    gender = models.CharField(max_length=10, choices=[("Male", "Male"), ("Female", "Female")])
    created_by = models.DateField(auto_now_add=True)
    
    class Meta:
        unique_together = ('animal_type', 'weight_category')
    
    def clean(self):
        super().clean()
        if self.breed.animal_type != self.animal_type:
            raise ValidationError("The selected breed does not belong to the specified animal type.")

    def save(self, *args, **kwargs):
        self.clean() 
        super().save(*args, **kwargs)
        
    def __str__(self):
        return f"{self.animal_type.name} ({self.weight_category}) - ${self.price}"

class AnimalInventory(models.Model):
    animal_type = models.ForeignKey(AnimalType, on_delete=models.CASCADE, related_name="inventories")
    breed = models.ForeignKey(AnimalBreed, on_delete=models.CASCADE, related_name="inventories")
    quantity = models.PositiveIntegerField(default=0)  # Total count of animals in this category

    class Meta:
        unique_together = ('animal_type', 'breed', 'quantity') 
        
    def __str__(self):
        return f"{self.animal_type.name} - {self.breed.name} - {self.breed}: {self.quantity}"

class DiedRecord(models.Model):
    animal_type = models.ForeignKey(AnimalType, on_delete=models.CASCADE, related_name="died_records")
    breed = models.ForeignKey(AnimalBreed, on_delete=models.CASCADE, related_name="died_records")
    weight = models.FloatField()
    quantity = models.PositiveIntegerField()
    date_of_death = models.DateField(auto_now_add=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)