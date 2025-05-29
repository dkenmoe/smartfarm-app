from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth import get_user_model
from account.models import Farm, FarmUser, Role, Customer, Supplier

# 🔐 Token avec rôles, fermes et permissions
class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)

        token['username'] = user.username
        token['email'] = user.email
        token['roles'] = list(user.roles.values_list('name', flat=True))

        farms_info = []
        farm_users = FarmUser.objects.filter(user=user).prefetch_related('roles', 'farm')
        for fu in farm_users:
            farms_info.append({
                'id': fu.farm.id,
                'name': fu.farm.name,
                'roles': list(fu.roles.values_list('name', flat=True))
            })
        token['farms'] = farms_info

        all_perms = set(user.user_permissions.values_list('codename', flat=True))
        for role in user.roles.all():
            all_perms.update(role.permissions.values_list('codename', flat=True))
        for group in user.groups.all():
            all_perms.update(group.permissions.values_list('codename', flat=True))

        token['permissions'] = list(all_perms)
        return token

# 🎭 Rôles
class RoleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Role
        fields = '__all__'

# 👤 Utilisateur
class UserSerializer(serializers.ModelSerializer):
    roles = RoleSerializer(many=True, read_only=True)

    class Meta:
        model = get_user_model()
        fields = (
            'id', 'username', 'email', 'phone_number', 'profile_picture',
            'street', 'street2', 'city', 'postal_code', 'country_name', 'country_code',
            'roles'
        )

# 🌾 Ferme
class FarmSerializer(serializers.ModelSerializer):
    class Meta:
        model = Farm
        fields = (
            'id', 'name', 'street', 'street2', 'city', 'postal_code', 'country_name', 'country_code',
            'size_hectares', 'owner', 'is_active', 'created_at', 'updated_at'
        )

# 👥 Client
class CustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Customer
        fields = [
            'id', 'name', 'phone', 'email',
            'street', 'street2', 'city', 'postal_code', 'country_name', 'country_code',
            'created_at', 'created_by', 'farm'
        ]
        read_only_fields = ['created_at', 'created_by']

# 🧾 Fournisseur
class SupplierSerializer(serializers.ModelSerializer):
    farms = serializers.PrimaryKeyRelatedField(many=True, queryset=Farm.objects.all())

    class Meta:
        model = Supplier
        fields = [
            'id', 'name', 'contact_person', 'email', 'phone',
            'street', 'street2', 'city', 'postal_code', 'country_name', 'country_code',
            'farms', 'notes', 'is_active'
        ]

# 👤 Utilisateur lié à une ferme
class FarmUserSerializer(serializers.ModelSerializer):
    user_details = UserSerializer(source='user', read_only=True)
    roles = RoleSerializer(many=True, read_only=True)

    class Meta:
        model = FarmUser
        fields = ('id', 'farm', 'user', 'roles', 'date_joined', 'user_details')
