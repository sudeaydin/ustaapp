from ..models.message import Message
from app.extensions import db

class MessageService:
    @staticmethod
    def get_by_id(message_id):
        return Message.query.get(message_id)
    
    @staticmethod
    def create(data):
        message = Message(**data)
        db.session.add(message)
        db.session.commit()
        return message