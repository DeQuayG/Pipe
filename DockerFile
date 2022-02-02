#Dockerfile, Image, Container 
#The 'DockerFile' is the blueprint for running images
#The image is a template for running containers
# The container is the actual running process holding your packaged code 


FROM ubuntu:latest
RUN apt-get update && apt-get install -y
RUN apt-get -qq -y install curl
RUN apt-get install sudo
RUN apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
RUN apt-get update -y
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
RUN add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable" 
RUN apt-get update 
RUN apt-get install docker-ce docker-ce-cli containerd.io -y

EXPOSE 80 443 

RUN apt-get install python3 
RUN apt-get install pip -y


#ENV PYTHON_APP=WebScraperClass.py

WORKDIR /app/

RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

COPY requirements.txt /app/

RUN pip install -r requirements.txt

COPY /WebScraperClass.py /app/

CMD ["python3", "WebScraperClass.py"] 
