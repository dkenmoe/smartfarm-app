from rest_framework import serializers
from account.serializers import FarmSerializer
from productions.models import (
    AnimalType, AnimalBreed, WeightCategory,
    BirthRecord, AcquisitionRecord, AnimalInventory, DiedRecord
)
from productions.models import Animal, AnimalGroup
from account.models import Farm

class FarmRelatedSerializer(serializers.ModelSerializer):
    farm = serializers.PrimaryKeyRelatedField(
        queryset=Farm.objects.all(),
        required=False,
        help_text="Farm ID this record belongs to"
    )

    def create(self, validated_data):
        if 'farm' not in validated_data:
            request = self.context.get('request')
            if request and hasattr(request, 'current_farm'):
                validated_data['farm'] = request.current_farm
            elif request and hasattr(request, 'current_farm_id'):
                validated_data['farm'] = Farm.objects.get(id=request.current_farm_id)
        return super().create(validated_data)

class AnimalTypeSerializer(serializers.ModelSerializer):
    image = serializers.SerializerMethodField()
    created_by_name = serializers.CharField(source='created_by.username', read_only=True)

    def get_image(self, obj):
        request = self.context.get('request')
        if obj.image and hasattr(obj.image, 'url'):
            return request.build_absolute_uri(obj.image.url) if request else obj.image.url
        return None

    class Meta:
        model = AnimalType
        fields = [
            'id',
            'name',
            'description',
            'image',
            'created_by',
            'created_by_name',
            'farms'
        ]
        read_only_fields = ['created_by', 'created_by_name']

class AnimalBreedSerializer(serializers.ModelSerializer):
    image = serializers.SerializerMethodField()
    thumbnail = serializers.SerializerMethodField()
    animal_type_name = serializers.CharField(source='animal_type.name', read_only=True)

    def get_image(self, obj):
        request = self.context.get('request')
        if obj.image and hasattr(obj.image, 'url'):
            return request.build_absolute_uri(obj.image.url) if request else obj.image.url
        return None

    def get_thumbnail(self, obj):
        request = self.context.get('request')
        if obj.thumbnail and hasattr(obj.thumbnail, 'url'):
            return request.build_absolute_uri(obj.thumbnail.url) if request else obj.thumbnail.url
        return None

    class Meta:
        model = AnimalBreed
        fields = [
            'id', 'name', 'description', 'animal_type', 'animal_type_name',
            'image', 'thumbnail', 'created_by', 'farms'
        ]

class WeightCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = WeightCategory
        fields = ['id', 'min_weight', 'max_weight', 'created_by']
        read_only_fields = ['created_by']

class BirthRecordSerializer(FarmRelatedSerializer):
    created_by_name = serializers.CharField(source='created_by.username', read_only=True)
    total_born = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = BirthRecord
        fields = [
            'id', 'animal', 'animal_group', 'weight', 'number_of_male', 'number_of_female',
            'number_of_died', 'total_born', 'date_of_birth', 'notes', 'attachment',
            'created_by', 'created_by_name', 'farm'
        ]
        read_only_fields = ['created_by', 'created_by_name']

    def get_total_born(self, obj):
        return obj.number_of_male + obj.number_of_female + obj.number_of_died

    def validate(self, data):
        if data.get('animal') and data.get('animal_group'):
            raise serializers.ValidationError("Only one of 'animal' or 'animal_group' can be set.")
        if not data.get('animal') and not data.get('animal_group'):
            raise serializers.ValidationError("You must provide either 'animal' or 'animal_group'.")
        if (data.get('number_of_male', 0) + data.get('number_of_female', 0) + data.get('number_of_died', 0)) == 0:
            raise serializers.ValidationError("Total number of births must be greater than 0.")
        return data

