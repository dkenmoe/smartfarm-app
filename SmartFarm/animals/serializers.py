from rest_framework import serializers
from .models import (
    AcquisitionRecord, AnimalInventory, AnimalType, AnimalBreed, AnimalGroup, DiedRecord, WeightCategory,
    BirthRecord, HealthRecord, FeedingRecord
)

class AnimalTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = AnimalType
        fields = ['id', 'name', 'created_by']
        read_only_fields = ['created_by']

class AnimalBreedSerializer(serializers.ModelSerializer):
    animal_type_name = serializers.CharField(source='animal_type.name', read_only=True)
    image = serializers.ImageField()
    thumbnail = serializers.ImageField()
    class Meta:
        model = AnimalBreed
        fields = [
            'id', 
            'name', 
            'description', 
            'animal_type',  # The ID for write operations
            'animal_type_name',  # The name for display
            'image',
            'thumbnail',
            'created_by'
        ]
        read_only_fields = ['created_by']
    def create(self, validated_data):       
        validated_data['created_by'] = self.context['request'].user
        return super().create(validated_data)

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
    
    animal_type_name = serializers.CharField(source='animal_type.name', read_only=True)
    breed_name = serializers.CharField(source='breed.name', read_only=True)
    class Meta:
        model = BirthRecord
        fields = ['id', 'animal_type', 'animal_type_name', 'breed', 'breed_name', 'weight', 'number_of_male', 'number_of_female', 'number_of_died', 'date_of_birth', 'created_by']
    
    def get_quantity(self, obj):
        return f"{obj.number_of_male + obj.number_of_female}"
    
    def validate(self, data):
        animal_type = data.get('animal_type')
        breed = data.get('breed')

        if breed and animal_type and breed.animal_type != animal_type:
            raise serializers.ValidationError("The selected breed does not belong to the specified animal type.")

        return data

class DiedRecordSerializer(serializers.ModelSerializer):
    animal_type = serializers.PrimaryKeyRelatedField(queryset=AnimalType.objects.all())
    breed = serializers.PrimaryKeyRelatedField(queryset=AnimalBreed.objects.all())
    
    animal_type_name = serializers.CharField(source='animal_type.name', read_only=True)
    breed_name = serializers.CharField(source='breed.name', read_only=True)
    # status = serializers.CharField(source='status', read_only=True)
    class Meta:
        model = DiedRecord
        fields = ['id', 'animal_type', 'animal_type_name', 'breed', 'breed_name', 'quantity', 'weight','date_of_death','created_by', 'status']
    
    def validate(self, data):
        animal_type = data.get('animal_type')
        breed = data.get('breed')

        if breed and animal_type and breed.animal_type != animal_type:
            raise serializers.ValidationError("The selected breed does not belong to the specified animal type.")

        return data
    
class AcquisitionRecordSerializer(serializers.ModelSerializer):
    animal_type = serializers.PrimaryKeyRelatedField(queryset=AnimalType.objects.all())
    breed = serializers.PrimaryKeyRelatedField(queryset=AnimalBreed.objects.all())
    
    animal_type_name = serializers.CharField(source='animal_type.name', read_only=True)
    breed_name = serializers.CharField(source='breed.name', read_only=True)
    class Meta:
        model = AcquisitionRecord
        fields = ['id', 'animal_type', 'animal_type_name', 'breed', 'breed_name', 'quantity', 'weight','unit_preis', 'gender', 'date_of_acquisition', 'created_by']
    
    def validate(self, data):
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
    
    animal_type_name = serializers.CharField(source='animal_type.name', read_only=True)
    breed_name = serializers.CharField(source='breed.name', read_only=True)
    
    class Meta:
        model = AnimalInventory
        fields = ['id', 'animal_type', 'animal_type_name', 'breed', 'breed_name', 'quantity']
    
    def get_quantity(self, obj):
         return f"{obj.number_of_male + obj.number_of_female}"
