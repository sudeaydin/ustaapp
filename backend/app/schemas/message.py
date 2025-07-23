from marshmallow import Schema, fields, validate
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema
from ..models.message import Message

class MessageSchema(SQLAlchemyAutoSchema):
    class Meta:
        model = Message
        load_instance = True
        include_relationships = True
    
    sender = fields.Nested('UserSchema', dump_only=True)
    receiver = fields.Nested('UserSchema', dump_only=True)
    quote = fields.Nested('QuoteSchema', dump_only=True, exclude=('messages',))

class MessageCreateSchema(Schema):
    receiver_id = fields.Int(required=True)
    quote_id = fields.Int()
    content = fields.Str(required=True, validate=validate.Length(min=1, max=1000))
    message_type = fields.Str(validate=validate.OneOf(['text', 'image', 'file']))

class ConversationSchema(Schema):
    user_id = fields.Int(dump_only=True)
    user_name = fields.Str(dump_only=True)
    user_avatar = fields.Str(dump_only=True)
    last_message = fields.Str(dump_only=True)
    last_message_time = fields.DateTime(dump_only=True)
    unread_count = fields.Int(dump_only=True)