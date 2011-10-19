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

        if accept.find('text/html') != -1:

            type = 'text/html'
            handler = HtmlHandler(documentRoot)
            output = handler.html()
        else:

            type = 'text/xml'
            handler = XmlHandler(documentRoot)
            output = handler.xml()  
    except Exception, e:
        
        output = str(e)
        responseHeaders = [('Content-type', type), ('Content-Length', str(len(output)))]
        start_response('503 Service Unavailable', responseHeaders)

    responseHeaders = [('Content-type', type), ('Content-Length', str(len(output)))]
    start_response('200 OK', responseHeaders)
    return [output]
