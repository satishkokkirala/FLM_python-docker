# ==================================================
# STAGE 1: BUILD
# ==================================================

FROM python:3.12-slim AS build

# Metadata
LABEL stage="build"

# Build argument
ARG APP_VERSION=1.0

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Working directory
WORKDIR /app

# Copy dependency file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Copy application code
COPY app.py .


# ==================================================
# STAGE 2: PRODUCTION
# ==================================================

FROM python:3.12-slim AS production

# Metadata
LABEL maintainer="Satish"
LABEL application="FLM Python Application"

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Create non-root user
RUN useradd --create-home --shell /bin/bash appuser

# Working directory
WORKDIR /app

# Copy installed Python packages from build stage
COPY --from=build /install /usr/local

# Copy application from build stage
COPY --from=build /app/app.py .

# Change ownership
RUN chown -R appuser:appuser /app

# Run as non-root user
USER appuser

# Application port
EXPOSE 8000

# Container startup command
CMD ["python", "app.py"]
