from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    ExpenseViewSet,
    ExpenseCategoryViewSet,
    SupplierViewSet,
    PaymentMethodViewSet,
)

router = DefaultRouter()
router.register(r'expenses', ExpenseViewSet)
router.register(r'categories', ExpenseCategoryViewSet)
router.register(r'suppliers', SupplierViewSet)
router.register(r'payment-methods', PaymentMethodViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
