from rest_framework.permissions import BasePermission
from rest_framework import exceptions

class IsAuthenticatedAndHasRole(BasePermission):
    """
    Permission qui vérifie si l'utilisateur a un rôle spécifique.
    Utilisation : Ajoute `required_role = 'nom_du_role'` dans ta vue.
    """
    
    def has_permission(self, request, view):
        if(request.user.is_superuser):
            return True
        
        required_role = getattr(view, 'required_role', None)
        
        if not request.user.is_authenticated:
            raise exceptions.PermissionDenied("User is not authenticated.")
        
        if required_role and not request.user.has_role(required_role):
             raise exceptions.PermissionDenied(f"User does not have the required role: {required_role}")
        
        return True

class HasSpecificPermission(BasePermission):
    """
    Vérifie si l'utilisateur a une permission spécifique.
    Utilisation : Ajoute `required_permission = 'nom_de_la_permission'` dans ta vue.
    """
    
    def has_permission(self, request, view):
        required_permission = getattr(view, 'required_permission', None)

        if not request.user.is_authenticated:
            return False  # L'utilisateur doit être connecté

        if required_permission and not request.user.has_permission(required_permission):
            return False  # L'utilisateur ne possède pas la permission requise

        return True