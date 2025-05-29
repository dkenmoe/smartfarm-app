from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated

from productions.filters import AcquisitionRecordFilter, AnimalInventoryFilter, BirthRecordFilter, DiedRecordFilter
from productions.models import (
    AcquisitionRecord, Animal, AnimalInventory, AnimalType, AnimalBreed,DiedRecord, WeightCategory,
    BirthRecord
)
from .serializers import (
    AcquisitionRecordSerializer, AnimalInventorySerializer, AnimalSerializer, AnimalTypeSerializer, AnimalBreedSerializer, DiedRecordSerializer, WeightCategorySerializer,
    BirthRecordSerializer
)
from account.permissions import IsAuthenticatedAndHasRole
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import filters

class AnimalTypeViewSet(viewsets.ModelViewSet):
    queryset = AnimalType.objects.all()
    serializer_class = AnimalTypeSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name', 'description']
    ordering_fields = ['name']
    filterset_fields = ['name']
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAuthenticatedAndHasRole()]
        return [IsAuthenticated()]
    required_role = 'production_manager'
    
    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)

class AnimalBreedViewSet(viewsets.ModelViewSet):
    queryset = AnimalBreed.objects.all()
    serializer_class = AnimalBreedSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name', 'description', 'animal_type__name']
    ordering_fields = ['name', 'animal_type__name']
    filterset_fields = ['animal_type', 'name']
    
    def get_queryset(self):
        queryset = super().get_queryset()
                      
        animal_type_id = self.request.query_params.get('animal_type')
        if animal_type_id:
            queryset = queryset.filter(animal_type_id=animal_type_id)
        
        name_query = self.request.query_params.get('name')
        if name_query:
            queryset = queryset.filter(name__icontains=name_query)
            
        return queryset.select_related('animal_type', 'created_by').order_by('animal_type__name', 'name')

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)

class WeightCategoryViewSet(viewsets.ModelViewSet):
    queryset = WeightCategory.objects.all()
    serializer_class = WeightCategorySerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    ordering_fields = ['min_weight', 'max_weight']
    filterset_fields = ['min_weight', 'max_weight']

class BirthRecordViewSet(viewsets.ModelViewSet):
    queryset = BirthRecord.objects.all()
    serializer_class = BirthRecordSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_class = BirthRecordFilter
    search_fields = ['notes', 'animal_type__name', 'breed__name']
    ordering_fields = ['date_of_birth', 'animal_type__name', 'breed__name', 'number_of_male', 'number_of_female']
    permission_classes = [IsAuthenticated]

class AcquisitionRecordViewSet(viewsets.ModelViewSet):
    queryset = AcquisitionRecord.objects.all()
    serializer_class = AcquisitionRecordSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_class = AcquisitionRecordFilter
    search_fields = ['notes', 'vendor', 'receipt_number']
    ordering_fields = ['date_of_acquisition', 'animal_type__name', 'breed__name', 'quantity']
    permission_classes = [IsAuthenticated]
    
class DiedRecordViewSet(viewsets.ModelViewSet):
    queryset = DiedRecord.objects.all()
    serializer_class = DiedRecordSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_class = DiedRecordFilter
    search_fields = ['notes', 'cause', 'animal_type__name', 'breed__name']
    ordering_fields = ['date_of_death', 'animal_type__name', 'breed__name', 'quantity']
    permission_classes = [IsAuthenticated]

class AnimalInventoryViewSet(viewsets.ModelViewSet):
    queryset = AnimalInventory.objects.all()
    serializer_class = AnimalInventorySerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_class = AnimalInventoryFilter
    search_fields = ['animal_type__name', 'breed__name']
    ordering_fields = ['animal_type__name', 'breed__name', 'quantity']
    permission_classes = [IsAuthenticated]
    
class AnimalViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = AnimalSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['farm', 'animal_type', 'breed', 'status']
    search_fields = ['tracking_id']
    ordering_fields = ['tracking_id', 'date_of_birth', 'current_weight']
    ordering = ['id']

    def get_queryset(self):
        # Précharger relations pour éviter les N+1
        return Animal.objects.select_related(
            'animal_type', 'breed', 'farm'
        ).all().order_by('id')  # ⚠️ ordre nécessaire pour éviter UnorderedObjectListWarning