# feature_repo/churn_definitions.py
from datetime import timedelta
from feast import (
    Entity, Feature, FeatureView, FileSource, ValueType,
)

customer = Entity(name="customerID", value_type=ValueType.STRING)

churn_source = FileSource(
    file_path="../data/processed/churn_features.parquet",
)

churn_features_view = FeatureView(
    name="churn_features_view",
    entities=[customer],
    ttl=timedelta(days=365),
    features=[
        Feature(name="gender", dtype=ValueType.STRING),
        Feature(name="SeniorCitizen", dtype=ValueType.INT64),
        Feature(name="Partner", dtype=ValueType.STRING),
        Feature(name="Dependents", dtype=ValueType.STRING),
        Feature(name="tenure", dtype=ValueType.INT64),
        Feature(name="Contract", dtype=ValueType.STRING),
        Feature(name="MonthlyCharges", dtype=ValueType.FLOAT),
        Feature(name="TotalCharges", dtype=ValueType.FLOAT),
        Feature(name="Churn", dtype=ValueType.INT64),
    ],
    source=churn_source, online=True, tags={},
)