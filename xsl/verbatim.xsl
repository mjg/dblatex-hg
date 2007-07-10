<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<!-- Literal parameters -->
<xsl:param name="literal.width.ignore">0</xsl:param>
<xsl:param name="literal.layout.options"/>
<xsl:param name="literal.lines.showall">1</xsl:param>


<xsl:template name="verbatim.setup">
  <xsl:apply-templates select="//screen|//programlisting"
                       mode="save.verbatim.preamble"/>
</xsl:template>

<xsl:template match="address|literallayout|literallayout[@class='monospaced']">
  <xsl:call-template name="output.verbatim"/>
</xsl:template>

<xsl:template match="text()" mode="save.verbatim"/>

<xsl:template match="address|literallayout|literallayout[@class='monospaced']"
              mode="save.verbatim">
  <xsl:call-template name="save.verbatim"/>
</xsl:template>

<xsl:template name="save.verbatim">
  <xsl:param name="content">
    <xsl:apply-templates mode="latex.verbatim"/>
  </xsl:param>
  <xsl:text>&#10;\begin{SaveVerbatim}{</xsl:text>
  <xsl:value-of select="generate-id()"/>
  <xsl:text>}&#10;</xsl:text>
  <xsl:value-of select="$content"/>
  <xsl:text>&#10;\end{SaveVerbatim}&#10;</xsl:text>
</xsl:template>

<xsl:template name="output.verbatim">
  <xsl:param name="content">
    <xsl:apply-templates mode="latex.verbatim"/>
  </xsl:param>
  <!-- In tables just use the data previously saved -->
  <xsl:choose>
  <xsl:when test="ancestor::entry|
                  ancestor::legalnotice">
    <xsl:text>\UseVerbatim{</xsl:text>
    <xsl:value-of select="generate-id(.)"/>
    <xsl:text>}</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>&#10;\begin{verbatim}</xsl:text>
    <xsl:value-of select="$content"/>
    <xsl:text>\end{verbatim}&#10;</xsl:text>
  </xsl:otherwise>
  </xsl:choose>
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

  <!-- get the listing escape sequence if needed -->
  <xsl:variable name="co-tagin">
    <xsl:if test="descendant::co|
                  descendant::footnote">
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


<!-- Global listing saving, for listings in footnotes, since we never know
     in which context the footnotes are used. A check is done to not cover
     the other saving points in tables. -->

<xsl:template match="programlisting|screen"
              mode="save.verbatim.preamble">
  <xsl:if test="not(ancestor::table or ancestor::informaltable) and
                ancestor::footnote">
    <xsl:apply-templates select="." mode="save.verbatim"/>
  </xsl:if>
</xsl:template>


<!-- Listings does not work in tables, even for external files. So, we
     use the fancyvrb verbatim coupled to listings for the rendering stuff.
     This mode assumes that all the verbatim data is in an external
     file. Using the save/use commands would work except for linenumbering
     stuff. -->

<xsl:template match="programlisting|screen"
              mode="save.verbatim">
  <xsl:if test="not(descendant::imagedata[@format='linespecific']|
                    descendant::inlinegraphic[@format='linespecific']|
                    descendant::textdata)">
    <xsl:variable name="str1" select="."/>
    <xsl:variable name="str">
      <xsl:apply-templates mode="latex.programlisting"/>
    </xsl:variable>

    <xsl:text>\begin{VerbatimOut}{tmplst-</xsl:text>
    <xsl:value-of select="generate-id()"/>
    <xsl:text>}</xsl:text>
    <!-- some text just after the open tag must be put on a new line -->
    <xsl:if test="not(contains($str1,'&#10;')) or
           string-length(normalize-space(substring-before($str1,'&#10;')))&gt;0">
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
    <xsl:value-of select="$str"/>
    <!-- put a \n only if needed -->
    <xsl:if test="substring($str1,string-length($str1))!='&#10;' and
                  string-length(substring-after(
                    concat(substring-after($str1,normalize-space($str1)),'&#10;'),
                    '&#10;'))=0">
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
    <xsl:text>\end{VerbatimOut}&#10;</xsl:text>
  </xsl:if>
</xsl:template>


<xsl:template match="programlisting[ancestor::entry or
                                    ancestor::entrytbl or
                                    ancestor::footnote]|
                     screen[ancestor::entry or
                            ancestor::entrytbl or
                            ancestor::footnote]">

  <xsl:variable name="lsopt">
    <!-- language option is only for programlisting -->
    <xsl:if test="@language">
      <xsl:text>language=</xsl:text>
      <xsl:value-of select="@language"/>
      <xsl:text>,</xsl:text>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="fvopt">
    <!-- print line numbers -->
    <xsl:if test="@linenumbering='numbered'">
      <xsl:text>numbers=left,</xsl:text>
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
    </xsl:if>
    <!-- TODO: TeX delimiters if <co>s are embedded -->
  </xsl:variable>

  <xsl:text>\begin{fvlisting}</xsl:text>
  <xsl:if test="$lsopt!=''">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="$lsopt"/>
    <xsl:text>]</xsl:text>
  </xsl:if>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>\VerbatimInput</xsl:text>
  <xsl:if test="$fvopt!=''">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="$fvopt"/>
    <xsl:text>]</xsl:text>
  </xsl:if>

  <xsl:text>{</xsl:text>
  <xsl:choose>
  <xsl:when test="descendant::imagedata[@format='linespecific']|
                  descendant::inlinegraphic[@format='linespecific']|
                  descendant::textdata">
    <!-- the listing content is in a (real) external file -->
    <xsl:apply-templates
        select="descendant::imagedata|descendant::inlinegraphic|
                descendant::textdata"
        mode="filename.abs.get"/>
  </xsl:when>
  <xsl:otherwise>
    <!-- the listing is outputed in a temporary file -->
    <xsl:text>tmplst-</xsl:text>
    <xsl:value-of select="generate-id(.)"/>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:text>}&#10;</xsl:text>

  <xsl:text>\end{fvlisting}&#10;</xsl:text>

</xsl:template>


<xsl:template match="*" mode="filename.abs.get">
  <xsl:choose>
  <xsl:when test="@entityref">
    <xsl:value-of select="unparsed-entity-uri(@entityref)"/>
  </xsl:when>
  <xsl:when test="contains(@fileref, ':')">
    <!-- absolute uri scheme -->
    <xsl:value-of select="substring-after(@fileref, ':')"/>
  </xsl:when>
  <xsl:when test="starts-with(@fileref, '/')">
    <!-- absolute unix like path -->
    <xsl:value-of select="@fileref"/>
  </xsl:when>
  <xsl:otherwise>
    <!-- relative to the doc directory -->
    <xsl:value-of select="$current.dir"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="@fileref"/>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
