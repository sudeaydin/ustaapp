from ..models.service import Service
from .. import db

class ServiceService:
    @staticmethod
    def get_by_id(service_id):
        return Service.query.get(service_id)
    
    @staticmethod
    def create(data):
        service = Service(**data)
        db.session.add(service)
        db.session.commit()
        return service
    
    @staticmethod
    def update(service, data):
        for key, value in data.items():
            if hasattr(service, key):
                setattr(service, key, value)
        db.session.commit()
        return service