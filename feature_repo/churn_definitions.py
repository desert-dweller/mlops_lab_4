# feature_repo/churn_definitions.py
from datetime import timedelta
from feast import Entity, Field, FeatureView, FileSource, ValueType
from feast.types import String, Int64, Float64  # <-- Import Float64

customer_entity = Entity(
    name="customer",
    join_keys=["customerID"],
    value_type=ValueType.STRING
)

churn_source = FileSource(
    path="../data/processed/churn_features.parquet",
    timestamp_field="",
)

churn_features_view = FeatureView(
    name="churn_features_view",
    entities=[customer_entity],
    ttl=timedelta(days=365),
    schema=[
        Field(name="gender", dtype=String),
        Field(name="SeniorCitizen", dtype=Int64),
        Field(name="Partner", dtype=String),
        Field(name="Dependents", dtype=String),
        Field(name="tenure", dtype=Int64),
        Field(name="Contract", dtype=String),
        Field(name="MonthlyCharges", dtype=Float64), 
        Field(name="TotalCharges", dtype=Float64),   
        Field(name="Churn", dtype=Int64),
    ],
    source=churn_source,
    online=True,
    tags={},
)