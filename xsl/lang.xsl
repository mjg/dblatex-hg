<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template name="babel.setup">
  <!-- babel use? -->
  <xsl:if test="$latex.babel.use='1'">
    <xsl:variable name="babel">
      <xsl:call-template name="babel.language">
        <xsl:with-param name="lang">
          <xsl:call-template name="l10n.language">
            <xsl:with-param name="target" select="(/set|/book|/article)[1]"/>
            <xsl:with-param name="xref-context" select="true()"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$babel!=''">
      <xsl:text>\usepackage[</xsl:text>
      <xsl:value-of select="$babel"/>
      <xsl:text>]{babel}&#10;</xsl:text>
    </xsl:if>
  </xsl:if>
</xsl:template>

<xsl:template name="lang.setup">
  <!-- first find the language actually set -->
  <xsl:variable name="lang">
    <xsl:call-template name="l10n.language">
      <xsl:with-param name="target" select="(/set|/book|/article)[1]"/>
      <xsl:with-param name="xref-context" select="true()"/>
    </xsl:call-template>
  </xsl:variable>

  <!-- locale setup for docbook -->
  <xsl:if test="$lang!='' and $lang!='en'">
    <xsl:text>\setuplocale{</xsl:text>
    <xsl:value-of select="$lang"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>

  <!-- some extra babel setup -->
  <xsl:if test="$latex.babel.use='1'">
    <xsl:variable name="babel">
      <xsl:call-template name="babel.language">
        <xsl:with-param name="lang" select="$lang"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$babel!=''">
      <xsl:text>\setupbabel{</xsl:text>
      <xsl:value-of select="$lang"/>
      <xsl:text>}&#10;</xsl:text>
    </xsl:if>
  </xsl:if>
</xsl:template>


<xsl:template name="babel.language">
  <xsl:param name="lang" select="'en'"/>

  <!-- select the corresponding babel language -->
  <xsl:choose>
    <xsl:when test="$latex.babel.language!=''">
      <xsl:value-of select="$latex.babel.language"/>
    </xsl:when>
    <xsl:when test="starts-with($lang,'af')">afrikaans</xsl:when>
    <xsl:when test="starts-with($lang,'br')">breton</xsl:when>
    <xsl:when test="starts-with($lang,'ca')">catalan</xsl:when>
    <xsl:when test="starts-with($lang,'cs')">czech</xsl:when>
    <xsl:when test="starts-with($lang,'cy')">welsh</xsl:when>
    <xsl:when test="starts-with($lang,'da')">danish</xsl:when>
    <xsl:when test="starts-with($lang,'de')">ngerman</xsl:when>
    <xsl:when test="starts-with($lang,'el')">greek</xsl:when>
    <xsl:when test="starts-with($lang,'en')">
      <xsl:choose>
        <xsl:when test="starts-with($lang,'en-CA')">canadian</xsl:when>
        <xsl:when test="starts-with($lang,'en-GB')">british</xsl:when>
        <xsl:when test="starts-with($lang,'en-US')">USenglish</xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="starts-with($lang,'eo')">esperanto</xsl:when>
    <xsl:when test="starts-with($lang,'es')">spanish</xsl:when>
    <xsl:when test="starts-with($lang,'et')">estonian</xsl:when>
    <xsl:when test="starts-with($lang,'fi')">finnish</xsl:when>
    <xsl:when test="starts-with($lang,'fr')">french</xsl:when>
    <xsl:when test="starts-with($lang,'ga')">irish</xsl:when>
    <xsl:when test="starts-with($lang,'gd')">scottish</xsl:when>
    <xsl:when test="starts-with($lang,'gl')">galician</xsl:when>
    <xsl:when test="starts-with($lang,'he')">hebrew</xsl:when>
    <xsl:when test="starts-with($lang,'hr')">croatian</xsl:when>
    <xsl:when test="starts-with($lang,'hu')">hungarian</xsl:when>
    <xsl:when test="starts-with($lang,'id')">bahasa</xsl:when>
    <xsl:when test="starts-with($lang,'it')">italian</xsl:when>
    <xsl:when test="starts-with($lang,'nl')">dutch</xsl:when>
    <xsl:when test="starts-with($lang,'nn')">norsk</xsl:when>
    <xsl:when test="starts-with($lang,'pl')">polish</xsl:when>
    <xsl:when test="starts-with($lang,'pt')">
      <xsl:choose>
        <xsl:when test="starts-with($lang,'pt-BR')">brazil</xsl:when>
        <xsl:otherwise>portugese</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="starts-with($lang,'ro')">romanian</xsl:when>
    <xsl:when test="starts-with($lang,'ru')">russian</xsl:when>
    <xsl:when test="starts-with($lang,'sk')">slovak</xsl:when>
    <xsl:when test="starts-with($lang,'sl')">slovene</xsl:when>
    <xsl:when test="starts-with($lang,'sv')">swedish</xsl:when>
    <xsl:when test="starts-with($lang,'tr')">turkish</xsl:when>
    <xsl:when test="starts-with($lang,'uk')">ukrainian</xsl:when>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
