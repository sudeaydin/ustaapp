from marshmallow import Schema, fields, validate
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema
from ..models.review import Review

class ReviewSchema(SQLAlchemyAutoSchema):
    class Meta:
        model = Review
        load_instance = True
        include_relationships = True
    
    customer = fields.Nested('CustomerSchema', dump_only=True)
    craftsman = fields.Nested('CraftsmanSchema', dump_only=True, exclude=('reviews',))
    quote = fields.Nested('QuoteSchema', dump_only=True, exclude=('review',))

class ReviewCreateSchema(Schema):
    craftsman_id = fields.Int(required=True)
    quote_id = fields.Int()
    rating = fields.Int(required=True, validate=validate.Range(min=1, max=5))
    comment = fields.Str(validate=validate.Length(min=10, max=1000))
    work_quality = fields.Int(validate=validate.Range(min=1, max=5))
    communication = fields.Int(validate=validate.Range(min=1, max=5))
    punctuality = fields.Int(validate=validate.Range(min=1, max=5))
    value_for_money = fields.Int(validate=validate.Range(min=1, max=5))

class ReviewUpdateSchema(Schema):
    rating = fields.Int(validate=validate.Range(min=1, max=5))
    comment = fields.Str(validate=validate.Length(min=10, max=1000))
    work_quality = fields.Int(validate=validate.Range(min=1, max=5))
    communication = fields.Int(validate=validate.Range(min=1, max=5))
    punctuality = fields.Int(validate=validate.Range(min=1, max=5))
    value_for_money = fields.Int(validate=validate.Range(min=1, max=5))