<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="/balbec">
        <balbec config_version="1">
            <xsl:copy-of select="nagios"/>
            <xsl:for-each select="map">
                <map>
                    <xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
                    <xsl:copy-of select="hostgroup"/>
                    <xsl:variable name="andItems" select= "filter[@revert='true']"/>
                    <xsl:if test="count($andItems) &gt; 0">
                        <and>
                            <xsl:for-each select="$andItems">
                                <hostgroup><xsl:value-of select="."/></hostgroup>         
                            </xsl:for-each>
                        </and>
                    </xsl:if>
                    <xsl:variable name="notItems" select= "filter[@revert!='true']"/>
                    <xsl:if test="count($notItems) &gt; 0">
                        <not>
                            <xsl:for-each select="$notItems">
                                 <hostgroup><xsl:value-of select="."/></hostgroup>
                            </xsl:for-each>       
                        </not>
                    </xsl:if>                                     
                </map>
            </xsl:for-each>
        </balbec>
    </xsl:template>
</xsl:stylesheet>
