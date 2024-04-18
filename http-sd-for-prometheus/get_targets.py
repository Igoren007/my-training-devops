from kazoo.client import KazooClient
import json, os
import http.server

NODE_EXPORTER_PORT = 9100
CADVISOR_PORT = 9200
ZK_HOST = os.getenv("ZK_HOST")
ZK_PORT = os.getenv("ZK_PORT")

class MyRequestHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json_string_zk(NODE_EXPORTER_PORT).encode())

        elif self.path == "/cadvisor":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json_string_zk(CADVISOR_PORT).encode())


def get_hosts_from_zk():
    zk_connect = f"{ZK_HOST}:{ZK_PORT}"
    zk_hosts = []
    zk = KazooClient(hosts=zk_connect)
    zk.start()
    children = zk.get_children("/nodes")
    for i in children:
        data, _ = zk.get(f'/nodes/{i}')
        host = data.decode('utf-8')
        zk_hosts.append(host)
    zk.stop()
    return zk_hosts


def list2dict(lst, service_port):
    out = []
    for host in lst:
        ip = host.split(',')[1].split(':')[1]
        dct = {}
        host = []
        host.append(f"{ip}:{service_port}")
        dct['targets'] = host
        out.append(dct)
    return out


def json_string_zk(service_port):
    hosts = list2dict(get_hosts_from_zk(), service_port)
    json_nodes = json.dumps(hosts)
    return json_nodes


if __name__ == "__main__":
    server_address = ('', 8888)
    httpd = http.server.HTTPServer(server_address, MyRequestHandler)
    httpd.serve_forever()