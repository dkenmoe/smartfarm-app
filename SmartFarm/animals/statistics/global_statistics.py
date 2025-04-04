from animals.statistics.production_overview import get_production_overview
from animals.statistics.production_by_type import get_production_by_type
from animals.statistics.inventory_details import get_inventory_details

def get_global_statistics(filters=None):
    overview = get_production_overview()
    production_by_type = get_production_by_type(filters)
    inventory = get_inventory_details(filters)
    
    return {
        'overview': overview,
        'production_by_type': production_by_type,
        'inventory': inventory,
    }
