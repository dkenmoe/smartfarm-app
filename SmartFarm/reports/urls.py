from django.urls import path

from reports.views.alerts import AlertViewSet
from reports.views.dashboard import DashboardMetricsView
from reports.views.user_activity import UserActivityReportView
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register(r'alerts', AlertViewSet, basename='alert')

urlpatterns = [
    path('dashboard-metrics/', DashboardMetricsView.as_view(), name='dashboard-metrics'),
    path('user-activity/', UserActivityReportView.as_view(), name='user-activity-report'),
]+ router.urls