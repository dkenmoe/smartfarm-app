from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from .views import CustomTokenObtainPairView, CustomerViewSet, FarmViewSet, RegisterAPIView, RoleViewSet, AdminDashboardAPIView, SupplierViewSet, UserFarmListView, UserListAPIView, UserViewSet


# Création d'un routeur DRF pour les ViewSets
router = DefaultRouter()
router.register(r'roles', RoleViewSet)
router.register(r'users', UserViewSet)
router.register(r'customers', CustomerViewSet)
router.register(r'suppliers', SupplierViewSet)
router.register(r'farms', FarmViewSet)

urlpatterns = [
    path('login/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('register/', RegisterAPIView.as_view(), name='register'),
    path('', include(router.urls)),
    path('api/admin-dashboard/', AdminDashboardAPIView.as_view(), name='api-admin-dashboard'),
    path('api/users/', UserListAPIView.as_view(), name='api-users'),
     path('user-farms/', UserFarmListView.as_view(), name='api-user-farms'),
    
    # Inclusion des routes générées par le routeur
    path('api/', include(router.urls)),
]