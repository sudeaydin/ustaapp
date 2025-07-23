from marshmallow import Schema, fields, validate
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema
from ..models.service import Service

class ServiceSchema(SQLAlchemyAutoSchema):
    class Meta:
        model = Service
        load_instance = True
        include_relationships = True
    
    craftsman = fields.Nested('CraftsmanSchema', dump_only=True, exclude=('services',))
    category = fields.Nested('CategorySchema', dump_only=True)

class ServiceCreateSchema(Schema):
    title = fields.Str(required=True, validate=validate.Length(min=5, max=200))
    description = fields.Str(required=True, validate=validate.Length(min=20, max=1000))
    price = fields.Decimal(places=2, required=True, validate=validate.Range(min=0))
    category_id = fields.Int(required=True)
    duration_hours = fields.Int(validate=validate.Range(min=1))
    is_available = fields.Bool()

class ServiceUpdateSchema(Schema):
    title = fields.Str(validate=validate.Length(min=5, max=200))
    description = fields.Str(validate=validate.Length(min=20, max=1000))
    price = fields.Decimal(places=2, validate=validate.Range(min=0))
    category_id = fields.Int()
    duration_hours = fields.Int(validate=validate.Range(min=1))
    is_available = fields.Bool()