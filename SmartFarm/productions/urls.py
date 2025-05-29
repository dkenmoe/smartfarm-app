from django.urls import path, include
from rest_framework.routers import DefaultRouter

from productions.feed_views import FeedInventoryViewSet, FeedTypeViewSet, FeedingRecordViewSet
from productions.health_views import HealthIssueViewSet, HealthRecordViewSet, MedicationTypeViewSet, TreatmentViewSet
from .views import (
    AcquisitionRecordViewSet, AnimalInventoryViewSet, AnimalTypeViewSet, AnimalBreedViewSet, AnimalViewSet, DiedRecordViewSet, WeightCategoryViewSet,
    BirthRecordViewSet
)

router = DefaultRouter()
router.register(r'animal-types', AnimalTypeViewSet)
router.register(r'animal-breeds', AnimalBreedViewSet, basename='animal-breeds')
router.register(r'weight-categories', WeightCategoryViewSet)
router.register(r'birth-records', BirthRecordViewSet, basename='birth-record')
router.register(r'died-records', DiedRecordViewSet, basename='died-record')
router.register(r'acquisition_records', AcquisitionRecordViewSet, basename='acquisition-record')
router.register(r'animal-inventories', AnimalInventoryViewSet, basename='animal-inventory')

router.register(r'health-issues', HealthIssueViewSet)
router.register(r'medication-types', MedicationTypeViewSet)
router.register(r'health-records', HealthRecordViewSet)
router.register(r'treatments', TreatmentViewSet, basename='treatment')

router.register(r'feed-types', FeedTypeViewSet)
router.register(r'feed-inventory', FeedInventoryViewSet)
router.register(r'feeding-records', FeedingRecordViewSet)
router.register(r'animals', AnimalViewSet, basename='animal')

# Farm-specific endpoints with explicit farm_id in URL
farm_router = DefaultRouter()
farm_router.register(r'birth-records', BirthRecordViewSet, basename='farm-birth-record')
farm_router.register(r'acquisition-records', AcquisitionRecordViewSet, basename='farm-acquisition-record')
farm_router.register(r'animal-inventories', AnimalInventoryViewSet, basename='farm-animal-inventory')
farm_router.register(r'died-records', DiedRecordViewSet, basename='farm-died-record')


urlpatterns = [
    path('', include(router.urls)),
        # Farm-specific endpoints
    path('farms/<int:farm_id>/', include(farm_router.urls)),
]
