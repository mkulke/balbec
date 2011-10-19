<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:nag="http://blue-elephant-systems.com/midas/nagios/1.0">

	<!--All valid host options.-->

	<xsl:template match="nag:host">
		<xsl:param name="identifier"/>

		<table width="100%" style="white-space:nowrap;border-style:solid;border-width:thin;border-color:black;background:lightgray;">

			<xsl:call-template name="print_id_line">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:call-template>

			<xsl:apply-templates select="nag:identifier">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:template_identifier">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:template_reference">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:register">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:reference">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:alias">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:address">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:max_check_attempts">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:check_interval">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:active_checks_enabled">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:passive_checks_enabled">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:obsess_over_host">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:check_freshness">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:freshness_threshold">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:event_handler_enabled">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:low_flap_threshold">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:high_flap_threshold">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:flap_detection_enabled">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:process_perf_data">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>				
			<xsl:apply-templates select="nag:retain_status_information">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>	
			<xsl:apply-templates select="nag:retain_nonstatus_information">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>		
			<xsl:apply-templates select="nag:notification_interval">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:notification_options">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>	
			<xsl:apply-templates select="nag:notifications_enabled">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>	
			<xsl:apply-templates select="nag:stalking_options">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
		</table>
	</xsl:template>

	<!--All valid hostgroup options.-->

	<xsl:template match="nag:hostgroup">
		<xsl:param name="identifier"/>
		<table width="100%" style="white-space:nowrap;border-style:solid;border-width:thin;border-color:black;background:lightgray;">
			<xsl:call-template name="print_id_line">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:call-template>
			<xsl:apply-templates select="nag:identifier">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:template_identifier">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:template_reference">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:register">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:reference">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="nag:alias">
				<xsl:with-param name="identifier" select="$identifier"/>
			</xsl:apply-templates>
		</table>
	</xsl:template>

	<!--Define attribute identifier.-->

	<xsl:template name="get_identifier">
		<xsl:choose>
			<xsl:when test="./nag:identifier">
				<xsl:value-of select="./nag:identifier/*[1]"/>
			</xsl:when>
			<xsl:when test="./nag:template_identifier">
				<xsl:value-of select="./nag:template_identifier/*[1]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!--Print id line.-->

	<xsl:template name="print_id_line">
		<xsl:param name="identifier"/>
		<tr>
			<td width="1%">
				<xsl:attribute name="onclick">toggleAttributes('<xsl:value-of select="$identifier"/>')</xsl:attribute>
				<xsl:attribute name="id"><xsl:value-of select="$identifier"/>.toggler</xsl:attribute>
				<xsl:attribute name="onmouseover">this.style.cursor='pointer';</xsl:attribute>
				<xsl:attribute name="style">font-family:monospace;</xsl:attribute>
				<xsl:text>+</xsl:text>
			</td>
			<td>
				<xsl:value-of select="$identifier"/>
			</td>
			<td></td>
		</tr>
	</xsl:template>

	<!--Strip identifier & reference tags.-->

	<xsl:template match="nag:identifier">
		<xsl:param name="identifier"/>
		<xsl:apply-templates select="nag:command_name">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:contact_name">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:contactgroup_name">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:host_name">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:hostgroup_name">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:service_description">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:servicegroup_name">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:timeperiod_name">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="nag:reference">
		<xsl:param name="identifier"/>
		<xsl:apply-templates select="nag:check_command">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:check_period">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:contactgroups">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:contact_groups">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:dependent_host_name">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:dependent_service_description">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:escalation_period">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:event_handler">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:host_name">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:host_notification_period">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:host_notification_commands">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:hostgroup_name">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:hostgroups">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:members">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>	
		<xsl:apply-templates select="nag:notification_period">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:parents">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:service_description">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:servicegroup">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:service_notification_period">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="nag:service_notification_commands">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>	
	</xsl:template>

	<xsl:template match="nag:template_identifier">
		<xsl:param name="identifier"/>
		<xsl:apply-templates select="nag:name">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>	
	</xsl:template>

	<xsl:template match="nag:template_reference">
		<xsl:param name="identifier"/>
		<xsl:apply-templates select="nag:use">
			<xsl:with-param name="identifier" select="$identifier"/>
		</xsl:apply-templates>	
	</xsl:template>

	<!--Call this template with a param encode = true if the arguments need to be decoded.-->

	<xsl:template match="nag:*">

		<xsl:param name="identifier"/>
		
		<tr>
			<xsl:attribute name="style">display:none;</xsl:attribute>
			<xsl:attribute name="class">
				<xsl:value-of select="$identifier"/>
				<xsl:text>.attribute</xsl:text>	
			</xsl:attribute>	
			<td></td>				
			<xsl:choose>

				<!-- If the preceding sibling has the same name, omit the name.-->

				<xsl:when test="name(preceding-sibling::*[1]) != name()">

					<td>

						<!--Print the option, which is the node name w/o the "nag:" prefix. 2d & 3d_coords have to be renamed, since xml tags starting with numbers are not legal.-->

						<xsl:variable name="tagname" select="local-name()"/>
						<xsl:choose>
							<xsl:when test="$tagname = 'coords_2d'">
								<xsl:text>2d_coords</xsl:text>
							</xsl:when>		
							<xsl:when test="$tagname = 'coords_3d'">
								<xsl:text>3d_coords</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$tagname"/>
							</xsl:otherwise>	
						</xsl:choose>	
						<xsl:text>: </xsl:text>
					</td>
				</xsl:when>
				<xsl:otherwise><td></td></xsl:otherwise>
			</xsl:choose>
			<td>
				<xsl:value-of select="."/>
				<!--If there neighbours which are called argument#, append them to the element string.-->

				<xsl:for-each select="../*[starts-with(name(),'nag:argument')]">
					<xsl:text>!</xsl:text>
					<xsl:value-of select="."/>
				</xsl:for-each>
			</td>
		</tr>
	</xsl:template>

<xsl:template name="javascript">
	function toggleAttributes(identifier) {

		var all = document.getElementsByTagName('*');
		for (var i = 0; i &lt; all.length; i++) {
			
			elem = all[i];
			if (elem.className &amp;&amp; elem.className == identifier+'.attribute') {

				var toggler = document.getElementById(identifier+'.toggler');

				if (elem.style.display == '')  {
		
					elem.style.display = 'none';
					toggler.innerHTML = '+';
				} else {

					elem.style.display = '';
					toggler.innerHTML = '-';
				}
			}
		}
	}	
</xsl:template>

<xsl:template match="/nag:configuration">
	<html>
		<script type="text/javascript">
			<xsl:call-template name="javascript"/>	
		</script>
		<head><title>nagios html test</title></head>
		<body>
			<table style="border-style:none;">
				<xsl:for-each select="./*">
					<xsl:variable name="identifier"><xsl:call-template name="get_identifier"/></xsl:variable>
					<tr>
						<td>
							<xsl:apply-templates select=".">
								<xsl:with-param name="identifier" select="$identifier"/>
							</xsl:apply-templates>
						</td>
					</tr>
				</xsl:for-each>
			</table>
		</body>
	</html>
</xsl:template>
</xsl:stylesheet>
