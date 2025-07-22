from marshmallow import Schema, fields, validate
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema
from ..models.craftsman import Craftsman

class CraftsmanSchema(SQLAlchemyAutoSchema):
    class Meta:
        model = Craftsman
        load_instance = True
        include_relationships = True
    
    user = fields.Nested('UserSchema', dump_only=True)
    categories = fields.Nested('CategorySchema', many=True, dump_only=True)
    services = fields.Nested('ServiceSchema', many=True, dump_only=True)
    reviews = fields.Nested('ReviewSchema', many=True, dump_only=True)

class CraftsmanRegistrationSchema(Schema):
    # User fields
    email = fields.Email(required=True)
    password = fields.Str(required=True, validate=validate.Length(min=6))
    confirm_password = fields.Str(required=True)
    first_name = fields.Str(required=True, validate=validate.Length(min=2))
    last_name = fields.Str(required=True, validate=validate.Length(min=2))
    phone = fields.Str(required=True, validate=validate.Length(min=10))
    
    # Craftsman fields
    business_name = fields.Str(required=True, validate=validate.Length(min=2))
    description = fields.Str(required=True, validate=validate.Length(min=10))
    address = fields.Str(required=True, validate=validate.Length(min=10))
    city = fields.Str(required=True, validate=validate.Length(min=2))
    district = fields.Str(required=True, validate=validate.Length(min=2))
    category_ids = fields.List(fields.Int(), required=True, validate=validate.Length(min=1))

class CraftsmanUpdateSchema(Schema):
    business_name = fields.Str(validate=validate.Length(min=2))
    description = fields.Str(validate=validate.Length(min=10))
    address = fields.Str(validate=validate.Length(min=10))
    city = fields.Str(validate=validate.Length(min=2))
    district = fields.Str(validate=validate.Length(min=2))
    hourly_rate = fields.Decimal(places=2, validate=validate.Range(min=0))
    is_available = fields.Bool()
    category_ids = fields.List(fields.Int())