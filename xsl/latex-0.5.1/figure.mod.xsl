<?xml version='1.0'?>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$												
 |														
 |   PURPOSE: Template for figure tag.
 + ############################################################################## -->

<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
	exclude-result-prefixes="doc" version='1.0'>
 

<doc:template name="XSL template for figure and informalfigure" xmlns="">
	<refpurpose> XSL template for figure|informalfigure  </refpurpose>
	<refdescription>
		<para>Outputs <literal>\begin{figure}</literal>,
		applies templates and outputs <literal>\end{abstract}</literal>. </para>
		<formalpara><title>Remarks and Bugs</title>
		<itemizedlist>
		</itemizedlist>
		</formalpara>
	</refdescription>
</doc:template>

<xsl:template match="figure|informalfigure">
<xsl:text>\begin{figure}</xsl:text><xsl:value-of select="$latex.figure.position"/><xsl:text>&#10;</xsl:text>
<xsl:text>\begin{center}&#10;</xsl:text>
<xsl:apply-templates/>
<xsl:text>&#10;\end{center}</xsl:text>
<xsl:text>&#10;\caption{</xsl:text>
<xsl:choose> 
	<xsl:when test="title">
			 <xsl:call-template name="normalize-scape"> <xsl:with-param name="string" select="title"/></xsl:call-template>
	</xsl:when> 
	<xsl:otherwise>
		<xsl:text>RCAS: Please, add a title to figures</xsl:text>
	</xsl:otherwise> 
</xsl:choose>
<xsl:text>}&#10;</xsl:text>
<xsl:call-template name="label.id"/>
<xsl:text>\end{figure}&#10;</xsl:text>
</xsl:template>


<doc:template name="XSL template for programlisting within a figure" xmlns="">
	<refpurpose> XSL template for programlisting within a figure </refpurpose>
	<refdescription>
		<para>Outputs <literal>\begin{figure}</literal>,
		applies templates and outputs <literal>\end{abstract}</literal>. </para>
		<formalpara><title>Remarks and Bugs</title>
		<itemizedlist>
		</itemizedlist>
		</formalpara>
	</refdescription>
</doc:template>

<xsl:template match="figure[programlisting]">
<xsl:text>&#10;\begin{program}&#10;</xsl:text>
<xsl:apply-templates />
<xsl:text>&#10;\caption{</xsl:text>
<xsl:choose> 
	<xsl:when test="title">
			<xsl:call-template name="normalize-scape"> 
			 	<xsl:with-param name="string" select="title"/>
			</xsl:call-template>
	</xsl:when> 
	<xsl:otherwise>
		<xsl:text>RCAS: Please, add a title to figures</xsl:text>
	</xsl:otherwise> 
</xsl:choose>
<xsl:text>}&#10;</xsl:text>
<xsl:call-template name="label.id"/>
<xsl:text>&#10;\end{program}&#10;</xsl:text>
</xsl:template>

<xsl:template match="figure/title"> </xsl:template>
<xsl:template match="informalfigure/title"> </xsl:template>
</xsl:stylesheet>
