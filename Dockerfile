# multistage build https://docs.docker.com/build/building/multi-stage/
# aunque no es necesario en este ejercicio en concreto porque ambas librerias son la misma lo dejo preparado para posibles plantillas
# 1
FROM python:3.12-slim AS builder

WORKDIR /app

COPY requirements.txt requirements-test.txt /app/

RUN pip install --no-cache-dir -r requirements.txt -r requirements-test.txt

# 2
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "run.py"]
