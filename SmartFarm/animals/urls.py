from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    AcquisitionRecordViewSet, AnimalInventoryViewSet, AnimalTypeViewSet, AnimalBreedViewSet, AnimalGroupViewSet, DiedRecordViewSet, WeightCategoryViewSet,
    BirthRecordViewSet, HealthRecordViewSet, FeedingRecordViewSet
)
from .views_statistics import GlobalStatisticsView

router = DefaultRouter()
router.register(r'animal-types', AnimalTypeViewSet)
router.register(r'animal-breeds', AnimalBreedViewSet)
router.register(r'animal-groups', AnimalGroupViewSet)
router.register(r'weight-categories', WeightCategoryViewSet)
router.register(r'birth-records', BirthRecordViewSet, basename='birth')
router.register(r'died-records', DiedRecordViewSet)
router.register(r'acquisition_records', AcquisitionRecordViewSet, basename='acquisition')
router.register(r'health-records', HealthRecordViewSet)
router.register(r'feeding-records', FeedingRecordViewSet)
router.register(r'animal-inventories', AnimalInventoryViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('statistics/global/', GlobalStatisticsView.as_view(), name='global_statistics'),
]
