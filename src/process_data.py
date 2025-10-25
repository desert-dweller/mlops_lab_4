# src/process_data.py
import os
import pandas as pd

os.makedirs('data/processed', exist_ok=True)
print("Reading raw data...")
df = pd.read_csv('data/raw/churn.csv')

# Clean 'TotalCharges' column
df['TotalCharges'] = pd.to_numeric(df['TotalCharges'], errors='coerce')
df['TotalCharges'].fillna(df['TotalCharges'].median(), inplace=True)

# Convert target variable to binary
df['Churn'] = df['Churn'].apply(lambda x: 1 if x == 'Yes' else 0)

# This satisfies Feast's requirement for a timestamp in the data source.
df['event_timestamp'] = pd.Timestamp.now()
# -----------------------------------------

print("Saving processed data with timestamp to Parquet format...")
df.to_parquet('data/processed/churn_features.parquet', index=False)
print("Data processing complete.")