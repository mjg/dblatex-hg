<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<!-- Literal parameters -->
<xsl:param name="literal.width.ignore">0</xsl:param>
<xsl:param name="literal.layout.options"/>
<xsl:param name="literal.lines.showall">1</xsl:param>


<xsl:template match="address|literallayout|literallayout[@class='monospaced']">
  <xsl:text>&#10;\begin{verbatim}</xsl:text>
  <xsl:apply-templates mode="latex.verbatim"/>
  <xsl:text>\end{verbatim}&#10;</xsl:text>
</xsl:template>

<!-- Special cases where nothing to output in verbatim mode -->
<xsl:template match="alt" mode="latex.verbatim"/>

<!-- Returns the filename from @fileref or @entityref attribute -->
<xsl:template match="*" mode="filename.get">
  <xsl:choose>
  <xsl:when test="@entityref">
    <xsl:value-of select="unparsed-entity-uri(@entityref)"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="@fileref"/>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- The following templates now works only with the listings package -->

<!-- The listing content is internal to the element, and is not a reference
     to an external file -->

<xsl:template match="programlisting|screen" mode="internal">
  <xsl:param name="opt"/>
  <xsl:param name="co-tagin"/>
  <xsl:param name="rnode" select="/"/>

  <xsl:variable name="env" select="'lstlisting'"/>

  <xsl:text>&#10;\begin{</xsl:text>
  <xsl:value-of select="$env"/>
  <xsl:text>}</xsl:text>
  <xsl:if test="$opt!=''">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="$opt"/>
    <xsl:text>]</xsl:text>
  </xsl:if>
  <!-- some text just after the open tag must be put on a new line -->
  <xsl:if test="not(contains(.,'&#10;')) or
                string-length(normalize-space(substring-before(.,'&#10;')))&gt;0">
    <xsl:text>&#10;</xsl:text>
  </xsl:if>
  <xsl:apply-templates mode="latex.programlisting">
    <xsl:with-param name="co-tagin" select="$co-tagin"/>
    <xsl:with-param name="rnode" select="$rnode"/>
  </xsl:apply-templates>
  <xsl:text>\end{</xsl:text>
  <xsl:value-of select="$env"/>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>
 
<xsl:template match="programlisting|screen">
  <xsl:param name="rnode" select="/"/>

  <!-- formula to compute the listing width -->
  <xsl:variable name="width">
    <xsl:if test="$literal.width.ignore='0' and
                  @width and string(number(@width))!='NaN'">
      <xsl:text>\setlength{\lstwidth}{</xsl:text>
      <xsl:value-of select="@width"/>
      <xsl:text>\lstcharwidth+2\lstframesep}</xsl:text>
    </xsl:if>
  </xsl:variable>

  <!-- get the listing co escape sequence if needed -->
  <xsl:variable name="co-tagin">
    <xsl:if test="descendant::co">
      <xsl:call-template name="co-tagin-gen"/>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="opt">
    <!-- skip empty endlines -->
    <xsl:if test="$literal.lines.showall='0'">
      <xsl:text>showlines=false,</xsl:text>
    </xsl:if>
    <!-- language option is only for programlisting -->
    <xsl:if test="@language">
      <xsl:text>language=</xsl:text>
      <xsl:value-of select="@language"/>
      <xsl:text>,</xsl:text>
    </xsl:if>
    <!-- listing width -->
    <xsl:if test="$width!=''">
      <xsl:text>linewidth=\lstwidth,</xsl:text>
    </xsl:if>
    <!-- print line numbers -->
    <xsl:if test="@linenumbering='numbered'">
      <xsl:text>numbers=left,</xsl:text>
    </xsl:if>
    <!-- find the fist line number to print -->
    <xsl:choose>
    <xsl:when test="@startinglinenumber">
      <xsl:text>firstnumber=</xsl:text>
      <xsl:value-of select="@startinglinenumber"/>
      <xsl:text>,</xsl:text>
    </xsl:when>
    <xsl:when test="@continuation and (@continuation='continues')">
      <!-- ask for continuation -->
      <xsl:text>firstnumber=last</xsl:text>
      <xsl:text>,</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <!-- explicit restart numbering -->
      <xsl:text>firstnumber=1</xsl:text>
      <xsl:text>,</xsl:text>
    </xsl:otherwise>
    </xsl:choose>
    <!-- TeX delimiters if <co>s are embedded -->
    <xsl:if test="$co-tagin!=''">
      <xsl:text>escapeinside={</xsl:text>
      <xsl:value-of select="$co-tagin"/>
      <xsl:text>}{</xsl:text>
      <xsl:value-of select="$co.tagout"/>
      <xsl:text>},</xsl:text>
    </xsl:if>
  </xsl:variable>

  <!-- put the listing with formula here -->
  <xsl:if test="$width!=''">
    <xsl:text>&#10;</xsl:text>
    <xsl:value-of select="$width"/>
  </xsl:if>
  <xsl:choose>
  <xsl:when test="descendant::imagedata[@format='linespecific']|
                  descendant::inlinegraphic[@format='linespecific']|
                  descendant::textdata">
    <!-- the listing content is in an external file -->
    <xsl:text>&#10;\lstinputlisting</xsl:text>
    <xsl:if test="$opt!=''">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="$opt"/>
      <xsl:text>]</xsl:text>
    </xsl:if>
    <xsl:text>{</xsl:text>
    <xsl:apply-templates
        select="descendant::imagedata|descendant::inlinegraphic|
                descendant::textdata"
        mode="filename.get"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <!-- the listing content is internal -->
    <xsl:apply-templates select="." mode="internal">
      <xsl:with-param name="rnode" select="$rnode"/>
      <xsl:with-param name="co-tagin" select="$co-tagin"/>
      <xsl:with-param name="opt" select="$opt"/>
    </xsl:apply-templates>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- sans doute a reprendre
<xsl:template match="literal">
<xsl:text>{\verb </xsl:text>
<xsl:apply-templates mode="latex.verbatim"/>
<xsl:text>}</xsl:text>
</xsl:template>
-->
</xsl:stylesheet>
