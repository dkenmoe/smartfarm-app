from django.urls import path, include
from rest_framework.routers import DefaultRouter

from finance.sales_views import SaleItemViewSet, SaleViewSet
from .views import (
    ExpenseViewSet,
    ExpenseCategoryViewSet,
    PaymentMethodViewSet
)

router = DefaultRouter()
router.register(r'expenses', ExpenseViewSet)
router.register(r'categories', ExpenseCategoryViewSet)
router.register(r'payment-methods', PaymentMethodViewSet)
router.register(r'sales', SaleViewSet)
router.register(r'sale-items', SaleItemViewSet)

# Farm-specific endpoints with explicit farm_id in URL
farm_router = DefaultRouter()
farm_router.register(r'expenses', ExpenseViewSet, basename='farm-expense')

urlpatterns = [
    path('', include(router.urls)),
    path('farms/<int:farm_id>/', include(farm_router.urls)),
]
