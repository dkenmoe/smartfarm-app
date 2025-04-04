from rest_framework import generics, viewsets, permissions
from rest_framework.permissions import IsAuthenticated
from .permissions import IsAuthenticatedAndHasRole
from rest_framework_simplejwt.views import TokenObtainPairView
from .serializers import UserSerializer, CustomTokenObtainPairSerializer
from django.contrib.auth import get_user_model
from .models import Role, Country, City, Address
from .serializers import RoleSerializer, CountrySerializer, CitySerializer, AddressSerializer

# Custom Login View (Overrides JWT Token View)
class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer
    
class BaseRoleViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticatedAndHasRole]

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAuthenticatedAndHasRole()]
        return [IsAuthenticated]

# User Registration View
class RoleViewSet(BaseRoleViewSet):
    queryset = Role.objects.all()
    serializer_class = RoleSerializer
    required_role = 'admin'

class CountryViewSet(BaseRoleViewSet):
    queryset = Country.objects.all()
    serializer_class = CountrySerializer
    required_role = 'admin'

class CityViewSet(BaseRoleViewSet):
    queryset = City.objects.all()
    serializer_class = CitySerializer
    required_role = 'admin'

class AddressViewSet(BaseRoleViewSet):
    queryset = Address.objects.all()
    serializer_class = AddressSerializer
    required_role = 'admin'

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
