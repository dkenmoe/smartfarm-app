from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from reports.models import Alert
from reports.serializers import AlertSerializer

class AlertViewSet(viewsets.ModelViewSet):
    serializer_class = AlertSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        current_farm = getattr(self.request, 'current_farm', None)
        queryset = Alert.objects.all()
        if not user.is_superuser and current_farm:
            queryset = queryset.filter(farm=current_farm)
        return queryset