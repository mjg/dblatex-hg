<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template match="qandaset">
  <!-- is it displayed as a section? -->
  <xsl:variable name="title">
    <xsl:choose>
    <xsl:when test="title">
      <xsl:value-of select="title"/>
    </xsl:when>
    <xsl:when test="blockinfo/title">
      <xsl:value-of select="blockinfo/title"/>
    </xsl:when>
    <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="$title!=''">
    <xsl:call-template name="map.sect.level">
      <xsl:with-param name="level">
        <xsl:call-template name="get.sect.level"/>
      </xsl:with-param>
      <xsl:with-param name="num" select="'0'"/>
    </xsl:call-template>
    <xsl:text>{</xsl:text>
    <xsl:value-of select="$title"/>
    <xsl:text>}&#10;</xsl:text>
    <xsl:call-template name="label.id"/>
  </xsl:if>

  <xsl:apply-templates select="qandaentry|qandadiv"/>
</xsl:template>

<xsl:template match="qandaset/title"/>


<!-- ############
     # qandadiv #
     ############ -->

<xsl:template match="qandadiv/title"/>

<xsl:template match="qandadiv">
  <!-- display the title according the section depth -->
  <xsl:variable name="l">
    <xsl:value-of select="count(ancestor::qandadiv)"/>
  </xsl:variable>
  <xsl:variable name="lset">
    <xsl:call-template name="get.sect.level">
      <xsl:with-param name="n" select="ancestor::qandaset"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:call-template name="map.sect.level">
    <xsl:with-param name="level">
      <xsl:choose>
      <xsl:when test="ancestor::qandaset[title|blockinfo/title]">
        <xsl:value-of select="$l+$lset+1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$l+$lset"/>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:text>{</xsl:text>
  <xsl:value-of select="title"/>
  <xsl:text>}&#10;</xsl:text>
  <xsl:call-template name="label.id"/>

  <!-- if default label is a number, display the quandaentries
       like an enumerate list
    -->
  <xsl:apply-templates select="*[not(self::qandaentry)]"/>
  <xsl:if test="qandaentry">
    <xsl:if test="ancestor::qandaset[@defaultlabel='number']">
      <xsl:text>&#10;\begin{enumerate}&#10;</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="qandaentry"/>
    <xsl:if test="ancestor::qandaset[@defaultlabel='number']">
      <xsl:text>&#10;\end{enumerate}</xsl:text>
    </xsl:if>
  </xsl:if>
</xsl:template>


<!-- ##############
     # qandaentry #
     ############## -->

<!-- should be really processed -->
<xsl:template match="label"/>

<xsl:template match="qandaentry">
  <xsl:apply-templates select="question"/>
  <xsl:apply-templates select="answer"/>
</xsl:template>

<!--
     Here @defaultlabel='number' has priority on label use. It is not
     conformant to the docbook reference
  -->

<xsl:template match="question">
  <xsl:choose>
  <xsl:when test="ancestor::qandaset[@defaultlabel='number']">
    <xsl:text>\item </xsl:text>
  </xsl:when>
  <xsl:when test="label">
    <xsl:text>\textbf{</xsl:text>
    <xsl:value-of select="label"/>
    <xsl:text>}~</xsl:text>
  </xsl:when>
  <xsl:when test="ancestor::qandaset[@defaultlabel='qanda']">
    <xsl:text>\textbf{</xsl:text>
    <xsl:call-template name="gentext">
      <xsl:with-param name="key" select="'question'"/>
    </xsl:call-template>
    <xsl:text>}~</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>&#10;</xsl:text>
  </xsl:otherwise>
  </xsl:choose>

  <xsl:text>\textit{</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>

<xsl:template match="answer">
  <xsl:choose>
  <xsl:when test="ancestor::qandaset[@defaultlabel='number']">
    <!-- answers are other paragraphs of the enumerated entry -->
    <xsl:text>&#10;</xsl:text>
  </xsl:when>
  <xsl:when test="label">
    <xsl:text>&#10;\textbf{</xsl:text>
    <xsl:value-of select="label"/>
    <xsl:text>}~</xsl:text>
  </xsl:when>
  <xsl:when test="ancestor::qandaset[@defaultlabel='qanda']">
    <xsl:text>&#10;\textbf{</xsl:text>
    <xsl:call-template name="gentext">
      <xsl:with-param name="key" select="'answer'"/>
    </xsl:call-template>
    <xsl:text>}~</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>&#10;</xsl:text>
  </xsl:otherwise>
  </xsl:choose>

  <xsl:apply-templates/>
  <xsl:text>&#10;&#10;</xsl:text>
</xsl:template>


</xsl:stylesheet>
