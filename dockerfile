FROM ubuntu:latest

RUN apt update && apt install -y net-tools

RUN apt install -y git

RUN git clone https://github.com/nasiryork/kuralabs_deployment_5.git

WORKDIR /kuralabs_deployment_5

RUN apt install -y python3.11

RUN apt install -y python3-pip

RUN pip install Flask

RUN pip install -r /kuralabs_deployment_5/requirements.txt

EXPOSE 5000

ENTRYPOINT FLASK_APP=application flask run --host=0.0.0.0