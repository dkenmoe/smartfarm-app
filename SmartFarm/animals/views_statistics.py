from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from animals.statistics.global_statistics import get_global_statistics

class GlobalStatisticsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, format=None):
        # Optional filters can be passed as query parameters
        filters = {}
        animal_type = request.query_params.get('animal_type')
        breed = request.query_params.get('breed')
        weight_category = request.query_params.get('weight_category')
        gender = request.query_params.get('gender')
        
        if animal_type:
            filters['animal_type_id'] = animal_type
        if breed:
            filters['breed_id'] = breed
        if weight_category:
            filters['weight_category_id'] = weight_category
        if gender:
            filters['gender'] = gender
        
        stats = get_global_statistics(filters)
        return Response(stats)
