# ==================================================
# STAGE 1: BUILD
# ==================================================

FROM python:3.12-slim AS build

LABEL stage="build"

ARG APP_VERSION=1.0

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Copy application
COPY app.py .
COPY templates ./templates


# ==================================================
# STAGE 2: PRODUCTION
# ==================================================

FROM python:3.12-slim AS production

LABEL maintainer="Satish"
LABEL application="FLM Python Application"

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN useradd --create-home --shell /bin/bash appuser

WORKDIR /app

# Copy Python packages
COPY --from=build /install /usr/local

# Copy application
COPY --from=build /app/app.py .
COPY --from=build /app/templates ./templates

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

CMD ["python", "app.py"]
