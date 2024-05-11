from kazoo.client import KazooClient
import socket
import time
import signal
from requests import get
import subprocess


SIGNAL_STATUS = True
hostname = socket.gethostname()
addresses = subprocess.run(['hostname', '-I'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True).stdout
host_info = f"name:{hostname},ip:{addresses}"

def handler_stop_signal():
    if zk.exists(f"/nodes/{hostname}") is not None:
        zk.delete(f"/nodes/{hostname}")
        zk.stop()


def signal_handler(signum, frame):
    global SIGNAL_STATUS
    SIGNAL_STATUS = False


zk = KazooClient(hosts='176.57.212.153:2181')
zk.start()

if zk.exists("/nodes"):
    zk.create(f"/nodes/{hostname}", bytes(host_info, 'utf-8'))
    print(f"created node {hostname}")
else:
    zk.create("/nodes")
    zk.create(f"/nodes/{hostname}", bytes(host_info, 'utf-8'))
    print(f"created node {hostname}")


signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGINT, signal_handler)

while SIGNAL_STATUS:
    time.sleep(1)

handler_stop_signal()
