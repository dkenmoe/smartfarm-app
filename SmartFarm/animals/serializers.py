from rest_framework import serializers
from .models import (
    AnimalInventory, AnimalType, AnimalBreed, AnimalGroup, WeightCategory,
    BirthRecord, HealthRecord, FeedingRecord
)

class AnimalTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = AnimalType
        fields = ['id', 'name', 'created_by']
        read_only_fields = ['created_by']

class AnimalBreedSerializer(serializers.ModelSerializer):
    class Meta:
        model = AnimalBreed
        fields = ['id', 'name', 'animal_type', 'created_by']
        read_only_fields = ['created_by']

class AnimalGroupSerializer(serializers.ModelSerializer):
    class Meta:
        model = AnimalGroup
        fields = '__all__'

class WeightCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = WeightCategory
        fields =  ['id', 'min_weight', 'max_weight', 'created_by']
        read_only_fields = ['created_by']

class BirthRecordSerializer(serializers.ModelSerializer):
    animal_type = serializers.PrimaryKeyRelatedField(queryset=AnimalType.objects.all())
    breed = serializers.PrimaryKeyRelatedField(queryset=AnimalBreed.objects.all())
    weight_category = serializers.PrimaryKeyRelatedField(queryset=WeightCategory.objects.all())
    
    animal_type_name = serializers.CharField(source='animal_type.name', read_only=True)
    breed_name = serializers.CharField(source='breed.name', read_only=True)
    weight_category_display = serializers.SerializerMethodField()
    class Meta:
        model = BirthRecord
        fields = ['id', 'animal_type', 'animal_type_name', 'breed', 'breed_name', 'gender',
                 'weight_category', 'weight_category_display', 'quantity', 'date_of_birth', 'created_by']
    
    def get_weight_category_display(self, obj):
        return f"{obj.weight_category.min_weight}-{obj.weight_category.max_weight} kg"
    
    def validate(self, data):
        """
        Ensure that the breed belongs to the selected animal type.
        """
        animal_type = data.get('animal_type')
        breed = data.get('breed')

        if breed and animal_type and breed.animal_type != animal_type:
            raise serializers.ValidationError("The selected breed does not belong to the specified animal type.")

        return data

class HealthRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = HealthRecord
        fields = '__all__'

class FeedingRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = FeedingRecord
        fields = '__all__'
        
class AnimalInventorySerializer(serializers.ModelSerializer):
    animal_type = serializers.PrimaryKeyRelatedField(queryset=AnimalType.objects.all())
    breed = serializers.PrimaryKeyRelatedField(queryset=AnimalBreed.objects.all())
    weight_category = serializers.PrimaryKeyRelatedField(queryset=WeightCategory.objects.all())
    
    # Des champs supplémentaires pour afficher les noms
    animal_type_name = serializers.CharField(source='animal_type.name', read_only=True)
    breed_name = serializers.CharField(source='breed.name', read_only=True)
    weight_category_display = serializers.SerializerMethodField()
    
    class Meta:
        model = AnimalInventory
        fields = ['id', 'animal_type', 'animal_type_name', 'breed', 'breed_name', 
                 'gender', 'weight_category', 'weight_category_display', 'quantity']
    
    def get_weight_category_display(self, obj):
        return f"{obj.weight_category.min_weight} - {obj.weight_category.max_weight} kg"
