<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->

<xsl:template match="latex">
<xsl:value-of select="."/>
</xsl:template>

<xsl:template match="tex">
<xsl:value-of select="."/>
</xsl:template>

<xsl:template match="latex[@fileref]">
<xsl:text>\input{</xsl:text><xsl:value-of select="@fileref"/><xsl:text>}&#10;</xsl:text>
</xsl:template>

<xsl:template match="tex[@fileref]">
<xsl:text>\input{</xsl:text><xsl:value-of select="@fileref"/><xsl:text>}&#10;</xsl:text>
</xsl:template>


<xsl:template match="tm[@fileref]">
<xsl:text>\input{</xsl:text><xsl:value-of select="@fileref"/><xsl:text>}&#10;</xsl:text>
</xsl:template>

<xsl:template match="tm[@tex]">
<xsl:value-of select="@tex"/>
</xsl:template>

<xsl:template match="inlinetm[@fileref]">
<xsl:text>\input{</xsl:text><xsl:value-of select="@fileref"/><xsl:text>}&#10;</xsl:text>
</xsl:template>

<xsl:template match="inlinetm[@tex]">
<xsl:value-of select="@tex"/>
</xsl:template>
</xsl:stylesheet>
