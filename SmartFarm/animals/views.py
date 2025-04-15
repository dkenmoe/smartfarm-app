from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import (
    AnimalInventory, AnimalType, AnimalBreed, AnimalGroup, WeightCategory,
    BirthRecord, HealthRecord, FeedingRecord
)
from .serializers import (
    AcquisitionRecordSerializer, AnimalInventorySerializer, AnimalTypeSerializer, AnimalBreedSerializer, AnimalGroupSerializer, WeightCategorySerializer,
    BirthRecordSerializer, HealthRecordSerializer, FeedingRecordSerializer
)
from users.permissions import IsAuthenticatedAndHasRole

class AnimalTypeViewSet(viewsets.ModelViewSet):
    queryset = AnimalType.objects.all()
    serializer_class = AnimalTypeSerializer
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAuthenticatedAndHasRole()]
        return [IsAuthenticated()]      
    required_role = 'production_manager'
    
    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user) 

class AnimalBreedViewSet(viewsets.ModelViewSet):
    queryset = AnimalBreed.objects.all()  # Keep this for the router
    serializer_class = AnimalBreedSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """
        Custom queryset that filters breeds by animal_type if that parameter exists
        """
        queryset = super().get_queryset()  # Start with the class-level queryset
                
        # Get animal_type from query parameters
        animal_type_id = self.request.query_params.get('animal_type')
        
        # Apply filter if animal_type was provided
        if animal_type_id:
            queryset = queryset.filter(animal_type_id=animal_type_id)
            
        return queryset

class AnimalGroupViewSet(viewsets.ModelViewSet):
    queryset = AnimalGroup.objects.all()
    serializer_class = AnimalGroupSerializer
    permission_classes = [IsAuthenticated]

class WeightCategoryViewSet(viewsets.ModelViewSet):
    queryset = WeightCategory.objects.all()
    serializer_class = WeightCategorySerializer
    permission_classes = [IsAuthenticated]

class BirthRecordViewSet(viewsets.ModelViewSet):
    queryset = BirthRecord.objects.all()
    serializer_class = BirthRecordSerializer
    permission_classes = [IsAuthenticated]

class AcquisitionRecordViewSet(viewsets.ModelViewSet):
    queryset = BirthRecord.objects.all()
    serializer_class = AcquisitionRecordSerializer
    permission_classes = [IsAuthenticated]

class AnimalInventoryViewSet(viewsets.ModelViewSet):
    queryset = AnimalInventory.objects.all()
    serializer_class = AnimalInventorySerializer
    permission_classes = [IsAuthenticated]

class HealthRecordViewSet(viewsets.ModelViewSet):
    queryset = HealthRecord.objects.all()
    serializer_class = HealthRecordSerializer
    permission_classes = [IsAuthenticated]

class FeedingRecordViewSet(viewsets.ModelViewSet):
    queryset = FeedingRecord.objects.all()
    serializer_class = FeedingRecordSerializer
    permission_classes = [IsAuthenticated]
