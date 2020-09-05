# Jenkins
import tempfile

def _run_jenkins_proxy(port):
    conf = tempfile.NamedTemporaryFile(mode='w', delete=False)
    conf.write('''
LogLevel Warning
MaxClients 5
MinSpareServers 5
MaxSpareServers 20
StartServers 10
Port {port}
ReverseOnly Yes
Upstream http localhost:8080
'''.format(port=port))
    conf.close()
    return ['tinyproxy', '-d', '-c', conf.name]

c.ServerProxy.servers = {
  'jenkins': {
    'command': _run_jenkins_proxy, # Nothing to do
    'absolute_url': True,
    'timeout': 30,
  }
}
