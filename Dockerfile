# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container to /code
WORKDIR /code

# Copy the requirements file into the container at /code
COPY ./requirements.txt /code/requirements.txt

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# --- DEBUGGING CHECKPOINT 1 ---
# Let's see what we're starting with. This should just show 'requirements.txt'.
RUN echo "--- 1. Listing contents of /code before copying project files ---" && ls -la

# Copy all necessary Git and DVC files for context
COPY .git .git
COPY .dvc .dvc
COPY ./data /code/data
COPY ./src /code/src
COPY ./feature_repo /code/feature_repo
COPY ./app /code/app

# --- DEBUGGING CHECKPOINT 2 ---
# Let's see if the pointer files were copied correctly.
# You should see the .dvc files, but NOT the actual Parquet file.
RUN echo "--- 2. Listing contents of /code/data/processed after copy ---" && ls -l /code/data/processed

# This command downloads the actual data files from Dagshub
RUN echo "--- 3. Running dvc pull ---" && dvc pull

# --- DEBUGGING CHECKPOINT 3 (THE MOST IMPORTANT ONE) ---
# Now, let's check if the Parquet file actually exists after dvc pull.
# THIS MUST SHOW 'churn_features.parquet'. If it doesn't, dvc pull failed.
RUN echo "--- 4. Listing contents of /code/data/processed AFTER dvc pull ---" && ls -l /code/data/processed

# 1. Build the feature store registry and database files
RUN echo "--- 5. Running feast apply ---" && cd /code/feature_repo && feast apply

# 2. Pre-populate the online store with the latest features
RUN echo "--- 6. Running feast materialize ---" && cd /code/feature_repo && feast materialize-incremental $(python -c "from datetime import datetime; print(datetime.now().isoformat())")

# Make port 10000 available to the world outside this container
EXPOSE 10000

# Command to run the application when the container launches
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "10000"] 