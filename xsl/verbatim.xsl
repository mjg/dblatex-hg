<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->


<xsl:template match="screen|address|literallayout|literallayout[@class='monospaced']">
  <xsl:text>&#10;\begin{verbatim}</xsl:text>
  <xsl:apply-templates mode="latex.verbatim"/>
  <xsl:text>\end{verbatim}&#10;</xsl:text>
</xsl:template>

<xsl:template match="programlisting">
  <xsl:variable name="env">
    <xsl:choose>
    <xsl:when test="@linenumbering='numbered'">Verbatim</xsl:when>
    <xsl:otherwise>verbatim</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="opt">
    <xsl:if test="@linenumbering='numbered'">
      <xsl:text>numbers=left</xsl:text>
    </xsl:if>
  </xsl:variable>

  <xsl:text>&#10;\begin{</xsl:text>
  <xsl:value-of select="$env"/>
  <xsl:text>}</xsl:text>
  <xsl:if test="$opt!=''">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="$opt"/>
    <xsl:text>]&#10;</xsl:text>
  </xsl:if>
  <xsl:apply-templates mode="latex.programlisting"/>
  <xsl:text>\end{</xsl:text>
  <xsl:value-of select="$env"/>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>


<!-- sans doute a reprendre
<xsl:template match="literal">
<xsl:text>{\verb </xsl:text>
<xsl:apply-templates mode="latex.verbatim"/>
<xsl:text>}</xsl:text>
</xsl:template>
-->
</xsl:stylesheet>
