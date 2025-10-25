# app/main.py
from fastapi import FastAPI
from feast import FeatureStore
from pydantic import BaseModel

# Define the input data model
class CustomerInput(BaseModel):
    customer_id: str

app = FastAPI(title="MLOps Course API")

# Initialize the feature store from the repository inside the container
fs = FeatureStore(repo_path="feature_repo")

@app.get("/", tags=["Greeting"])
def read_root():
    """Returns a simple greeting message."""
    return {"message": "Hello from your deployed app!"}

# Feature endpoint to look at the feature store
@app.post("/features", tags=["Feature Store"])
def get_features(customer_input: CustomerInput):
    """Fetches and displays live features for a given customer ID."""
    
    # Define the features we want to retrieve
    features_to_get = fs.get_feature_view("churn_features_view").features
    
    # Prepare the entity dictionary for the lookup
    entity = {"customerID": customer_input.customer_id}
    
    # Fetch features from the online store
    online_features = fs.get_online_features(
        features=features_to_get,
        entity_rows=[entity]
    ).to_dict()
    
    return online_features
# --------------------