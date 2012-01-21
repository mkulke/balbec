<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:variable name="url_prefix">http://nagios/nagios/cgi-bin/status.cgi?host=</xsl:variable>
	<xsl:template match="/">
		<html>
		    <head>
		        <title>Balbec v1.5</title>
		        <META HTTP-EQUIV="refresh">
		            <xsl:attribute name="content">120;URL=/<xsl:value-of select="/nagios/map[not(@skipped = 'true')]/@name"/></xsl:attribute>
		        </META>
		    </head>
			<!--<body onload="toggleMap('test')">-->
			<body onload="buildDateString()">
				<script type="text/javascript">
				    function hasClass(elem, className) {
				    
                        var regexp = new RegExp('\\b' + className + '\\b');
                        return regexp.test(elem.className);
				    }
					function toggleServices(hostname) {

						var all = document.getElementsByTagName('*');
						for (var i = 0; i &lt; all.length; i++) {
							
							var elem = all[i];
							var className = hostname + '.service';
							if (hasClass(elem, className)) {
				
								var toggler = document.getElementById(hostname+'.toggler');

                                if (hasClass(elem, 'hidden_service')) {
                                
                                    elem.className = className;
                                    toggler.innerHTML = '+';
                                } else {
                                
                                    elem.className = className + ' hidden_service';
                                    toggler.innerHTML = '-';
                                }
							}
						}
					}
					function buildDateString() {

						var currentTime = <xsl:value-of select="/nagios/@currentTime"/>;
						var lastCheck = <xsl:value-of select="/nagios/@lastCheck"/>;
						var min = parseInt((currentTime - lastCheck) / 60);
						var maxmin = 5;
						var delayed = min &#62; maxmin;
						var date = new Date(currentTime * 1000);

						if (delayed) var ago = '<span class="red_text">'+min+'m ago</span>';
						else var ago = '&#60; '+maxmin+'m ago';

                        var lastCheckBox = document.getElementById('last_check_box');
                        lastCheckBox.innerHTML = 'last check: '+date.toLocaleString()+' ('+ago+')';
					}
				</script>
				<style type="text/css">
                    a:link { text-decoration: none; }
                    a:active { text-decoration: none; }
                    a:visited { text-decoration: none; }
                    .red_text { color: red; }
                    #map_list {
                    
                        margin:3px;
                        border-collapse:collapse;
                    }
                    .map_list_item { 
                    
                        border-style:solid;
                        border-width:thin;
                        border-color:black;
                        padding:3px;
                    }
                    #map_list_selected_item { background-color:lightgray; }
                    .group_td { vertical-align:top; }
                    .group_table { border-style:none; }
                    .group_table_2 {
                    
                        white-space:nowrap;
                        border-style:solid;
                        border-width:thin;
                        border-color:black;
                        background:lightgray;
                    }
                    .host_table {
                    
                        white-space:nowrap;
                        border-style:solid;
                        border-width:thin;
                        border-color:black;
                        background:lightgray;
                    }
                    .green_bg { background-color:limegreen; }
                    .red_bg { background-color:red; }
                    .yellow_bg { background-color:yellow; }
                    .grey_bg { background-color:grey; }
                    .hidden_service { display:none; }
                    #last_check_box {
                    
                        display:table;
                        border-style:solid;
                        border-color:black;
                        border-width:thin;
                        padding-top:3px;
                        padding-left:3px;
                        padding-right:3px;
                        margin:3px;
                    }
                    .monospace_font { font-family:monospace; }
                    .clearer { clear:left; }
                </style>
				<table id="map_list">
					<tr>
						<xsl:for-each select="/nagios/map">
							<td class="map_list_item">
								<xsl:if test="not(@skipped = 'true')">
								    <xsl:attribute name="id">map_list_selected_item</xsl:attribute>
								</xsl:if>
								<a>
								    <xsl:attribute name="href"><xsl:text>/</xsl:text><xsl:value-of select="@name"/></xsl:attribute>
								    <xsl:value-of select="@name"/>
								</a>
							</td>
						</xsl:for-each>
					</tr>
				</table>
				<xsl:for-each select="/nagios/map[not(@skipped = 'true')]">
				    <div class="map">			    
					<xsl:attribute name="id"><xsl:value-of select="@name"/>.map</xsl:attribute>
					<table cellpadding="0" cellspacing="0">
					<tr>
					<xsl:for-each select="hostgroup|servicegroup">
						<td class="group_td">
							<table class="group_table">
								<tr>
									<td>
										<table width="100%" class="group_table_2">
											<tr>
												<td><xsl:value-of select="@name"/></td>
											</tr>
										</table>
									</td>
								</tr>
								<xsl:for-each select="host">
									<tr>								
										<td>
											<table width="100%" class="host_table">								
                                                <tr>
                                                    <xsl:if test="ancestor::hostgroup">
                                                        <td width="1%"><xsl:call-template name="hostgroup_header"/></td>
                                                    </xsl:if>
                                                    <xsl:if test="ancestor::servicegroup">
                                                        <td width="1%"><xsl:call-template name="servicegroup_header"/></td>
                                                    </xsl:if>
                                                    <td>
                                                        <xsl:element name="a">
                                                            <xsl:attribute name="href">
                                                                <xsl:value-of select="$url_prefix"/><xsl:value-of select="@name"/>
                                                            </xsl:attribute>
                                                            <xsl:value-of select="@name"/>
                                                        </xsl:element>
                                                    </td>
                                                    <td width="1%">
                                                        <xsl:if test="ancestor::hostgroup">
                                                            <xsl:choose>
                                                                <xsl:when test="status/code='0'">
                                                                    <xsl:attribute name="class">green_bg</xsl:attribute>
                                                                </xsl:when>
                                                                <xsl:when test="status/code='1'">
                                                                    <xsl:attribute name="class">red_bg</xsl:attribute>	
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:attribute name="class">grey_bg</xsl:attribute>	
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        <xsl:value-of select="status/text"/>
                                                        </xsl:if>
                                                        <xsl:if test="ancestor::servicegroup">
                                                            <xsl:call-template name="servicegroup_header_two"/>
                                                        </xsl:if>
                                                    </td>
                                                </tr>                                            
											<xsl:for-each select="service">
												<tr>												    
                                                    <xsl:attribute name="class">hidden_service <xsl:value-of select="../../../@name"/>.<xsl:value-of select="../../@name"/>.<xsl:value-of select="../@name"/>.service</xsl:attribute>
                                                    <td></td>
													<td>
													    <xsl:choose>
													        <xsl:when test="ancestor::hostgroup">
													            <xsl:value-of select="@name"/>
													        </xsl:when>
													        <xsl:when test="ancestor::servicegroup">
													            <xsl:element name="a">
                                                                    <xsl:attribute name="href">
                                                                        <xsl:value-of select="$url_prefix"/>
                                                                        <xsl:value-of select="../@name"/>
                                                                    </xsl:attribute>
                                                                    <xsl:value-of select="@name"/>
                                                                </xsl:element>
      													    </xsl:when>
													    </xsl:choose>
						                            </td>
													<td>
														<xsl:choose>
															<xsl:when test="status/code='0'">
																<xsl:attribute name="class">green_bg</xsl:attribute>
															</xsl:when>
															<xsl:when test="status/code='1'">
																<xsl:attribute name="class">yellow_bg</xsl:attribute>
															</xsl:when>
															<xsl:when test="status/code='2'">
																<xsl:attribute name="class">red_bg</xsl:attribute>
															</xsl:when>
															<xsl:otherwise>
																<xsl:attribute name="class">grey_bg</xsl:attribute>
															</xsl:otherwise>
														</xsl:choose>
														<xsl:value-of select="status/text"/>
													</td>
												</tr>
											</xsl:for-each>
										</table>
									</td></tr>
								</xsl:for-each>
							</table>
						</td>
					</xsl:for-each></tr></table>
				</div></xsl:for-each>
				<div class="clearer"/>
				<div id="last_check_box">
					<xsl:value-of select="/nagios/@lastCheck"/>
				</div>
			</body>
		</html>
	</xsl:template>
	<xsl:template name="color_max_problem">
        <xsl:variable name="unknown_found" select="count(service/status/code[. = 3]) &gt; 0"/>
        <xsl:variable name="warning_found" select="count(service/status/code[. = 1]) &gt; 0"/>
        <xsl:variable name="error_found" select="count(service/status/code[. = 2]) &gt; 0"/>
        <xsl:attribute name="class">monospace_font</xsl:attribute>
        <xsl:if test="$unknown_found='true'">
            <xsl:attribute name="class">grey_bg monospace_font</xsl:attribute>
        </xsl:if>
        <xsl:if test="$warning_found='true'">
            <xsl:attribute name="class">yellow_bg monospace_font</xsl:attribute>
        </xsl:if>
        <xsl:if test="$error_found='true'">
            <xsl:attribute name="class">red_bg monospace_font</xsl:attribute>
        </xsl:if>
    </xsl:template>
	<xsl:template name="hostgroup_header" match="host">
		<xsl:choose>
			<xsl:when test="count(./service) &gt; 0">
                <xsl:call-template name="color_max_problem"/>
				<xsl:attribute name="onclick">toggleServices('<xsl:value-of select="../../@name"/>.<xsl:value-of select="../@name"/>.<xsl:value-of select="@name"/>')</xsl:attribute>
				<xsl:attribute name="onmouseover">this.style.cursor='pointer';</xsl:attribute>
				<xsl:attribute name="id"><xsl:value-of select="../../@name"/>.<xsl:value-of select="../@name"/>.<xsl:value-of select="@name"/>.toggler</xsl:attribute>
				<xsl:text>+</xsl:text>
			</xsl:when>
			<xsl:otherwise>/</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
    <xsl:template name="servicegroup_header" match="host">
        <xsl:attribute name="class">monospace_font</xsl:attribute>
		<xsl:choose>
			<xsl:when test="count(./service) &gt; 0">
				<xsl:attribute name="onclick">toggleServices('<xsl:value-of select="../../@name"/>.<xsl:value-of select="../@name"/>.<xsl:value-of select="@name"/>')</xsl:attribute>
				<xsl:attribute name="onmouseover">this.style.cursor='pointer';</xsl:attribute>
				<xsl:attribute name="id"><xsl:value-of select="../../@name"/>.<xsl:value-of select="../@name"/>.<xsl:value-of select="@name"/>.toggler</xsl:attribute>
				<xsl:text>+</xsl:text>
			</xsl:when>
			<xsl:otherwise>/</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
    <xsl:template name="print_max_problem">
        <xsl:variable name="unknown_found" select="count(service/status/code[. = 3]) &gt; 0"/>
        <xsl:variable name="warning_found" select="count(service/status/code[. = 1]) &gt; 0"/>
        <xsl:variable name="error_found" select="count(service/status/code[. = 2]) &gt; 0"/>
        <xsl:if test="$unknown_found='true'">
            <xsl:attribute name="class">grey_bg</xsl:attribute>
            <xsl:value-of select="service/status[code = 3]/text"/>
        </xsl:if>
        <xsl:if test="$warning_found='true'">
            <xsl:attribute name="class">yellow_bg</xsl:attribute>
            <xsl:value-of select="service/status[code = 1]/text"/>
        </xsl:if>
        <xsl:if test="$error_found='true'">
            <xsl:attribute name="class">red_bg</xsl:attribute>
            <xsl:value-of select="service/status[code = 2]/text"/>
        </xsl:if>
        <xsl:if test="not(($unknown_found) or ($error_found) or ($warning_found))">
            <xsl:attribute name="class">green_bg</xsl:attribute>
            <xsl:value-of select="service/status/text"/>
        </xsl:if>
    </xsl:template>
	<xsl:template name="servicegroup_header_two" match="host">
	    <xsl:call-template name="print_max_problem">
	        <xsl:with-param name="values" select="service/status/code"/>
	    </xsl:call-template>
	</xsl:template>
</xsl:stylesheet>
