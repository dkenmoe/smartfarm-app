from datetime import date, timedelta
from django.db.models import Sum, Count, Q
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.http import HttpResponse
import csv
from io import BytesIO
from reportlab.pdfgen import canvas

from reports.services.dashboard_service import DashboardService

class DashboardMetricsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        user = request.user
        current_farm = getattr(request, 'current_farm', None)
        start_date = request.query_params.get('start_date')
        end_date = request.query_params.get('end_date')
        period = request.query_params.get('period')  # week, month, year
        animal_type_id = request.query_params.get('animal_type_id')

        if not start_date or not end_date:
            today = date.today()
            if period == 'week':
                start_date = today - timedelta(days=today.weekday())
                end_date = today
            elif period == 'month':
                start_date = today.replace(day=1)
                end_date = today
            elif period == 'year':
                start_date = today.replace(month=1, day=1)
                end_date = today
            else:
                start_date = end_date = today

        export_format = request.query_params.get('export')
        if export_format == 'csv':
            return self.export_csv(current_farm, start_date, end_date, animal_type_id)
        elif export_format == 'pdf':
            return self.export_pdf(current_farm, start_date, end_date, animal_type_id)

        metrics = DashboardService.get_metrics(
            farm=current_farm,
            start_date=start_date,
            end_date=end_date,
            animal_type_id=animal_type_id
        )
        return Response(metrics)

    def export_csv(self, farm, start_date, end_date, animal_type_id):
        metrics = DashboardService.get_metrics(
            farm=farm,
            start_date=start_date,
            end_date=end_date,
            animal_type_id=animal_type_id
        )

        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename="dashboard_metrics.csv"'

        writer = csv.writer(response)
        writer.writerow(['Metric', 'Value'])
        for key, value in metrics.items():
            writer.writerow([key.replace('_', ' ').capitalize(), value])

        return response

    def export_pdf(self, farm, start_date, end_date, animal_type_id):
        metrics = DashboardService.get_metrics(
            farm=farm,
            start_date=start_date,
            end_date=end_date,
            animal_type_id=animal_type_id
        )

        buffer = BytesIO()
        p = canvas.Canvas(buffer)
        p.setFont("Helvetica-Bold", 14)
        p.drawString(100, 800, "Smart Farm Dashboard Metrics")
        p.setFont("Helvetica", 12)

        y = 760
        for key, value in metrics.items():
            p.drawString(100, y, f"{key.replace('_', ' ').capitalize()}: {value}")
            y -= 20

        p.showPage()
        p.save()

        buffer.seek(0)
        response = HttpResponse(buffer, content_type='application/pdf')
        response['Content-Disposition'] = 'attachment; filename="dashboard_metrics.pdf"'
        return response
