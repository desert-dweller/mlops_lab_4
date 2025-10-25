# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container to /code
WORKDIR /code

# Copy the requirements file into the container at /code
COPY ./requirements.txt /code/requirements.txt

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# Copy the Git history so DVC knows which data version to pull
COPY .git .git

# Copy DVC metadata and config files
COPY .dvc .dvc
COPY ./data /code/data
COPY ./src /code/src

# --- THIS IS THE CRITICAL FIX ---
# Run dvc pull to download the data from the remote (Dagshub)
# This will use the secrets we provide in the Hugging Face UI.
RUN dvc pull
# --------------------------------

# Copy the feature repository into the container
COPY ./feature_repo /code/feature_repo

# 1. Build the feature store registry and database files
RUN cd /code/feature_repo && feast apply

# 2. Pre-populate the online store with the latest features
RUN cd /code/feature_repo && feast materialize-incremental $(python -c "from datetime import datetime; print(datetime.now().isoformat())")

# Copy the app directory (containing main.py) into the container
COPY ./app /code/app

# Make port 10000 available to the world outside this container
EXPOSE 10000

# Command to run the application when the container launches
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "10000"]