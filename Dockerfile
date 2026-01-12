
FROM python:3.12-slim

WORKDIR /app

# System deps for mysqlclient
RUN apt-get update && apt-get install -y \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy app
COPY . /app

# Install Python deps
RUN pip install --no-cache-dir \
    flask \
    flask-sqlalchemy \
    flask-login \
    flask-migrate \
    mysqlclient

EXPOSE 5000

CMD ["python", "app.py"]
