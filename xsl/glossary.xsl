<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<!-- ############
     # glossary #
     ############ -->

<xsl:template match="glossary">
  <xsl:variable name="divs" select="glossdiv"/>
  <xsl:variable name="entries" select="glossentry"/>
  <xsl:variable name="preamble" select="*[not(self::title
                                          or self::subtitle
                                          or self::glossdiv
                                          or self::glossentry)]"/>
  <xsl:text>% --------	&#10;</xsl:text>
  <xsl:text>% GLOSSARY	&#10;</xsl:text>
  <xsl:text>% --------	&#10;</xsl:text>

  <!-- defined or default glossary title? -->
  <xsl:variable name="title">
    <xsl:choose>
    <xsl:when test="title">
      <xsl:call-template name="normalize-scape">
      <xsl:with-param name="string" select="title"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="gentext.element.name"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- find the appropriate section level -->
  <xsl:call-template name="map.sect.level">
    <xsl:with-param name="level">
      <xsl:call-template name="get.sect.level"/>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:text>{</xsl:text>
  <xsl:copy-of select="$title"/>
  <xsl:text>}&#10;</xsl:text>
  <xsl:call-template name="label.id"/>
  <xsl:if test="$preamble">
    <xsl:apply-templates select="$preamble"/>
  </xsl:if>
  <xsl:if test="$entries">
    <xsl:text>&#10;\noindent&#10;</xsl:text>
    <xsl:text>\begin{description}&#10;</xsl:text>
    <xsl:apply-templates select="$entries"/>
    <xsl:text>&#10;\end{description}&#10;</xsl:text>
  </xsl:if>
  <xsl:if test="$divs">
    <xsl:apply-templates select="$divs"/>
  </xsl:if>
</xsl:template>

<xsl:template match="glossary/glossaryinfo"/>
<xsl:template match="glossary/title"/>
<xsl:template match="glossary/subtitle"/>
<xsl:template match="glossary/titleabbrev"/>


<!-- ############
     # glossdiv #
     ############ -->

<xsl:template match="glossdiv">
  <!-- find the appropriate section level -->
  <xsl:variable name="l">
    <xsl:call-template name="get.sect.level">
      <xsl:with-param name="n" select="parent::glossary"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:call-template name="map.sect.level">
    <xsl:with-param name="level" select="$l+1"/>
  </xsl:call-template>
  <xsl:text>{</xsl:text>
  <xsl:copy-of select="title"/>
  <xsl:text>}&#10;</xsl:text>
  <xsl:call-template name="label.id"/>

  <!-- display the stuff before the entries -->
  <xsl:apply-templates select="*[not(self::glossentry)]"/>
  
  <!-- now, display the description list -->
  <xsl:text>&#10;\noindent&#10;</xsl:text>
  <xsl:text>\begin{description}&#10;</xsl:text>
  <xsl:apply-templates select="glossentry"/>
  <xsl:text>&#10;\end{description}&#10;</xsl:text>
</xsl:template>


<!-- #############
     # glosslist #
     ############# -->

<xsl:template match="glossdiv/title" />

<xsl:template match="glosslist">
  <xsl:text>&#10;\noindent&#10;</xsl:text>
  <xsl:text>\begin{description}&#10;</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>&#10;\end{description}&#10;</xsl:text>
</xsl:template>

<xsl:template match="glosslist/title" />
<xsl:template match="glosslist/blockinfo" />


<!-- ##############
     # glossentry #
     ############## -->

<xsl:template match="glossentry">
  <xsl:apply-templates/>
  <xsl:text>&#10;&#10;</xsl:text>
</xsl:template>

<xsl:template match="glossentry/glossterm">
  <xsl:text>\item[</xsl:text>
  <xsl:if test="../@id">
    <xsl:text>\hypertarget{</xsl:text>
    <xsl:value-of select="../@id"/>
    <xsl:text>}</xsl:text>
  </xsl:if>
  <xsl:text>{</xsl:text>
  <xsl:variable name="term">
    <xsl:apply-templates/>
  </xsl:variable>
  <xsl:value-of select="normalize-space($term)"/>
  <xsl:text>}] </xsl:text>
</xsl:template>

<xsl:template match="glossentry/acronym">
  <xsl:text> (\texttt{</xsl:text><xsl:apply-templates/><xsl:text>}) </xsl:text>
</xsl:template>
  
<xsl:template match="glossentry/abbrev">
  <xsl:text> [ </xsl:text><xsl:apply-templates/><xsl:text> ] </xsl:text> 
</xsl:template>

<!-- not printed -->
<xsl:template match="glossentry/revhistory"/>
  
<xsl:template match="glossentry/glossdef">
  <xsl:text>&#10;</xsl:text>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="glossseealso|glosssee">
  <xsl:variable name="otherterm" select="@otherterm"/>
  <xsl:variable name="targets" select="//node()[@id=$otherterm]"/>
  <xsl:variable name="target" select="$targets[1]"/>
  <xsl:variable name="text">
    <xsl:apply-templates/>
  </xsl:variable>
  <xsl:text> </xsl:text>
  <xsl:call-template name="gentext.element.name"/>
  <xsl:call-template name="gentext.space"/>
  <xsl:text>"</xsl:text>
  <xsl:choose>
    <xsl:when test="@otherterm">
      <xsl:text>\hyperlink{</xsl:text>
      <xsl:value-of select="@otherterm"/>
      <xsl:text>}{</xsl:text>
      <xsl:choose>
      <xsl:when test="$text!=''">
        <xsl:value-of select="$text"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$target" mode="xref"/>
      </xsl:otherwise>
      </xsl:choose>
      <xsl:text>}</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$text"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>". </xsl:text>
</xsl:template>

<xsl:template match="glossentry" mode="xref">
  <xsl:apply-templates select="./glossterm" mode="xref"/>
</xsl:template>

<xsl:template match="glossterm" mode="xref">
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>

