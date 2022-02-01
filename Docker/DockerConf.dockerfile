#Dockerfile, Image, Container 
#The 'DockerFile' is the blueprint for running images
#The image is a template for running containers
# The container is the actual running process holding your packaged code 

FROM python:3.9.0 
RUN pip install boto3
RUN apk update && apk add --no-cache docker-cli

#ENV PYTHON_APP=WebScraperClass.py

WORKDIR /app/

RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

COPY requirements.txt /app/

RUN pip install -r requirements.txt

COPY /WebScraperClass.py /app/

CMD ["python3", "WebScraperClass.py"] 