class AcquisitionRecordSerializer(FarmRelatedSerializer):
    created_by_name = serializers.CharField(source='created_by.username', read_only=True)
    total_cost = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = AcquisitionRecord
        fields = [
            'id', 'animal', 'animal_group', 'quantity', 'weight', 'gender',
            'unit_preis', 'total_cost', 'date_of_acquisition', 'vendor',
            'receipt_number', 'notes', 'attachment', 'created_by', 'created_by_name', 'farm'
        ]
        read_only_fields = ['created_by', 'created_by_name', 'total_cost']

    def get_total_cost(self, obj):
        if obj.unit_preis and obj.quantity:
            return float(obj.unit_preis) * obj.quantity
        return 0

    def validate(self, data):
        if data.get('animal') and data.get('animal_group'):
            raise serializers.ValidationError("Only one of 'animal' or 'animal_group' can be set.")
        if not data.get('animal') and not data.get('animal_group'):
            raise serializers.ValidationError("You must provide either 'animal' or 'animal_group'.")
        if data.get('quantity', 0) <= 0:
            raise serializers.ValidationError("Quantity must be greater than 0.")
        if data.get('unit_preis', 0) <= 0:
            raise serializers.ValidationError("Unit price must be greater than 0.")
        return data

class AnimalInventorySerializer(FarmRelatedSerializer):
    animal_type_name = serializers.CharField(source='animal_type.name', read_only=True)
    breed_name = serializers.CharField(source='breed.name', read_only=True)

    class Meta:
        model = AnimalInventory
        fields = [
            'id', 'animal_type', 'animal_type_name', 'breed', 'breed_name',
            'quantity', 'farm'
        ]

    def validate(self, data):
        animal_type = data.get('animal_type')
        breed = data.get('breed')
        if breed and animal_type and breed.animal_type != animal_type:
            raise serializers.ValidationError("The selected breed does not belong to the specified animal type.")
        return data

class DiedRecordSerializer(FarmRelatedSerializer):
    created_by_name = serializers.CharField(source='created_by.username', read_only=True)

    class Meta:
        model = DiedRecord
        fields = [
            'id', 'animal', 'animal_group', 'weight', 'quantity', 'date_of_death',
            'cause', 'notes', 'status', 'attachment', 'created_by', 'created_by_name', 'farm'
        ]
        read_only_fields = ['created_by', 'created_by_name']

    def validate(self, data):
        if data.get('animal') and data.get('animal_group'):
            raise serializers.ValidationError("Only one of 'animal' or 'animal_group' can be set.")
        if not data.get('animal') and not data.get('animal_group'):
            raise serializers.ValidationError("You must provide either 'animal' or 'animal_group'.")
        if data.get('quantity', 0) <= 0:
            raise serializers.ValidationError("Quantity must be greater than 0.")
        if data.get('weight', 0) <= 0:
            raise serializers.ValidationError("Weight must be greater than 0.")
        return data

class AnimalSerializer(serializers.ModelSerializer):
    animal_type = AnimalTypeSerializer(read_only=True)
    breed = AnimalBreedSerializer(read_only=True)
    farm = FarmSerializer(read_only=True)

    animal_type_id = serializers.PrimaryKeyRelatedField(
        queryset=Animal.objects.all(), source='animal_type', write_only=True
    )
    breed_id = serializers.PrimaryKeyRelatedField(
        queryset=Animal.objects.all(), source='breed', write_only=True
    )
    farm_id = serializers.PrimaryKeyRelatedField(
        queryset=Animal.objects.all(), source='farm', write_only=True
    )

    qr_code = serializers.SerializerMethodField()
    created_by = serializers.SerializerMethodField()

    def get_qr_code(self, obj):
        request = self.context.get('request')
        if obj.qr_code and hasattr(obj.qr_code, 'url'):
            return request.build_absolute_uri(obj.qr_code.url) if request else obj.qr_code.url
        return None

    def get_created_by(self, obj):
        return obj.created_by.username if obj.created_by else None

    class Meta:
        model = Animal
        fields = [
            'id',
            'tracking_id',
            'animal_type', 'breed', 'farm',
            'animal_type_id', 'breed_id', 'farm_id',
            'gender', 'date_of_birth', 'date_of_acquisition',
            'initial_weight', 'current_weight', 'last_weigh_date',
            'notes', 'qr_code', 'status',
            'created_by', 'created_at', 'updated_at'
        ]

class AnimalGroupSerializer(FarmRelatedSerializer):
    class Meta:
        model = AnimalGroup
        fields = '__all__'