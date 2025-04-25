import os
from django.core.exceptions import ValidationError

def validate_attachment_extension(value):
    ext = os.path.splitext(value.name)[1]
    valid_extensions = ['.jpg', '.jpeg', '.png', '.pdf']
    if not ext.lower() in valid_extensions:
        raise ValidationError(
            f'Extension de fichier non supportée ({ext}). Autorisées : {", ".join(valid_extensions)}'
        )

def validate_file_size(value):
    max_size = 5 * 1024 * 1024  # 5MB
    if value.size > max_size:
        raise ValidationError('Fichier trop volumineux (max 5MB).')
