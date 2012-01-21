#!/usr/bin/python
# -*- coding: utf-8 -*-

from balbec.xmlhandler import XmlHandler
from balbec.htmlhandler import HtmlHandler

def application(environ, start_response):

    try:
	
        accept = environ['HTTP_ACCEPT']
    except KeyError:

        accept = 'text/xml'
    documentRoot = environ['DOCUMENT_ROOT']

    try:

        pathElements = filter(None, environ['PATH_INFO'].split('/'))
        if len(pathElements) == 1:
                
            requestedMap = pathElements[0]
        elif len(pathElements) > 1:

            raise Exception('"' + self.path + '" is not an allowed path.')
        else:
            
            requestedMap = None

        if accept.find('text/html') != -1:

            type = 'text/html'
            handler = HtmlHandler(documentRoot)
            if requestedMap == None:
        
                responseHeaders = [("Location", "/" + handler.maps[0].name)]
                start_response('301 Moved Permanently', responseHeaders)                             
                return []
            output = handler.html(requestedMap)
        else:

            type = 'text/xml'
            handler = XmlHandler(documentRoot)
            output = handler.xml(requestedMap)  
    except Exception, e:
        
        output = str(e)
        responseHeaders = [('Content-type', type), ('Content-Length', str(len(output)))]
        start_response('503 Service Unavailable', responseHeaders)
        return [output]

    responseHeaders = [('Content-type', type), ('Content-Length', str(len(output)))]
    start_response('200 OK', responseHeaders)
    return [output]
