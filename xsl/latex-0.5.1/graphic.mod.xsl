<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->


<xsl:template match="screenshot">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="screeninfo">
</xsl:template>


<xsl:template match="graphic[@fileref]">
	<xsl:text>\includegraphics{</xsl:text> <xsl:value-of select="normalize-space(@fileref)"/>}
</xsl:template>

<xsl:template match="graphic[@entityref]">
	<xsl:text>\includegraphics{</xsl:text> <xsl:value-of select="unparsed-entity-uri(@entityref)"/>}
</xsl:template>


<xsl:template match="inlinegraphic[@fileref]">
	<xsl:choose>
    	<xsl:when test="@format='linespecific'">
      	<a xml:link="simple" show="embed" actuate="auto" href="{@fileref}"/>
    	</xsl:when>
    	<xsl:otherwise>
		<xsl:text>\includegraphics{</xsl:text>
        	<xsl:if test="@align">
          		<!-- <xsl:attribute name="align"><xsl:value-of select="@align"/></xsl:attribute> -->
        	</xsl:if>
      	<xsl:value-of select="normalize-space(@fileref)"/>}
    	</xsl:otherwise>
  	</xsl:choose>
</xsl:template>

<xsl:template match="inlinegraphic[@entityref]">
	<xsl:choose>
    	<xsl:when test="@format='linespecific'">
      	<a xml:link="simple" show="embed" actuate="auto" href="{@fileref}"/>
    	</xsl:when>
    	<xsl:otherwise>
		<xsl:text>\includegraphics{</xsl:text>
        	<xsl:if test="@align">
          		<!-- <xsl:attribute name="align"><xsl:value-of select="@align"/></xsl:attribute> -->
        	</xsl:if>
      	<xsl:value-of select="unparsed-entity-uri(@entityref)"/>}
    	</xsl:otherwise>
  	</xsl:choose>
</xsl:template>
</xsl:stylesheet>
