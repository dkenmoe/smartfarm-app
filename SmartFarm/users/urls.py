from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from .views import CustomTokenObtainPairView, RegisterAPIView, RoleViewSet, CityViewSet, AdminDashboardAPIView, UserListAPIView, CountryViewSet, AddressViewSet, UserViewSet


# Création d'un routeur DRF pour les ViewSets
router = DefaultRouter()
router.register(r'roles', RoleViewSet)
router.register(r'countries', CountryViewSet)
router.register(r'cities', CityViewSet)
router.register(r'addresses', AddressViewSet)
router.register(r'users', UserViewSet)

urlpatterns = [
    path('login/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('register/', RegisterAPIView.as_view(), name='register'),
    path('', include(router.urls)),
    path('api/admin-dashboard/', AdminDashboardAPIView.as_view(), name='api-admin-dashboard'),
    path('api/users/', UserListAPIView.as_view(), name='api-users'),
    
    # Inclusion des routes générées par le routeur
    path('api/', include(router.urls)),
]