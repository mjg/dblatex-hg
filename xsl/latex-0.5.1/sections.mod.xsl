<?xml version='1.0'?>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$												
 |														
 |   PURPOSE: sections.
 |   PENDING:
 |	- Nested section|simplesect > 3 mapped to subsubsection*
 |    - No sectinfo (!)
 + ############################################################################## -->

<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
	exclude-result-prefixes="doc" version='1.0'>
 


<xsl:template match="sect1|sect2|sect3|sect4|sect5">
<xsl:call-template name="element.and.label"/>
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="sect1/title"/>
<xsl:template match="sect2/title"/>
<xsl:template match="sect3/title"/>
<xsl:template match="sect4/title"/>
<xsl:template match="sect5/title"/>

<xsl:template match="section">
<xsl:text>&#10;</xsl:text>
<xsl:variable name="level" select="count(ancestor::section)"/>
<xsl:choose>
		<xsl:when test='$level=0'>\section{ </xsl:when>
		<xsl:when test='$level=1'>\subsection{ </xsl:when>
		<xsl:when test='$level=2'>\subsubsection{ </xsl:when>
		<xsl:when test='$level=3'>\paragraph{ </xsl:when>
		<xsl:when test='$level=4'>\subparagraph{ </xsl:when>
		<xsl:otherwise> 
			<xsl:message>DB2LaTeX: recursive section|simplesect &gt; 5 Not  well Supported</xsl:message> 
			<xsl:text>\subparagraph*{ </xsl:text>
		</xsl:otherwise>
</xsl:choose>
<xsl:call-template name="title.and.label"/>
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="simplesect">
<xsl:text>&#10;</xsl:text>
<xsl:variable name="level" select="count(ancestor::section)"/>
<xsl:choose>
		<xsl:when test='$level=0'>\section*{ </xsl:when>
		<xsl:when test='$level=1'>\subsection*{ </xsl:when>
		<xsl:when test='$level=2'>\subsubsection*{ </xsl:when>
		<xsl:when test='$level=3'>\paragraph*{ </xsl:when>
		<xsl:when test='$level=4'>\subparagraph*{ </xsl:when>
		<xsl:otherwise> 
			<xsl:message>DB2LaTeX: recursive section|simplesect &gt; 5 Not  well Supported</xsl:message> 
			<xsl:text>\subparagraph*{ </xsl:text>
		</xsl:otherwise>
</xsl:choose>
<xsl:call-template name="title.and.label"/>
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="section/title"/>
<xsl:template match="simplesect/title"/>

<xsl:template match="sectioninfo"/>
<xsl:template match="sect1info"/>
<xsl:template match="sect2info"/>
<xsl:template match="sect3info"/>
<xsl:template match="sect4info"/>
<xsl:template match="sect5info"/>

</xsl:stylesheet>
