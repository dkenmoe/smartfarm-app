from rest_framework import serializers

from finance.sales_models import Sale, SaleItem
from productions.models import Animal, AnimalGroup, AnimalType

# ----------------------------
# Serializers
# ----------------------------
class SaleItemSerializer(serializers.ModelSerializer):
    animal_id = serializers.PrimaryKeyRelatedField(queryset=Animal.objects.all(), source='animal', required=False, allow_null=True)
    animal_group_id = serializers.PrimaryKeyRelatedField(queryset=AnimalGroup.objects.all(), source='animal_group', required=False, allow_null=True)
    animal_type_id = serializers.PrimaryKeyRelatedField(queryset=AnimalType.objects.all(), source='animal_type', required=False, allow_null=True)

    class Meta:
        model = SaleItem
        fields = ['id', 'animal_id', 'animal_group_id', 'animal_type_id', 'quantity', 'unit_price', 'subtotal']
        read_only_fields = ['subtotal']

    def validate(self, data):
        if not any([data.get('animal'), data.get('animal_group'), data.get('animal_type')]):
            raise serializers.ValidationError("At least one of animal, animal group, or animal type must be set.")
        return data


class SaleSerializer(serializers.ModelSerializer):
    items = SaleItemSerializer(many=True)
    balance_due = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)

    class Meta:
        model = Sale
        fields = [
            'id', 'farm', 'customer', 'invoice_number', 'total_amount', 'amount_paid', 'balance_due',
            'payment_method', 'sale_date', 'notes', 'created_by', 'created_at', 'items'
        ]
        read_only_fields = ['created_by', 'created_at', 'balance_due']

    def create(self, validated_data):
        items_data = validated_data.pop('items')
        request = self.context.get('request')
        if request and hasattr(request, 'user'):
            validated_data['created_by'] = request.user

        sale = Sale.objects.create(**validated_data)
        for item_data in items_data:
            SaleItem.objects.create(sale=sale, **item_data)
        return sale

    def update(self, instance, validated_data):
        items_data = validated_data.pop('items', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        if items_data is not None:
            instance.items.all().delete()
            for item_data in items_data:
                SaleItem.objects.create(sale=instance, **item_data)
        return instance