from marshmallow import Schema, fields, validate
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema
from ..models.category import Category

class CategorySchema(SQLAlchemyAutoSchema):
    class Meta:
        model = Category
        load_instance = True
    
    craftsmen_count = fields.Int(dump_only=True)

class CategoryCreateSchema(Schema):
    name = fields.Str(required=True, validate=validate.Length(min=2, max=100))
    description = fields.Str(validate=validate.Length(max=500))
    icon = fields.Str(validate=validate.Length(max=50))