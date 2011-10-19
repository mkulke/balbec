#!/usr/bin/python
# -*- coding: utf-8 -*-

class Filter:

    def __init__(self, name):
    
        self.name = name
        self.revert = False
        self.hostgroups = []

class Map:

    def __init__(self, name):

        self.name = name
        self.expression = []

class GroupObject:

    HOSTGROUP = 0
    SERVICEGROUP = 1
    
    def __init__(self, name, show, type):
    
        self.name = name
        self.show = show
        self.type = type    
    
class Operation:

    AND = 0
    NOT = 1
    OR = 2
    
    def __init__(self, expression, type):
    
        self.expression = expression
        self.type = type

class Result:

    def __init__(self, status, output):

        self.status = status
        self.output = output        
        
class Hostgroup:

    def __init__(self, name):

        self.name = name
        self.hostObjectIds = []
        self.hosts = []
        self.show = True
    def addHostObjectId(self, id):

        self.hostObjectIds.append(id)

class Servicegroup:

    def __init__(self, name):

        self.name = name
        self.hostObjectIds = []
        self.hosts = []
        self.show = True
        self.hostServiceObjectIds = {}
    def addHostObjectId(self, id):

        self.hostObjectIds.append(id)

class Host:

    def __init__(self, hostname):

        self.hostname = hostname
        self.result = None
        self.services = []
    def setResult(self, result):

        self.result = result
    def addService(self, service):

        self.services.append(service)

class Service:  

    def __init__(self, servicename):

        self.servicename = servicename
        self.result = None
    def setResult(self, result):

        self.result = result

