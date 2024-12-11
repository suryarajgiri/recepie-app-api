FROM python:3.10-alpine3.13

LABEL maintainer="newsoftsolution.com"

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PATH="/py/bin:$PATH"

# Set a working directory
WORKDIR /app

# Copy requirements files first to leverage Docker layer caching
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# Argument for development mode
ARG DEV=false

# Install system dependencies, create a virtual environment, and install Python dependencies
RUN apk add --no-cache --virtual .build-deps \
        gcc musl-dev libffi-dev postgresql-dev && \
    python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi && \
    apk del .build-deps && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Copy the application code
COPY ./app /app

# Expose the application port
EXPOSE 8000

# Switch to a non-root user
USER django-user

# Start the application (default entry point)
CMD ["sh", "-c", "python manage.py runserver 0.0.0.0:8000"]
