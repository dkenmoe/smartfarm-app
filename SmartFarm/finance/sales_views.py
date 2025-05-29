from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated

from finance.sales_models import Sale, SaleItem
from finance.sales_serializers import SaleItemSerializer, SaleSerializer

class SaleViewSet(viewsets.ModelViewSet):
    queryset = Sale.objects.all().prefetch_related('items')
    serializer_class = SaleSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.is_superuser:
            return self.queryset
        current_farm = getattr(self.request, 'current_farm', None)
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


class SaleItemViewSet(viewsets.ModelViewSet):
    queryset = SaleItem.objects.all()
    serializer_class = SaleItemSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        return self.queryset if user.is_superuser else self.queryset.filter(sale__created_by=user)