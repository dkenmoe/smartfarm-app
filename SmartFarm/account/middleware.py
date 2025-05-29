from account.models import Farm


class FarmContextMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        request.current_farm = None
        request.current_farm_id = None

        if request.user.is_authenticated:
            farm_id = request.session.get('current_farm_id')

            farm = (
                Farm.objects.filter(id=farm_id, farmuser__user=request.user).first()
                if farm_id else None
            )

            # Fallback to first accessible farm if session is invalid or missing
            if not farm:
                farm_user = request.user.farmuser_set.select_related('farm').first()
                if farm_user:
                    farm = farm_user.farm
                    request.session['current_farm_id'] = farm.id

            if farm:
                request.current_farm = farm
                request.current_farm_id = farm.id

        return self.get_response(request)
