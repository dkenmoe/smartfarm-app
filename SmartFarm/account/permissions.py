from rest_framework.permissions import BasePermission
from rest_framework import exceptions

class IsAuthenticatedAndHasRole(BasePermission):
    """
    Permission qui vérifie si l'utilisateur a un rôle spécifique.
    Peut fonctionner globalement ou dans le contexte d'une ferme.
    Utilisation : Ajoute `required_role = 'nom_du_role'` dans ta vue.
    """
    
    def has_permission(self, request, view):
        if request.user.is_superuser:
            return True
        
        if not request.user.is_authenticated:
            raise exceptions.PermissionDenied("User is not authenticated.")
        
        # Vérification du rôle global
        required_role = getattr(view, 'required_role', None)
        if required_role and not request.user.has_role(required_role):
            # Si pas de rôle global, vérifions le rôle dans la ferme
            farm_id = view.kwargs.get('farm_id') or getattr(request, 'current_farm_id', None)
            if farm_id:
                # Vérifie si l'utilisateur a le rôle requis dans cette ferme
                from ..account.models import FarmUser
                has_farm_role = FarmUser.objects.filter(
                    user=request.user,
                    farm_id=farm_id,
                    role__name=required_role
                ).exists()
                
                if not has_farm_role:
                    raise exceptions.PermissionDenied(
                        f"User does not have the required role '{required_role}' for this farm."
                    )
            else:
                raise exceptions.PermissionDenied(
                    f"User does not have the required role: {required_role}"
                )
        
        return True

class HasSpecificPermission(BasePermission):
    """
    Vérifie si l'utilisateur a une permission spécifique.
    Peut fonctionner globalement ou dans le contexte d'une ferme.
    Utilisation : Ajoute `required_permission = 'nom_de_la_permission'` dans ta vue.
    """
    
    def has_permission(self, request, view):
        if request.user.is_superuser:
            return True
            
        if not request.user.is_authenticated:
            return False
        
        required_permission = getattr(view, 'required_permission', None)
        if not required_permission:
            return True
            
        # Vérification de la permission globale
        if request.user.has_permission(required_permission):
            return True
            
        # Vérification de la permission dans le contexte d'une ferme
        farm_id = view.kwargs.get('farm_id') or getattr(request, 'current_farm_id', None)
        if farm_id:
            from ..account.models import FarmUser
            # Récupère le rôle de l'utilisateur dans cette ferme
            try:
                farm_user = FarmUser.objects.get(user=request.user, farm_id=farm_id)
                # Vérifie si le rôle a la permission requise
                if farm_user.role.permissions.filter(codename=required_permission).exists():
                    return True
            except FarmUser.DoesNotExist:
                pass
                
        return False

class HasFarmAccess(BasePermission):
    """
    Vérifie si l'utilisateur a accès à la ferme spécifiée.
    """
    def has_permission(self, request, view):
        if request.user.is_superuser:
            return True
            
        if not request.user.is_authenticated:
            return False
            
        # Récupère l'ID de la ferme depuis l'URL ou le contexte
        farm_id = view.kwargs.get('farm_id') or getattr(request, 'current_farm_id', None)
        if not farm_id:
            # Si pas de ferme spécifiée, on autorise (filtrage fait dans get_queryset)
            return True
            
        # Vérifie si l'utilisateur a accès à cette ferme
        from ..account.models import FarmUser
        return FarmUser.objects.filter(
            user=request.user,
            farm_id=farm_id
        ).exists()