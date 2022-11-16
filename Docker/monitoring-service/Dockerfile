# pull official base image
FROM alpine

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install dependencies
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools
# set work directory
RUN mkdir -p /usr/src/app/
WORKDIR /usr/src/app
COPY ./requirements.txt .
RUN pip install -r requirements.txt
# copy project
COPY . .

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]