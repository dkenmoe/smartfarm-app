from datetime import timedelta
from rest_framework import serializers
from productions.health_models import HealthIssue, HealthRecord, MedicationType, Treatment


class HealthIssueSerializer(serializers.ModelSerializer):
    class Meta:
        model = HealthIssue
        fields = '__all__' 

    def create(self, validated_data):
        validated_data['created_by'] = self.context['request'].user
        validated_data['farm'] = self.context['request'].user.farm  # Adjust if user has multiple farms
        return super().create(validated_data)


class MedicationTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = MedicationType
        fields = '__all__' 

    def create(self, validated_data):
        validated_data['created_by'] = self.context['request'].user
        validated_data['farm'] = self.context['request'].user.farm
        return super().create(validated_data)


class HealthRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = HealthRecord
        fields = '__all__'

class TreatmentSerializer(serializers.ModelSerializer):
    safe_consumption_date = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Treatment
        fields = '__all__'   # We'll set this in `create()`

    def get_safe_consumption_date(self, obj):
        if obj.medication and obj.date_administered:
            return obj.date_administered + timedelta(days=obj.medication.withdrawal_period_days)
        return None

    def create(self, validated_data):
        validated_data['administered_by'] = self.context['request'].user
        return super().create(validated_data)