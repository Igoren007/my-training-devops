FROM ubuntu
SHELL ["/bin/bash", "-c"]
RUN apt-get update && sudo apt-get install -y apt-transport-https software-properties-common wget
RUN sudo mkdir -p /etc/apt/keyrings/
RUN wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
RUN echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
RUN apt-get update && apt-get install grafana-enterprise
RUN apt-get update && apt-get install curl iputils-ping
COPY ./grafana_conf/grafana.ini /etc/grafana