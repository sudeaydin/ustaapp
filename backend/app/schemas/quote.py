from marshmallow import Schema, fields, validate
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema
from ..models.quote import Quote

class QuoteSchema(SQLAlchemyAutoSchema):
    class Meta:
        model = Quote
        load_instance = True
        include_relationships = True
    
    customer = fields.Nested('CustomerSchema', dump_only=True)
    craftsman = fields.Nested('CraftsmanSchema', dump_only=True, exclude=('quotes',))
    service = fields.Nested('ServiceSchema', dump_only=True)

class QuoteRequestSchema(Schema):
    craftsman_id = fields.Int(required=True)
    service_id = fields.Int()
    title = fields.Str(required=True, validate=validate.Length(min=5, max=200))
    description = fields.Str(required=True, validate=validate.Length(min=20, max=1000))
    location = fields.Str(required=True, validate=validate.Length(min=10, max=200))
    preferred_date = fields.DateTime()
    budget_min = fields.Decimal(places=2, validate=validate.Range(min=0))
    budget_max = fields.Decimal(places=2, validate=validate.Range(min=0))

class QuoteResponseSchema(Schema):
    quote_id = fields.Int(required=True)
    price = fields.Decimal(places=2, required=True, validate=validate.Range(min=0))
    message = fields.Str(required=True, validate=validate.Length(min=10, max=1000))
    estimated_duration = fields.Int(validate=validate.Range(min=1))
    proposed_date = fields.DateTime()

class QuoteUpdateSchema(Schema):
    status = fields.Str(validate=validate.OneOf(['pending', 'accepted', 'rejected', 'completed', 'cancelled']))
    craftsman_message = fields.Str(validate=validate.Length(max=1000))
    price = fields.Decimal(places=2, validate=validate.Range(min=0))
    estimated_duration = fields.Int(validate=validate.Range(min=1))
    proposed_date = fields.DateTime()