<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->


<xsl:template match="qandaset">
</xsl:template>

<xsl:template match="qandaset/title">
</xsl:template>

<xsl:template match="qandadiv">
</xsl:template>

<xsl:template match="qandadiv/title">
</xsl:template>

<xsl:template match="qandaentry">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="question">
</xsl:template>

<xsl:template match="answer">
</xsl:template>

<xsl:template match="label">
</xsl:template>

</xsl:stylesheet>
