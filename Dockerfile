# FROM python:3.10-alpine3.13

# LABEL maintainer="newsoftsolution.com"

# ENV PYTHONUNBUFFERED=1

# COPY ./requirements.txt /tmp/requirements.txt
# COPY ./requirements.dev.txt /tmp/requirements.dev.txt
# COPY ./app /app
# WORKDIR /app
# EXPOSE 8000

# ARG DEV=false
# RUN python -m venv /py && \
#     /py/bin/pip install --upgrade pip && \
#     /py/bin/pip install -r /tmp/requirements.txt && \
#     if [$DEV = "true"]; \
#         then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
#     fi && \
#     rm -rf /tmp && \ 
#     adduser \
#         --disabled-password \
#         --no-create-home \
#         django-user

# ENV PATH="/py/bin:$PATH"

# USER django-user

FROM python:3.10-alpine3.13

LABEL maintainer="newsoftsolution.com"

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Copy requirements files
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

# Set working directory
WORKDIR /app

# Expose application port
EXPOSE 8000

# Build argument to determine if it's a development build
ARG DEV=false

# Install system dependencies
RUN apk add --no-cache gcc musl-dev libffi-dev && \
    python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .temp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt flake8; fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Set PATH to include the virtual environment
ENV PATH="/py/bin:$PATH"

# Switch to the non-root user
USER django-user

# Default command (can be overridden in docker-compose)
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]




