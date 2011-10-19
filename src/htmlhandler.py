#!/usr/bin/python
# -*- coding: utf-8 -*-

from StringIO import StringIO
from lxml import etree
from balbec.xmlhandler import XmlHandler

class HtmlHandler(XmlHandler):

	def __init__(self, documentRoot):

		self.documentRoot = documentRoot

	def readUrlPrefix(self):
	
		configFile = open(self.documentRoot+'/config.xml', 'r')
		doc = etree.parse(configFile)
		
		urlNode = doc.xpath("/balbec/nagios/url_prefix")[0]
		return urlNode.text

	def html(self):

		xml = self.xml()
		
		urlPrefix = self.readUrlPrefix()
		
		stylesheetFile = open(self.documentRoot+'/xslt/html.xsl', 'r')
		stylesheetDoc = etree.parse(stylesheetFile)
		urlPrefixNode = stylesheetDoc.xpath('/xsl:stylesheet/xsl:variable', namespaces = {'xsl' : 'http://www.w3.org/1999/XSL/Transform'})[0]
		urlPrefixNode.text = urlPrefix
		stylesheet = etree.XSLT(stylesheetDoc)
		
		stringIO = StringIO(xml)
		doc = etree.parse(stringIO)
		result = stylesheet(doc)
		
		return str(result)
