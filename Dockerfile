FROM python:3.10-alpine3.13

LABEL maintainer="newsoftsolution.com"

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Copy requirements files and application code
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

# Set the working directory
WORKDIR /app

# Expose the application port
EXPOSE 8000

# Argument for development mode
ARG DEV=false

# Install dependencies and create a virtual environment
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Update PATH environment variable
ENV PATH="/py/bin:$PATH"

# Set user for the container
USER django-user
