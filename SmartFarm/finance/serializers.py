from rest_framework import serializers
from finance.models import Expense, ExpenseCategory, PaymentMethod
from account.models import Farm

class FarmRelatedSerializer(serializers.ModelSerializer):
    """Base serializer for models with farm relationship"""
    farm = serializers.PrimaryKeyRelatedField(
        queryset=Farm.objects.all(),
        required=False,  # Make it not required for backward compatibility
        help_text="Farm ID this record belongs to"
    )
    
    def create(self, validated_data):
        # If farm is not provided, use the current farm from the request
        if 'farm' not in validated_data:
            request = self.context.get('request')
            if request and hasattr(request, 'current_farm'):
                validated_data['farm'] = request.current_farm
            elif request and hasattr(request, 'current_farm_id'):
                validated_data['farm'] = Farm.objects.get(id=request.current_farm_id)
        return super().create(validated_data)


class ExpenseCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = ExpenseCategory
        fields = ['id', 'name', 'description', 'icon', 'color', 'created_at', 'updated_at']
        read_only_fields = ['created_at', 'updated_at']


class PaymentMethodSerializer(serializers.ModelSerializer):
    class Meta:
        model = PaymentMethod
        fields = ['id', 'name', 'description']


class ExpenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Expense
        fields = '__all__'
        read_only_fields = ['created_at', 'updated_at']

    def validate(self, data):
        # Ensure only one of animal / animal_group / animal_type is provided
        animal = data.get('animal')
        animal_group = data.get('animal_group')
        animal_type = data.get('animal_type')

        if not any([animal, animal_group, animal_type]):
            raise serializers.ValidationError("At least one of animal, animal_group or animal_type must be specified.")
        return data