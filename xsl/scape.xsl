<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    Feuille de style de transformation XML DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template match="text()">
  <xsl:call-template name="scape">
  <xsl:with-param name="string" select="."/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="text()" mode="latex.verbatim">
  <xsl:value-of select="."/> 
</xsl:template>

<xsl:template match="text()" mode="slash.hyphen">
  <xsl:choose>
  <xsl:when test="contains(.,'://')">
    <xsl:call-template name="scape">
    <xsl:with-param name="string">
      <xsl:value-of select="substring-before(.,'://')"/>
      <xsl:value-of select="'://'"/>
      <xsl:call-template name="string-replace">
      <xsl:with-param name="to">/\-</xsl:with-param>
      <xsl:with-param name="from">/</xsl:with-param>
      <xsl:with-param name="string" select="substring-after(.,'://')"/>
      </xsl:call-template></xsl:with-param>
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
    <xsl:call-template name="scape">
    <xsl:with-param name="string">
      <xsl:call-template name="string-replace">
      <xsl:with-param name="to">/\-</xsl:with-param>
      <xsl:with-param name="from">/</xsl:with-param>
      <xsl:with-param name="string" select="."/>
      </xsl:call-template></xsl:with-param>
    </xsl:call-template>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- To do: how to scape tabs? xt plants -->
<xsl:template match="text()" mode="latex.programlisting">
  <xsl:value-of select="."/> 
</xsl:template>

<xsl:template name="normalize-scape" >
  <xsl:param name="string"/>
  <xsl:variable name="result">
    <xsl:call-template name="scape">
      <xsl:with-param name="string" select="$string"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:value-of select="normalize-space($result)"/>
</xsl:template>


<xsl:template name="scape" >
  <xsl:param name="string"/>
  <xsl:call-template name="string-replace">
  <xsl:with-param name="to">$&lt;$</xsl:with-param>
  <xsl:with-param name="from">&lt;</xsl:with-param>
  <xsl:with-param name="string">
    <xsl:call-template name="string-replace">
    <xsl:with-param name="to">$&gt;$</xsl:with-param>
    <xsl:with-param name="from">&gt;</xsl:with-param>
    <xsl:with-param name="string">
      <xsl:call-template name="string-replace">
      <xsl:with-param name="to">\{</xsl:with-param>
      <xsl:with-param name="from">{</xsl:with-param>
      <xsl:with-param name="string">
        <xsl:call-template name="string-replace">
        <xsl:with-param name="to">\}</xsl:with-param>
        <xsl:with-param name="from">}</xsl:with-param>
        <xsl:with-param name="string">
          <xsl:call-template name="string-replace">
          <xsl:with-param name="to">\&amp;</xsl:with-param>
          <xsl:with-param name="from">&amp;</xsl:with-param>
          <xsl:with-param name="string">
            <xsl:call-template name="string-replace">
            <xsl:with-param name="to">\#</xsl:with-param>
            <xsl:with-param name="from">#</xsl:with-param>
            <xsl:with-param name="string">
              <xsl:call-template name="string-replace">
              <xsl:with-param name="to">\_</xsl:with-param>
              <xsl:with-param name="from">_</xsl:with-param>
              <xsl:with-param name="string">
                <xsl:call-template name="string-replace">
                <xsl:with-param name="to">\$</xsl:with-param>
                <xsl:with-param name="from">$</xsl:with-param>
                <xsl:with-param name="string">
                  <xsl:call-template name="string-replace">
                  <xsl:with-param name="to">\%</xsl:with-param>
                  <xsl:with-param name="from">%</xsl:with-param>
                  <xsl:with-param name="string" select="$string"></xsl:with-param>
                  </xsl:call-template>
                </xsl:with-param>
                </xsl:call-template></xsl:with-param>
              </xsl:call-template></xsl:with-param>
            </xsl:call-template></xsl:with-param>
          </xsl:call-template></xsl:with-param>
        </xsl:call-template></xsl:with-param>
      </xsl:call-template></xsl:with-param>
    </xsl:call-template></xsl:with-param>
  </xsl:call-template>
</xsl:template>


<!--  (c) David Carlisle
  replace all occurences of the character(s) `from'
       by the string `to' in the string `string'.
  -->
<xsl:template name="string-replace" >
  <xsl:param name="string"/>
  <xsl:param name="from"/>
  <xsl:param name="to"/>
  <xsl:choose>
    <xsl:when test="contains($string,$from)">
      <xsl:value-of select="substring-before($string,$from)"/>
      <xsl:value-of select="$to"/>
      <xsl:call-template name="string-replace">
        <xsl:with-param name="string" select="substring-after($string,$from)"/>
        <xsl:with-param name="from" select="$from"/>
        <xsl:with-param name="to" select="$to"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$string"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
