import re
import socket
from datetime import datetime
from balbec.objects import Host, Hostgroup, Servicegroup, Result, Service

class LivestatusBackend:

    directive_counter = 0
    host_counter = 0
    hostgroup_counter = 0
    
    def __init__(self, socketPath):

        self.socketPath = socketPath
        
    def query(self, queryString):

        try:
            s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            s.connect(self.socketPath)
            s.send(queryString)
            s.shutdown(socket.SHUT_WR)
            answer = s.recv(100000000)
            if answer[:-1] == '':
                
                return []
            else:

                return answer[:-1].split("\n")
        except socket.error, e:

             raise Exception("Couldn't query livestatus socket: "+str(e.args[1]))

    def getCurrentDateTime(self):

        return datetime.now()     

    def getLastCheck(self):

        queryString = "GET status\nColumns: last_command_check\n"
        lines = self.query(queryString)
        lastCheck = float(lines[0])

        return datetime.fromtimestamp(lastCheck)  

    def getServicegroups(self, names):
    
        reString = '^' + '$|^'.join(names) + '$'
        queryString = "GET servicegroups\nColumns: name members\nFilter: name ~ " + reString + "\n"
        lines = self.query(queryString)

        idServicegroupMap = {}

        for line in lines:

            columns = line.split(';')
            name = columns[0]
            members = columns[1].split(',')

            idServicegroupMap[name] = Servicegroup(name)

            for member in members:

                elements = member.split('|')
                hostObjectId = elements[0]
                serviceObjectId = elements[1]

                if hostObjectId not in idServicegroupMap[name].hostObjectIds:

                    if hostObjectId not in idServicegroupMap[name].hostObjectIds:
                
                        idServicegroupMap[name].addHostObjectId(hostObjectId)
                        idServicegroupMap[name].hostServiceObjectIds[hostObjectId] = []
                    idServicegroupMap[name].hostServiceObjectIds[hostObjectId].append(serviceObjectId)

        return idServicegroupMap.values()
    
    def getHostgroups(self, names):

        reString = '^' + '$|^'.join(names) + '$'
        queryString = "GET hostgroups\nColumns: name members\nFilter: name ~ " + reString + "\n"
        lines = self.query(queryString)

        idHostgroupMap = {}

        for line in lines:

            columns = line.split(';')
            name = columns[0]
            members = columns[1].split(',')
            idHostgroupMap[name] = Hostgroup(name)
            idHostgroupMap[name].hostObjectIds = members
        
        return idHostgroupMap.values()

    def getHosts(self, group):

        #self.host_counter = self.host_counter + 1

        reString = '^' + '$|^'.join(group.hostObjectIds) + '$'
        queryString = "GET hosts\nColumns: host_name plugin_output state\nFilter: host_name ~ " + reString + "\n"
        lines = self.query(queryString)

        hosts = {}

        for line in lines:

            columns = line.split(';')
            hostname = columns[0]
            output = columns[1]
            status = int(columns[2])

            host = Host(hostname)
            host.setResult(Result(status, output))
            hosts[hostname] = host

        reString = '^' + '$|^'.join(group.hostObjectIds) + '$'
        queryString = "GET services\nColumns: host_name description plugin_output state\nFilter: host_name ~ " + reString + "\n"
        if isinstance(group, Servicegroup):

            descriptions = []
            for hostname in group.hostObjectIds:

                descriptions = descriptions + group.hostServiceObjectIds[hostname]
            reString = '^' + '$|^'.join(descriptions) + '$'
            queryString = queryString + "Filter: description ~ " + reString + "\n" 
        lines = self.query(queryString)

        for line in lines:

            columns = line.split(';')
            hostname = columns[0]
            description = columns[1]
            output = columns[2]
            status = int(columns[3])

            service = Service(description)
            service.setResult(Result(status, output))
            hosts[hostname].addService(service)

        return hosts.values();
