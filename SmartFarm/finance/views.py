from rest_framework import viewsets, permissions
from rest_framework.permissions import IsAuthenticated
from .models import Expense, ExpenseCategory, PaymentMethod
from .serializers import (
    ExpenseSerializer,
    ExpenseCategorySerializer,
    PaymentMethodSerializer
)

class IsManagerOrReadOnly(permissions.BasePermission):
    """
    Seul le manager général peut modifier.
    """
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user.groups.filter(name='ManagerGeneral').exists()

class ExpenseCategoryViewSet(viewsets.ModelViewSet):
    queryset = ExpenseCategory.objects.all()
    serializer_class = ExpenseCategorySerializer
    permission_classes = [IsAuthenticated]


class PaymentMethodViewSet(viewsets.ModelViewSet):
    queryset = PaymentMethod.objects.all()
    serializer_class = PaymentMethodSerializer
    permission_classes = [IsAuthenticated]


class ExpenseViewSet(viewsets.ModelViewSet):
    queryset = Expense.objects.all()
    serializer_class = ExpenseSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        current_farm = getattr(self.request, 'current_farm', None)
        if user.is_superuser:
            return self.queryset
        if current_farm:
            return self.queryset.filter(farm=current_farm)
        return self.queryset.none()

    def perform_create(self, serializer):
        request = self.request
        current_farm = getattr(request, 'current_farm', None)
        if current_farm:
            serializer.save(created_by=request.user, farm=current_farm)
        else:
            serializer.save(created_by=request.user)