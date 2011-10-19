#!/usr/bin/python
# -*- coding: utf-8 -*-

import MySQLdb
import re
from datetime import datetime
from balbec.objects import Host, Hostgroup, Servicegroup, Result, Service

class MysqlBackend:

    def __init__(self):

        self.database = 'nagios'
        self.hostname = 'localhost'
        self.username = 'nagios'
        self.password = ''
        self.prefix = 'nagios'
        self.connection = None

    def __del__(self):

        self.connection.close()

    def connect(self):

        try:

            self.connection = MySQLdb.connect(self.hostname, self.username, self.password, self.database)       
        except MySQLdb.Error, e:

            raise Exception("Could not connect to database: "+str(e.args[1]))

    def getLastCheck(self):

        try:
            cursor = self.connection.cursor()

            cursor.execute("SELECT last_command_check FROM "+self.prefix+"_programstatus")
            row = cursor.fetchone()
            dtString = str(row[0])
            dtNumbers = re.findall('(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d+)', dtString)[0]
            dt = datetime(int(dtNumbers[0]), int(dtNumbers[1]), int(dtNumbers[2]), int(dtNumbers[3]), int(dtNumbers[4]), int(dtNumbers[5]))

            cursor.close()
            return dt
        except MySQLdb.Error, e:

            self.connection.close()
            raise Exception("Could not fetch last check date from database: "+str(e.args[1]))

    def getCurrentDateTime(self):

        try:
            cursor = self.connection.cursor()

            cursor.execute("SELECT CURDATE(), CURTIME()")
            row = cursor.fetchone()
            dtString = str(row[0])+' '+str(row[1])
            dtNumbers = re.findall('(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d+)', dtString)[0]
            dt = datetime(int(dtNumbers[0]), int(dtNumbers[1]), int(dtNumbers[2]), int(dtNumbers[3]), int(dtNumbers[4]), int(dtNumbers[5]))

            cursor.close()
            return dt
        except MySQLdb.Error, e:

            self.connection.close()
            raise Exception("Could not fetch current date and time from database: "+str(e.args[1]))

    def getServicegroups(self, names):
    
        if len(names) == 0:

            return []
            raise Exception("List of servicegroup names invalid or empty.")
        try:
        
            cursor = self.connection.cursor()

            whereClause = '") OR (name1="'.join(names)
            cursor.execute('SELECT name1, object_id FROM '+self.prefix+'_objects WHERE (objecttype_id="4") AND ((name1="'+whereClause+'"))')
            rows = cursor.fetchall()

            if len(rows) != len(names):

                raise Exception("List of servicegroup names invalid or empty.")

            objectIdNameMap = {}

            for row in rows:

                objectIdNameMap[str(row[1])] = row[0]

            whereClause = '") OR (servicegroup_object_id="'.join(objectIdNameMap.keys())
            cursor.execute('SELECT servicegroup_id, servicegroup_object_id FROM '+self.prefix+'_servicegroups WHERE (servicegroup_object_id="'+whereClause+'")')
            rows = cursor.fetchall()

            # bis hier ok

            idServicegroupMap = {}

            for row in rows:

                name = objectIdNameMap[str(row[1])]
                idServicegroupMap[str(row[0])] = Servicegroup(name)

            # get all members

            whereClause = '") OR (servicegroup_id="'.join(idServicegroupMap.keys())
            cursor.execute('SELECT service_object_id, servicegroup_id FROM '+self.prefix+'_servicegroup_members WHERE (servicegroup_id="'+whereClause+'")')         
            rows = cursor.fetchall()

            for row in rows:

                serviceId = str(row[0])
                servicegroupId = str(row[1])

                # find out the host in which the service is.

                cursor.execute('SELECT host_object_id FROM '+self.prefix+'_services WHERE (service_object_id="'+serviceId+'")')
                hostId = str(cursor.fetchone()[0])

                if hostId not in idServicegroupMap[servicegroupId].hostObjectIds:

                    idServicegroupMap[servicegroupId].addHostObjectId(hostId)
                    idServicegroupMap[servicegroupId].hostServiceObjectIds[hostId] = []
                idServicegroupMap[servicegroupId].hostServiceObjectIds[hostId].append(serviceId)
                    
            cursor.close()
            return idServicegroupMap.values()

        except MySQLdb.Error, e:

            self.connection.close()
            raise Exception("Couldn't fetch service information from database: "+str(e.args[1]))

    def getHostgroups(self, names):

        if len(names) == 0:

            return []
            raise Exception("List of hostgroup names invalid or empty.")

        try:

            cursor = self.connection.cursor()

            whereClause = '") OR (name1="'.join(names)
            cursor.execute('SELECT name1, object_id FROM '+self.prefix+'_objects WHERE (objecttype_id="3") AND ((name1="'+whereClause+'"))')
            rows = cursor.fetchall()

            if len(rows) != len(names):

                raise Exception("List of hostgroup names invalid or empty.")

            objectIdNameMap = {}

            for row in rows:

                objectIdNameMap[str(row[1])] = row[0]

            whereClause = '") OR (hostgroup_object_id="'.join(objectIdNameMap.keys())
            cursor.execute('SELECT hostgroup_id, hostgroup_object_id FROM '+self.prefix+'_hostgroups WHERE (hostgroup_object_id="'+whereClause+'")')
            rows = cursor.fetchall()

            idHostgroupMap = {}

            for row in rows:

                name = objectIdNameMap[str(row[1])]
                idHostgroupMap[str(row[0])] = Hostgroup(name)

            whereClause = '") OR (hostgroup_id="'.join(idHostgroupMap.keys())
            cursor.execute('SELECT host_object_id, hostgroup_id FROM '+self.prefix+'_hostgroup_members WHERE (hostgroup_id="'+whereClause+'")')
            rows = cursor.fetchall()

            for row in rows:

                idHostgroupMap[str(row[1])].addHostObjectId(str(row[0]))

            cursor.close()
            return idHostgroupMap.values()

        except MySQLdb.Error, e:

            self.connection.close()
            raise Exception("Couldn't fetch hostgroup information from database: "+str(e.args[1]))

    def getHosts(self, group):
    
        try:
            cursor = self.connection.cursor()

            hosts = {}


            if len(group.hostObjectIds) == 0: return hosts

            # get a list of all hosts in hostgroup

            whereClause = '") OR (host_object_id="'.join(group.hostObjectIds)
            cursor.execute('SELECT host_object_id, display_name FROM '+self.prefix+'_hosts WHERE (host_object_id="'+whereClause+'")')   

            rows = cursor.fetchall()
            for row in rows:

                hosts[str(row[0])] = Host(row[1])
    
            # get host results
        
            if isinstance(group, Hostgroup):
        
                whereClause = '") OR (host_object_id="'.join(hosts.keys())
                cursor.execute('SELECT host_object_id, current_state, output FROM '+self.prefix+'_hoststatus WHERE(host_object_id="'+whereClause+'")')
            
                rows = cursor.fetchall()
                for row in rows:
    
                    result = Result(row[1], row[2])
                    hosts[str(row[0])].setResult(result)

            # get service list
        
            services = {}

            whereClause = '") OR (host_object_id="'.join(hosts.keys())
            cursor.execute('SELECT host_object_id, service_object_id, display_name FROM '+self.prefix+'_services WHERE (host_object_id="'+whereClause+'")')

            rows = cursor.fetchall()
        
            for row in rows:

                service = Service(row[2])
                services[str(row[1])] = service
                
                if isinstance(group, Servicegroup) and str(row[1]) not in group.hostServiceObjectIds[str(row[0])]: continue
                
                hosts[str(row[0])].addService(service)
        
            # get service results
            
            whereClause = '") OR (service_object_id="'.join(services.keys())
            cursor.execute('SELECT service_object_id, current_state, output FROM '+self.prefix+'_servicestatus WHERE (service_object_id="'+whereClause+'")')
            rows = cursor.fetchall()
        
            for row in rows:

                result = Result(row[1], row[2])
                services[str(row[0])].setResult(result)

            cursor.close()
            return hosts.values()
        
        except MySQLdb.Error, e:

            self.connection.close()
            raise Exception("Could fetch host information from database: "+str(e.args[1]))
