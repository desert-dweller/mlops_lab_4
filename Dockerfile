# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the main working directory
WORKDIR /code

# Copy and install requirements first to leverage Docker caching
COPY ./requirements.txt .
RUN pip install --no-cache-dir --upgrade -r requirements.txt

# Copy all the project files into the container
# This includes .git, .dvc, data, src, feature_repo, and app
COPY . .

# --- THIS IS THE CRITICAL FIX ---
# Run dvc pull to download the actual data files from Dagshub
RUN dvc pull

# Set the working directory to the feature repo for the Feast commands
WORKDIR /code/feature_repo

# 1. Build the feature store registry and database files
RUN feast apply

# 2. Pre-populate the online store with the latest features
RUN feast materialize-incremental $(python -c "from datetime import datetime; print(datetime.now().isoformat())")

# Reset the working directory for the final app command
WORKDIR /code
# --------------------------------

# Make port 10000 available to the world outside this container
EXPOSE 10000

# Command to run the application when the container launches
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "10000"]