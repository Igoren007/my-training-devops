FROM python:3.8

RUN mkdir /app
WORKDIR /app
ENV PYTHONUNBUFFERED=1
COPY . /app
RUN pip install -r requirements.txt
EXPOSE 8888
CMD ["python", "get_targets.py"]
