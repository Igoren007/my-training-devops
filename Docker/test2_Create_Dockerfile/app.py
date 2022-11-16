from email import message
import time
import datetime

while True:
    now = datetime.datetime.now()
    message = f'Hello from Python at {now.strftime("%d-%m-%Y %H:%M:%S")}'
    print(message)
    with open("/usr/src/data/output.txt", "a") as file:
        file.write(message)
    time.sleep(3)
