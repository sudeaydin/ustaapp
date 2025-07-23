from marshmallow import Schema, fields, validate
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema
from ..models.user import User

class UserSchema(SQLAlchemyAutoSchema):
    class Meta:
        model = User
        load_instance = True
        exclude = ('password_hash',)
    
    password = fields.Str(load_only=True, required=True, validate=validate.Length(min=6))
    confirm_password = fields.Str(load_only=True)

class UserLoginSchema(Schema):
    email = fields.Email(required=True)
    password = fields.Str(required=True, validate=validate.Length(min=6))

class UserRegistrationSchema(Schema):
    email = fields.Email(required=True)
    password = fields.Str(required=True, validate=validate.Length(min=6))
    confirm_password = fields.Str(required=True)
    first_name = fields.Str(required=True, validate=validate.Length(min=2))
    last_name = fields.Str(required=True, validate=validate.Length(min=2))
    phone = fields.Str(required=True, validate=validate.Length(min=10))
    user_type = fields.Str(required=True, validate=validate.OneOf(['customer', 'craftsman']))