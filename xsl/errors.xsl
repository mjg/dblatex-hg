<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<xsl:template match="*">
  <xsl:message>*** No template for: <xsl:value-of select="name(.)"/></xsl:message>
  <xsl:text>% &lt;</xsl:text>
  <xsl:value-of select="name(.)"/>
  <xsl:text>&gt;&#10;</xsl:text>
  <xsl:apply-templates/> 
</xsl:template>

</xsl:stylesheet>
