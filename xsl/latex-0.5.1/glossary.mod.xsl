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


<xsl:template match="glossary">
<xsl:variable name="divs" select="glossdiv"/>
<xsl:variable name="entries" select="glossentry"/>
<xsl:variable name="preamble" select="*[not(self::title
                            or self::subtitle
                            or self::glossdiv
                            or self::glossentry)]"/>
<!-- \printglossary -->
<xsl:text>% -------------------------------------------	&#10;</xsl:text>
<xsl:text>%	&#10;</xsl:text>
<xsl:text>% GLOSSARY	&#10;</xsl:text>
<xsl:text>%	&#10;</xsl:text>
<xsl:text>%	&#10;</xsl:text>
<xsl:text>% -------------------------------------------	&#10;</xsl:text>
<xsl:variable name="normalized.title">
	<xsl:choose>
	<xsl:when test="./title">
		<xsl:call-template name="normalize-scape">
		<xsl:with-param name="string" select="title"/>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="gentext.element.name"/>
	</xsl:otherwise>
	</xsl:choose>
</xsl:variable>
<xsl:choose>
<xsl:when test="local-name(..)='book' or local-name(..)='part'">
	<xsl:text>\chapter*{</xsl:text><xsl:copy-of select="$normalized.title"/><xsl:text>}&#10;</xsl:text>
</xsl:when>
<xsl:otherwise>
	<xsl:text>\section*{</xsl:text><xsl:copy-of select="$normalized.title"/><xsl:text>}&#10;</xsl:text>
</xsl:otherwise>
</xsl:choose>
<xsl:call-template name="label.id"/>
<xsl:if test="./subtitle"><xsl:apply-templates select="./subtitle" mode="component.title.mode"/> </xsl:if>
<xsl:if test="$preamble"> <xsl:apply-templates select="$preamble"/> </xsl:if>
<xsl:if test="$divs"> <xsl:apply-templates select="$divs"/> </xsl:if>
<xsl:if test="$entries"> <xsl:apply-templates select="$entries"/></xsl:if>
</xsl:template>


<xsl:template match="glossary/glossaryinfo"/>
<xsl:template match="glossary/title"/>
<xsl:template match="glossary/subtitle"/>
<xsl:template match="glossary/titleabbrev"/>
<xsl:template match="glossary/title" 	mode="component.title.mode"> <xsl:apply-templates/> </xsl:template>
<xsl:template match="glossary/subtitle" 	mode="component.title.mode"> <xsl:apply-templates/> </xsl:template>


<xsl:template match="glosslist">
<xsl:call-template name="label.id"/>
<!-- \begin{itemizedlist} -->
      <xsl:apply-templates/>
<!-- \end{itemizedlist} -->
</xsl:template>


<xsl:template match="glossdiv">
<xsl:variable name="normalized.title">
	<xsl:call-template name="normalize-scape">
	<xsl:with-param name="string" select="title"/>
	</xsl:call-template>
</xsl:variable>
<xsl:choose>
<xsl:when test="local-name(..)='book' or local-name(..)='part'">
	<xsl:text>\section*{</xsl:text><xsl:copy-of select="$normalized.title"/><xsl:text>}&#10;</xsl:text>
</xsl:when>
<xsl:otherwise>
	<xsl:text>\subsection*{</xsl:text><xsl:copy-of select="$normalized.title"/><xsl:text>}&#10;</xsl:text>
</xsl:otherwise>
</xsl:choose>
<xsl:text>&#10;\noindent&#10;</xsl:text>
<xsl:text>\begin{description}</xsl:text>
<xsl:call-template name="label.id"/>
<xsl:apply-templates/>
<xsl:text>\end{description}&#10;</xsl:text>
</xsl:template>



<xsl:template match="glossdiv/title" />

<xsl:template match="glossentry">
<xsl:apply-templates/>
<xsl:text>&#10;&#10;</xsl:text>
</xsl:template>
 
<xsl:template match="glossentry/glossterm">
<xsl:text>\item[</xsl:text>
	<xsl:call-template name="normalize-scape">
		<xsl:with-param name="string" select="."/> </xsl:call-template>
<xsl:text>]  </xsl:text>
</xsl:template>

<xsl:template match="glossentry/acronym">
<xsl:text> ( {\tt </xsl:text> <xsl:apply-templates/> <xsl:text>} ) </xsl:text>
</xsl:template>
  
<xsl:template match="glossentry/abbrev">
<xsl:text> [ </xsl:text> <xsl:apply-templates/> <xsl:text> ] </xsl:text> 
</xsl:template>
  
<xsl:template match="glossentry/revhistory">
</xsl:template>
  
<xsl:template match="glossentry/glosssee">
<xsl:variable name="otherterm" select="@otherterm"/>
<xsl:variable name="targets" select="//node()[@id=$otherterm]"/>
<xsl:variable name="target" select="$targets[1]"/>
<xsl:text> </xsl:text>
<xsl:call-template name="gentext.element.name"/>
<xsl:call-template name="gentext.space"/>
<xsl:text> </xsl:text>
<xsl:choose>
	<xsl:when test="@otherterm">
		<xsl:text> </xsl:text>
		<xsl:text>(</xsl:text>
		<xsl:copy-of select="normalize-space(@otherterm)"/>
		<xsl:text>)</xsl:text>
		<xsl:apply-templates select="$target" mode="xref"/>
        </xsl:when>
        <xsl:otherwise>
		<xsl:apply-templates/>
	</xsl:otherwise>
</xsl:choose>
<xsl:text>. </xsl:text>
</xsl:template>


<xsl:template match="glossentry/glossdef">
<xsl:text>&#10;</xsl:text>
<xsl:apply-templates/>
</xsl:template>


<xsl:template match="glossseealso">
<xsl:variable name="otherterm" select="@otherterm"/>
<xsl:variable name="targets" select="//node()[@id=$otherterm]"/>
<xsl:variable name="target" select="$targets[1]"/>
<xsl:call-template name="gentext.element.name"/>
<xsl:text> </xsl:text>
<xsl:call-template name="gentext.space"/>
<xsl:text> </xsl:text>
<xsl:choose>
	<xsl:when test="@otherterm">
		<xsl:text> </xsl:text>
		<xsl:text>(</xsl:text>
		<xsl:copy-of select="normalize-space(@otherterm)"/>
		<xsl:text>)</xsl:text>
            	<xsl:apply-templates select="$target" mode="xref"/>
	</xsl:when>
	<xsl:otherwise>
        	<xsl:apply-templates/>
	</xsl:otherwise>
</xsl:choose>
<xsl:text>. </xsl:text>
</xsl:template>


<xsl:template match="glossentry" mode="xref">
<xsl:apply-templates select="./glossterm" mode="xref"/>
</xsl:template>

<xsl:template match="glossterm" mode="xref">
<xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>
