from rest_framework import serializers

from animals.models import AnimalBreed, AnimalType
from .models import Expense, ExpenseCategory, Supplier, PaymentMethod

class ExpenseCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = ExpenseCategory
        fields = '__all__'

class SupplierSerializer(serializers.ModelSerializer):
    class Meta:
        model = Supplier
        fields = '__all__'

class PaymentMethodSerializer(serializers.ModelSerializer):
    class Meta:
        model = PaymentMethod
        fields = '__all__'

class ExpenseSerializer(serializers.ModelSerializer):
    category = ExpenseCategorySerializer(read_only=True)
    category_id = serializers.PrimaryKeyRelatedField(
        queryset=ExpenseCategory.objects.all(), source='category', write_only=True
    )
    
    supplier = SupplierSerializer(read_only=True)
    supplier_id = serializers.PrimaryKeyRelatedField(
        queryset=Supplier.objects.all(), source='supplier', write_only=True, allow_null=True, required=False
    )

    animal_breed = SupplierSerializer(read_only=True)
    animal_breed_id = serializers.PrimaryKeyRelatedField(
        queryset=AnimalBreed.objects.all(), source='animal_breed', write_only=True, allow_null=True, required=False
    )
    
    animal_type = SupplierSerializer(read_only=True)
    animal_type_id = serializers.PrimaryKeyRelatedField(
        queryset=AnimalType.objects.all(), source='animal_type', write_only=True, allow_null=True, required=False
    )

    payment_method = PaymentMethodSerializer(read_only=True)
    payment_method_id = serializers.PrimaryKeyRelatedField(
        queryset=PaymentMethod.objects.all(), source='payment_method', write_only=True, allow_null=True, required=False
    )

    class Meta:
        model = Expense
        fields = [
            'id', 'category', 'category_id', 'description', 'amount', 'date',
            'supplier', 'supplier_id', 'payment_method', 'payment_method_id',
            'created_by', 'attachment', 'invoice_number', 'is_recurrent', 'status',
            'created_at', 'updated_at', 'animal_type', 'animal_type_id', 'animal_breed', 'animal_breed_id'
        ]
        read_only_fields = ['created_by', 'created_at', 'updated_at']

    def create(self, validated_data):
        validated_data['created_by'] = self.context['request'].user
        return super().create(validated_data)
