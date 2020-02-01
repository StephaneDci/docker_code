FROM python:3.7-rc-slim
LABEL "Description"="############ Python API-Consul : Container Image ###########"

#DONT MODIFY PROXY PARAMETERS : Use scripts
#ENV http_proxy "http://"
#ENV https_proxy "https://"
#ENV PIP_OPTIONS="--proxy $http_proxy"

RUN pip install --upgrade pip
RUN pip install requests flask

EXPOSE 5000

#API version 1 Python 2.7-slim

# clé d'environnement pour indiquer que le processus tourne dans un container
#ENV INCONTAINER "true"
#RUN mkdir /usr/bin/python_api_v1
#COPY python_api_v1 /usr/bin/python_api_v1
#RUN ls /usr/bin/python_api_v1
#CMD ["python" , "./usr/bin/python_api_v1/restapi.py"]


#API Version 2.2 Python 3.7

RUN mkdir /usr/bin/python_api_v22
COPY python_api_v22 /usr/bin/python_api_v22
RUN ls /usr/bin/python_api_v22
CMD ["python" , "./usr/bin/python_api_v22/restapi.py"]
#CMD ["/bin/bash"]
