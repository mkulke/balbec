#!/usr/bin/python
# -*- coding: utf-8 -*-

from lxml import etree
import sys

try:

    if len(sys.argv) != 2:

        stylesheetFilename = sys.argv[1]
        oldconfigFilename = sys.argv[2]
except Exception:

    print 'syntax: convert_config.py [stylesheet filename] [old config filename]'
    sys.exit(1) 

stylesheetFile = open(stylesheetFilename, 'r')
stylesheetDoc = etree.parse(stylesheetFile)
stylesheet = etree.XSLT(stylesheetDoc)

oldFile = open(oldconfigFilename, 'r')
oldDoc = etree.parse(oldFile)

result = stylesheet(oldDoc)
print str(result).replace('><', '>\n<')
