# Use an official Python runtime as a base image
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container
COPY . /app

# Install dependencies
RUN pip install -r requirements.txt

# Expose the port the app runs on
EXPOSE 5000

# Command to run the app
CMD ["python", "app.py"]
