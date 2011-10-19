#!/usr/bin/python
# -*- coding: utf-8 -*-

from lxml import etree
import re
import datetime
from balbec.objects import Map, Hostgroup, Operation, GroupObject

HOST_UP = 0
HOST_DOWN = 1
HOST_UNREACHABLE = 2
HOST_UNREACHABLE_2 = 3

SERVICE_OK = 0
SERVICE_WARNING = 1
SERVICE_CRITICAL = 2
SERVICE_UNKNOWN = 3

hostStatus = {HOST_UP : "Up", HOST_DOWN : "Down", HOST_UNREACHABLE : "Unreachable", HOST_UNREACHABLE_2 : "Unreachable"}
serviceStatus = {SERVICE_OK : "Ok", SERVICE_WARNING : "Warning", SERVICE_CRITICAL : "Critical", SERVICE_UNKNOWN : "Unknown"}

class XmlHandler:

    def __init__(self, documentRoot):

        self.documentRoot = documentRoot

    def readConfig(self):

        maps = []

        schemaFile = open(self.documentRoot+'/schema/config.xsd', 'r')
        schemaDoc = etree.parse(schemaFile)
        schema = etree.XMLSchema(schemaDoc)

        configFile = open(self.documentRoot+'/config.xml', 'r')
        try:
            doc = etree.parse(configFile)
            schema.assertValid(doc)
        except etree.XMLSyntaxError, e:
           
            raise Exception('Invalid Config file: "'+str(e)+'"')
        except etree.DocumentInvalid, e:

            schemaFile = open(self.documentRoot+'/schema/old_config.xsd', 'r')
            schemaDoc = etree.parse(schemaFile)
            schema = etree.XMLSchema(schemaDoc)

            try: 

                schema.assertValid(doc)

                stylesheetFile = open(self.documentRoot+'/xslt/old_config.xsl', 'r')
                stylesheetDoc = etree.parse(stylesheetFile)
                stylesheet = etree.XSLT(stylesheetDoc)
                doc = stylesheet(doc)
            except:

                raise Exception('Invalid Config file: "'+str(e)+'"')

        mysqlNodes = doc.xpath("/balbec/nagios/ndo2db")
        filesNodes = doc.xpath("/balbec/nagios/files")
        livestatusNodes = doc.xpath("/balbec/nagios/livestatus")
        if len(mysqlNodes) == 1:

            from balbec.mysqlbackend import MysqlBackend

            mysql = MysqlBackend()

            mysqlNode = doc.xpath("/balbec/nagios/ndo2db")[0]

            databaseNodes = mysqlNode.xpath('database')
            if len(databaseNodes) == 1:

                mysql.database = databaseNodes[0].text
            hostnameNodes = mysqlNode.xpath('hostname')
            if len(hostnameNodes) == 1:

                mysql.hostname = hostnameNodes[0].text
            usernameNodes = mysqlNode.xpath('username')
            if len(usernameNodes) == 1:

                mysql.username = usernameNodes[0].text
            passwordNodes = mysqlNode.xpath('password')
            if len(passwordNodes) == 1 and passwordNodes[0] != None:

                mysql.password = passwordNodes[0].text  
            prefixNodes = mysqlNode.xpath('prefix')
            if len(prefixNodes) == 1 and prefixNodes[0] != None:

                mysql.prefix = prefixNodes[0].text

            mysql.connect()
            backend = mysql
        elif len(filesNodes) == 1:

            from balbec.filebackend import FileBackend

            objectFilename = doc.xpath("/balbec/nagios/files/object_file")[0].text      
            statusFilename = doc.xpath("/balbec/nagios/files/status_file")[0].text     

            backend = FileBackend(objectFilename, statusFilename)
        elif len(livestatusNodes) == 1:

            from balbec.livestatusbackend import LivestatusBackend

            socketPath = doc.xpath("/balbec/nagios/livestatus/socket_path")[0].text
            backend = LivestatusBackend(socketPath)

        mapNames = []
        mapNodes = doc.xpath("/balbec/map")
        for mapNode in mapNodes:

            mapName = mapNode.get("name")
            if mapName in mapNames:
            
                raise Exception('Map "'+mapName+'" is defined more than once.')
            else:
            
                mapNames.append(mapName)
            
            map = Map(mapName) 

            hostgroups = []
            
            expression = self.buildExpression(mapNode)
            #self.printExpression(expression)

            map.expression = expression
            maps.append(map)
        
        return maps, backend

    def buildExpression(self, node):
    
            expression = []
    
            hostgroupNodes = node.xpath("hostgroup")
            for hostgroupNode in hostgroupNodes:

                name = hostgroupNode.text
                show = not (len(hostgroupNode.xpath("@show")) > 0 and hostgroupNode.xpath("@show")[0] == "false")               
                expression.append(GroupObject(name, show, GroupObject.HOSTGROUP))
            servicegroupNodes = node.xpath("servicegroup")
            for servicegroupNode in servicegroupNodes:

                name = servicegroupNode.text
                show = not (len(servicegroupNode.xpath("@show")) > 0 and servicegroupNode.xpath("@show")[0] == "false")               
                expression.append(GroupObject(name, show, GroupObject.SERVICEGROUP))           
            andNodes = node.xpath("and")
            for andNode in andNodes:

                andExpression = self.buildExpression(andNode)
                expression.append(Operation(andExpression, Operation.AND))
            orNodes = node.xpath("or")
            for orNode in orNodes:

                orExpression = self.buildExpression(orNode)
                expression.append(Operation(orExpression, Operation.OR))
            notNodes = node.xpath("not")
            for notNode in notNodes:

                notExpression = self.buildExpression(notNode)
                expression.append(Operation(notExpression, Operation.NOT))    
                
            return expression

    def printExpression(self, expression):
    
        for part in expression:
        
            if isinstance(part, Operation):
            
                symbols = ['&', '!', '|']
                print symbols[part.type] + '('
                self.printExpression(part.expression)
                print ')'
            elif isinstance(part, GroupObject):
            
                print '|' + part.name + ', show: ' + str(part.show)

    def getFilteredGroups(self, backend, expression):
        
        # select groups first
        
        assembledGroups = []
        
        def isGroupObject(x): return isinstance(x, GroupObject)
        groupObjects = filter(isGroupObject, expression)
        for groupObject in groupObjects: 
                
            if groupObject.type == GroupObject.HOSTGROUP: groups = backend.getHostgroups([groupObject.name])
            elif groupObject.type == GroupObject.SERVICEGROUP: groups = backend.getServicegroups([groupObject.name])
            for group in groups: 
            
                if groupObject.show == True: group.show = True
            assembledGroups.extend(groups)
        
        # get hostgroups from OR clauses
        
        def isOrOperation(x): return isinstance(x, Operation) and x.type == Operation.OR
        operations = filter(isOrOperation, expression)
        for operation in operations:
            
            groups = self.getFilteredGroups(backend, operation.expression)
            assembledGroups.extend(groups)
                
        # build object id list from assembled groups        
                
        objectIds = []
        for group in assembledGroups: objectIds.extend(group.hostObjectIds)
                
        # get hostgroups from AND clauses and filter hosts out                
                      
        def isAndOperation(x): return isinstance(x, Operation) and x.type == Operation.AND
        operations = filter(isAndOperation, expression)
        for operation in operations:

            andIds = []
            groups = self.getFilteredGroups(backend, operation.expression)
            for group in groups: andIds.extend(group.hostObjectIds)                
            def andFilter(x): return x in andIds
            objectIds = filter(andFilter, objectIds)

        # get hostgroups from NOT clauses and filter hosts out                
                        
        def isNotOperation(x): return isinstance(x, Operation) and x.type == Operation.NOT
        operations = filter(isNotOperation, expression)
        for operation in operations:

            notIds = []
            groups = self.getFilteredGroups(backend, operation.expression)     
            for group in groups: notIds.extend(group.hostObjectIds)              
            def notFilter(x): return x not in notIds
            objectIds = filter(notFilter, objectIds)                    
        
        # allow only those hosts which are in objectIds
        
        def andFilter(x): return x in objectIds
        for group in assembledGroups: group.hostObjectIds = filter(andFilter, group.hostObjectIds) 
        
        return assembledGroups
        
    def xml(self):       

        maps, backend = self.readConfig()
        dt = backend.getLastCheck()
        lastCheck = dt.strftime('%s')
        dt = backend.getCurrentDateTime()
        currentTime=dt.strftime('%s')        

        nagiosNode = etree.Element('nagios', currentTime=str(currentTime), lastCheck=str(lastCheck))

        for map in maps:
        
            mapNode = etree.SubElement(nagiosNode, 'map', name = map.name)
            
            groups = self.getFilteredGroups(backend, map.expression)
            #hostgroups = self.getFilteredGroups(backend, map.expression)

            for group in groups:

                if group.show == False:
                
                    continue
                if len(group.hostObjectIds) == 0:

                    continue
                group.hosts = backend.getHosts(group)
                
                if isinstance(group, Hostgroup): groupNode = etree.SubElement(mapNode, "hostgroup", name=group.name)
                else: groupNode = etree.SubElement(mapNode, "servicegroup", name=group.name)

                for host in group.hosts:

                    hostNode = etree.SubElement(groupNode, "host", name=host.hostname)
                    if host.result:

                        statusText = hostStatus[host.result.status]
                        statusCode = host.result.status
                    else:

                        statusText = serviceStatus[SERVICE_UNKNOWN]
                        statusCode = SERVICE_UNKNOWN

                    if isinstance(group, Hostgroup):
                    
                        statusNode = etree.SubElement(hostNode, "status")
                        codeNode = etree.SubElement(statusNode, "code")
                        codeNode.text = str(statusCode)
                        textNode = etree.SubElement(statusNode, "text")
                        textNode.text = str(statusText)

                    for service in host.services:

                        serviceNode = etree.SubElement(hostNode, "service", name=service.servicename)
                        if service.result:

                            statusText = serviceStatus[service.result.status]
                            statusCode = service.result.status
                        else:

                            statusText = serviceStatus[SERVICE_UNKNOWN]
                            statusCode = SERVICE_UNKNOWN

                        statusNode = etree.SubElement(serviceNode, "status")
                        codeNode = etree.SubElement(statusNode, "code")
                        codeNode.text = str(statusCode)
                        textNode = etree.SubElement(statusNode, "text")
                        textNode.text = str(statusText)
            
        tree = etree.ElementTree(nagiosNode)
        return etree.tostring(tree, encoding='UTF-8', pretty_print=True, xml_declaration=True)
        
      
        
