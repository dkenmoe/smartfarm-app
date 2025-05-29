from datetime import date, timedelta
from django.conf import settings
from django.contrib.auth import get_user_model
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404

from finance.sales_models import Sale
from productions.models import Animal
from finance.models import Expense
from productions.models import BirthRecord, DiedRecord

class UserActivityReportView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user_id = request.query_params.get("user_id")
        period = request.query_params.get("period", "month")  # default to month

        user = get_object_or_404(settings.AUTH_USER_MODEL, id=user_id)
        today = date.today()

        if period == "week":
            start_date = today - timedelta(days=today.weekday())
        elif period == "year":
            start_date = today.replace(month=1, day=1)
        else:  # default to month
            start_date = today.replace(day=1)

        date_filter = {"created_at__gte": start_date}

        report = {
            "user": user.username,
            "animals_created": Animal.objects.filter(created_by=user, **date_filter).count(),
            "sales_recorded": Sale.objects.filter(created_by=user, **date_filter).count(),
            "expenses_logged": Expense.objects.filter(created_by=user, **date_filter).count(),
            "birth_records": BirthRecord.objects.filter(created_by=user, **date_filter).count(),
            "death_records": DiedRecord.objects.filter(created_by=user, **date_filter).count(),
            "last_login": user.last_login
        }

        return Response(report)
