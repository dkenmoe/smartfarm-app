from rest_framework import serializers

from productions.feed_models import FeedInventory, FeedType, FeedingRecord

class FeedTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = FeedType
        fields = '__all__'


class FeedInventorySerializer(serializers.ModelSerializer):
    is_expired = serializers.ReadOnlyField()

    class Meta:
        model = FeedInventory
        fields = '__all__'


class FeedingRecordSerializer(serializers.ModelSerializer):
    estimated_cost = serializers.ReadOnlyField()

    class Meta:
        model = FeedingRecord
        fields = '__all__'
