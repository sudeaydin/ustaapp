from marshmallow import Schema, fields, validate
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema
from ..models.customer import Customer

class CustomerSchema(SQLAlchemyAutoSchema):
    class Meta:
        model = Customer
        load_instance = True
        include_relationships = True
    
    user = fields.Nested('UserSchema', dump_only=True)

class CustomerRegistrationSchema(Schema):
    # User fields
    email = fields.Email(required=True)
    password = fields.Str(required=True, validate=validate.Length(min=6))
    confirm_password = fields.Str(required=True)
    first_name = fields.Str(required=True, validate=validate.Length(min=2))
    last_name = fields.Str(required=True, validate=validate.Length(min=2))
    phone = fields.Str(required=True, validate=validate.Length(min=10))

class CustomerUpdateSchema(Schema):
    address = fields.Str(validate=validate.Length(min=10))
    city = fields.Str(validate=validate.Length(min=2))
    district = fields.Str(validate=validate.Length(min=2))