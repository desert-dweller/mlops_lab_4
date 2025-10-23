import pandas as pd
import sys
import os

# URL for the Telco Customer Churn dataset
url = 'https://raw.githubusercontent.com/IBM/telco-customer-churn-on-icp4d/master/data/Telco-Customer-Churn.csv'

print("Downloading dataset...")
try:
    df = pd.read_csv(url)
    # Ensure the output directory exists
    os.makedirs('data/raw', exist_ok=True)
    # Save the raw data
    df.to_csv('data/raw/churn.csv', index=False)
    print("Dataset downloaded successfully to data/raw/churn.csv")
except Exception as e:
    print(f"Error downloading data: {e}")
    sys.exit(1)