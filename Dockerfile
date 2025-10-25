# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container to /code
WORKDIR /code

# Copy the requirements file into the container at /code
COPY ./requirements.txt /code/requirements.txt

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# Copy the app directory (containing main.py) into the container at /code
COPY ./app /code/app

# Copy the feature repository into the container
COPY ./feature_repo /code/feature_repo

# Make port 10000 available to the world outside this container
EXPOSE 10000

# Command to run the application when the container launches
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "10000"]