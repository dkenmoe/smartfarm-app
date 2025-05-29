from rest_framework import viewsets

from rest_framework.permissions import IsAuthenticated
from productions.feed_models import FeedType, FeedInventory, FeedingRecord
from productions.feed_serializers import FeedInventorySerializer, FeedTypeSerializer, FeedingRecordSerializer

class FeedTypeViewSet(viewsets.ModelViewSet):
    queryset = FeedType.objects.all()
    serializer_class = FeedTypeSerializer
    permission_classes = [IsAuthenticated]


class FeedInventoryViewSet(viewsets.ModelViewSet):
    queryset = FeedInventory.objects.all()
    serializer_class = FeedInventorySerializer
    permission_classes = [IsAuthenticated]

class FeedingRecordViewSet(viewsets.ModelViewSet):
    queryset = FeedingRecord.objects.all()
    serializer_class = FeedingRecordSerializer
    permission_classes = [IsAuthenticated]
