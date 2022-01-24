#Dockerfile, Image, Container 
#The 'DockerFile' is the blueprint for running images
#The image is a template for running containers
# The container is the actual running process holding your packaged code 

FROM python:3.9.0 

WORKDIR /app/

COPY requirements.txt /app/

RUN pip install -r requirements.txt

COPY /WebScraperClass.py /app/

#ADD WebScraperClass.py . 
 


CMD ["python3", "WebScraperClass.py"] 