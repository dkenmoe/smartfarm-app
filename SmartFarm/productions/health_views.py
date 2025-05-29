from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from productions.health_models import HealthIssue, HealthRecord, MedicationType, Treatment
from productions.health_serializers import HealthIssueSerializer, HealthRecordSerializer, MedicationTypeSerializer, TreatmentSerializer


class HealthIssueViewSet(viewsets.ModelViewSet):
    queryset = HealthIssue.objects.all()
    serializer_class = HealthIssueSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return HealthIssue.objects.filter(farm=self.request.user.farm)


class MedicationTypeViewSet(viewsets.ModelViewSet):
    queryset = MedicationType.objects.all()
    serializer_class = MedicationTypeSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return MedicationType.objects.filter(farm=self.request.user.farm)


class HealthIssueViewSet(viewsets.ModelViewSet):
    queryset = HealthIssue.objects.all()  # ✅ Required for DRF router introspection
    serializer_class = HealthIssueSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return HealthIssue.objects.filter(farm=self.request.user.farm)

class TreatmentViewSet(viewsets.ModelViewSet):
    queryset = Treatment.objects.all()
    serializer_class = TreatmentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Treatment.objects.filter(health_record__animal__farm=self.request.user.farm)
    
class HealthRecordViewSet(viewsets.ModelViewSet):
    queryset = HealthRecord.objects.all()  # ✅ REQUIRED
    serializer_class = HealthRecordSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return HealthRecord.objects.filter(farm=self.request.user.farm)