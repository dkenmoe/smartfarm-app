from rest_framework import generics, viewsets, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.filters import SearchFilter, OrderingFilter
from django_filters.rest_framework import DjangoFilterBackend
from django.contrib.auth import get_user_model
from account.models import Customer, Farm, Role, Supplier, FarmUser
from .serializers import (
    CustomerSerializer, FarmSerializer, FarmUserSerializer, SupplierSerializer,
    UserSerializer, CustomTokenObtainPairSerializer, RoleSerializer
)
from rest_framework_simplejwt.views import TokenObtainPairView
from .permissions import HasFarmAccess

# 🔐 JWT token view
class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

# 🔐 Base class for authenticated access
class BaseRoleViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]

# 🎭 Role management
class RoleViewSet(BaseRoleViewSet):
    queryset = Role.objects.all()
    serializer_class = RoleSerializer

# 👤 User management
class UserViewSet(viewsets.ModelViewSet):
    queryset = get_user_model().objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

class RegisterAPIView(generics.CreateAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.AllowAny]

class ProfileAPIView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user

class AdminDashboardAPIView(generics.ListAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return get_user_model().objects.all()

class UserListAPIView(generics.ListAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return get_user_model().objects.all()

# 🌾 Farm management
class FarmViewSet(viewsets.ModelViewSet):
    queryset = Farm.objects.all()
    serializer_class = FarmSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.is_superuser:
            return Farm.objects.all()
        return Farm.objects.filter(users=user)

# 👥 Customer management
class CustomerViewSet(viewsets.ModelViewSet):
    queryset = Customer.objects.all()
    serializer_class = CustomerSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    search_fields = ['name', 'phone', 'email', 'city']
    ordering_fields = ['name', 'created_at']

    def get_queryset(self):
        user = self.request.user
        if user.is_superuser:
            return Customer.objects.all()
        return Customer.objects.filter(farm__in=user.accessible_farms.all())

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)

# 🧾 Supplier management
class SupplierViewSet(viewsets.ModelViewSet):
    queryset = Supplier.objects.all()
    serializer_class = SupplierSerializer
    permission_classes = [IsAuthenticated]

# 👥 Farm-User link management
class FarmUserViewSet(viewsets.ModelViewSet):
    queryset = FarmUser.objects.all()
    serializer_class = FarmUserSerializer
    permission_classes = [IsAuthenticated]
    
class UserFarmListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        # Inclut les fermes possédées et celles accessibles via FarmUser
        farms_owned = Farm.objects.filter(owner=user)
        farms_accessible = Farm.objects.filter(users=user)
        farms = (farms_owned | farms_accessible).distinct()

        serializer = FarmSerializer(farms, many=True)
        return Response(serializer.data)