<?xml version='1.0'?>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->

<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
	exclude-result-prefixes="doc" version='1.0'>

<!-- REFERENCE -->
<doc:reference xmlns="">
<referenceinfo>
<releaseinfo role="meta"> 
$Id$
</releaseinfo>
<author> <surname>Casellas</surname> <firstname>Ramon</firstname> </author>
<copyright><year>2000</year><holder>Ramon Casellas</holder>	</copyright>
</referenceinfo>
<title>ProgramListing Templates</title>
	<partintro>
		<section><title>Introduction</title>
		</section>
	</partintro>
</doc:reference>

<!-- DOCUMENTATION -->
<doc:template name="revhistory" xmlns="">
<refpurpose> revhistory XSL template </refpurpose>
<refdescription>
</refdescription>
</doc:template>

<xsl:template match="revhistory">
<xsl:if test="$latex.output.revhistory=1">
	<xsl:message>RCAS: Processing Revision History </xsl:message>
	<xsl:text>&#10;</xsl:text>
	<xsl:text>%% ------------------------ 	&#10;</xsl:text>
	<xsl:text>%% RevHistory					&#10;</xsl:text>
	<xsl:text>%% ------------------------	&#10;</xsl:text>
	<xsl:text>\pagebreak&#10;</xsl:text>
	<xsl:text>\begin{table}[htb]&#10;</xsl:text>
	<xsl:text>\caption{</xsl:text><xsl:call-template name="gentext.element.name"/><xsl:text>}</xsl:text>
	<xsl:text>\begin{center}&#10;</xsl:text>
	<xsl:text>{\tt \begin{tabular}{|l||l|l|}\hline&#10;</xsl:text>
	      <xsl:apply-templates/>
	<xsl:text>\end{tabular} }&#10;</xsl:text>
	<xsl:text>\end{center}&#10;</xsl:text>
	<xsl:text>\end{table}&#10;</xsl:text>
	<xsl:text>%% ------------------------ 	&#10;</xsl:text>
	<xsl:text>%% ends RevHistory 			&#10;</xsl:text>
	<xsl:text>%% ------------------------ 	&#10;</xsl:text>
</xsl:if>
</xsl:template>


<!-- DOCUMENTATION -->
<doc:template name="revhistory/revision" xmlns="">
<refpurpose> revhistory XSL template </refpurpose>
<refdescription>
</refdescription>
</doc:template>

<xsl:template match="revhistory/revision">
<xsl:variable name="revnumber" select=".//revnumber"/>
<xsl:variable name="revdate"   select=".//date"/>
<xsl:variable name="revauthor" select=".//authorinitials"/>
<xsl:variable name="revremark" select=".//revremark|../revdescription"/>
  <!-- Row starts here -->
    	<xsl:if test="$revnumber">
     		<xsl:call-template name="gentext.element.name"/>
     		<xsl:text> </xsl:text>
     		<xsl:apply-templates select="$revnumber"/>
    	</xsl:if>
    <xsl:text>&amp;</xsl:text>
    <xsl:apply-templates select="$revdate"/>
    <xsl:text>&amp;</xsl:text>
    <xsl:choose>
      <xsl:when test="count($revauthor)=0">
          	<xsl:call-template name="dingbat">
            <xsl:with-param name="dingbat">nbsp</xsl:with-param>
          	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
          	<xsl:apply-templates select="$revauthor"/>
      </xsl:otherwise>
    </xsl:choose>
    <!-- End Row here -->
    <xsl:text>\\\hline&#10;</xsl:text>
    <!-- Add Remark Row if exists-->
    <xsl:if test="$revremark"> 
    	<xsl:text>\multicolumn{3}{l}{</xsl:text>
    	<xsl:apply-templates select="$revremark"/> 
    	<!-- End Row here -->
    	<xsl:text>}\\\hline&#10;</xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template match="revision/revnumber">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="revision/date">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="revision/authorinitials">
  <xsl:text>, </xsl:text>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="revision/authorinitials[1]">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="revision/revremark">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="revision/revdescription">
  <xsl:apply-templates/>
</xsl:template>
</xsl:stylesheet>
