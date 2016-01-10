<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->


<xsl:template match="processing-instruction()"/>

<!-- Raw latex text, e.g "<?latex \sloppy ?>" -->
<xsl:template match="processing-instruction('latex')">
  <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="processing-instruction('db2latex')">
  <xsl:value-of select="."/>
</xsl:template>

<!-- ==================================================================== -->
<!-- The bibtex PI.  -->

<xsl:template name="pi.bibtex_bibfiles">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="pi-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('bibtex')"/>
    <xsl:with-param name="attribute" select="'bibfiles'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.bibtex_bibstyle">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="pi-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('bibtex')"/>
    <xsl:with-param name="attribute" select="'bibstyle'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.bibtex_mode">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="pi-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('bibtex')"/>
    <xsl:with-param name="attribute" select="'mode'"/>
  </xsl:call-template>
</xsl:template>


</xsl:stylesheet>
