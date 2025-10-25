# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container to /code
WORKDIR /code

# --- NEW: Define build arguments to receive secrets ---
ARG DVC_USER
ARG DVC_TOKEN
# ----------------------------------------------------

# Copy the requirements file into the container at /code
COPY ./requirements.txt /code/requirements.txt

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# Copy all the project files into the container
COPY . .

# --- THIS IS THE CRITICAL FIX ---
# 1. Use the build arguments to create the DVC config file inside the container
RUN echo "['remote \"origin\"']\nuser = ${DVC_USER}\npassword = ${DVC_TOKEN}" > .dvc/config.local

# 2. Run dvc pull. It will now find and use the credentials.
RUN dvc pull

# 3. Immediately remove the config file so secrets are not saved in the image.
RUN rm .dvc/config.local
# --------------------------------

# Copy the feature repository into the container *before* running feast commands
COPY ./feature_repo /code/feature_repo

WORKDIR /code/feature_repo

# Build the feature store registry and database files
RUN feast apply

# Pre-populate the online store with the latest features
RUN feast materialize-incremental $(python -c "from datetime import datetime; print(datetime.now().isoformat())")

# Copy the app directory (containing main.py) into the container at /code
WORKDIR /code

# Make port 10000 available to the world outside this container
EXPOSE 10000

# Command to run the application when the container launches
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "10000"]