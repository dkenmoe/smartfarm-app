from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from users.permissions import HasRolePermission

class SalesReportView(APIView):
    permission_classes = [IsAuthenticated, HasRolePermission]
    required_role = "Sales Manager"  # Only Sales Managers can access

    def get(self, request):
        return Response({"message": "Sales Report Data"})
