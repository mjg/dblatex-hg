<?xml version='1.0' encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template match="anchor">
  <xsl:call-template name="label.id"/>
</xsl:template>

<xsl:template match="xref">
  <xsl:variable name="target" select="id(@linkend)[1]"/>
  <xsl:call-template name="check.id.unique">
    <xsl:with-param name="linkend" select="@linkend"/>
  </xsl:call-template>

  <xsl:choose>
  <xsl:when test="count($target)=0">
    <xsl:message>
    <xsl:text>*** Error: xref to nonexistent id: </xsl:text>
    <xsl:value-of select="@linkend"/>
    </xsl:message>
    <xsl:text>[?]</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:variable name="text">
      <xsl:choose>
      <!-- If there is an endterm -->
      <xsl:when test="@endterm">
        <xsl:variable name="etarget" select="id(@endterm)[1]"/>
        <xsl:choose>
        <xsl:when test="count($etarget) = 0">
          <xsl:message>
            <xsl:value-of select="count($etargets)"/>
            <xsl:text>*** Error: endterm points to nonexistent ID: </xsl:text>
            <xsl:value-of select="@endterm"/>
          </xsl:message>
          <xsl:text>[NONEXISTENT ID]</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="$etarget" mode="xref.text"/>
        </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- If an xreflabel has been specified for the target -->
      <xsl:when test="$target/@xreflabel">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="$target/@xreflabel"/>
        <xsl:text>"</xsl:text>
      </xsl:when>
      <!-- nothing specified -->
      <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>

    <!-- how to print it -->
    <xsl:choose>
    <xsl:when test="$text!=''">
      <xsl:text>\hyperlink{</xsl:text>
      <xsl:value-of select="@linkend"/>
      <xsl:text>}{</xsl:text>
      <xsl:value-of select="$text"/>
      <xsl:text>}</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="$target" mode="xref-to"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="ulink">
  <xsl:choose>
  <xsl:when test=".=''">
    <xsl:text>\url{</xsl:text>
    <xsl:value-of select="@url"/>
    <xsl:text>}</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>\href{</xsl:text>
    <xsl:value-of select="@url"/>
    <xsl:text>}{</xsl:text>
    <!-- LaTeX chars are scaped. Each / except the :// is mapped to a /\- -->
    <xsl:apply-templates mode="slash.hyphen"/>
    <xsl:text>}</xsl:text>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- it now works thanks to "hyperlabel" -->

<xsl:template match="link">
  <xsl:text>\hyperlink{</xsl:text>
  <xsl:value-of select="@linkend"/> 
  <xsl:text>}{</xsl:text>
  <xsl:choose>
  <xsl:when test=".!=''">
    <xsl:call-template name="normalize-scape">
      <xsl:with-param name="string">
        <xsl:copy-of select="."/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
    <xsl:copy-of select="id(@endterm)[1]"/>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="olink">
  <xsl:apply-templates/>
</xsl:template>

<!-- Text of endterm xref must be managed with the text() function to support
     the special latex characters -->

<xsl:template match="*" mode="xref.text">
  <xsl:apply-templates/>
</xsl:template>

<!-- ###########################
     # Format display (%n, %t) #
     ########################### -->

<xsl:template name="number.xref">
  <xsl:text>\ref{</xsl:text><xsl:value-of select="@id"/><xsl:text>}</xsl:text>
</xsl:template>

<xsl:template name="title.xref">
  <xsl:param name="target" select="."/>
  <xsl:choose>
  <xsl:when test="name($target) = 'figure'
                  or name($target) = 'example'
                  or name($target) = 'equation'
                  or name($target) = 'table'
                  or name($target) = 'dedication'
                  or name($target) = 'preface'
                  or name($target) = 'bibliography'
                  or name($target) = 'glossary'
                  or name($target) = 'index'
                  or name($target) = 'setindex'
                  or name($target) = 'colophon'">
    <!-- xsl:call-template name="gentext.startquote"/ -->
    <xsl:text>"</xsl:text>
    <xsl:apply-templates select="$target" mode="title.content"/>
    <!-- xsl:call-template name="gentext.endquote"/ -->
    <xsl:text>"</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>\emph{</xsl:text>
    <xsl:apply-templates select="$target" mode="title.content"/>
    <xsl:text>}</xsl:text>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ###########################
     # Cross-reference display #
     ########################### -->

<xsl:variable name="xref.default.template" select="'%g %n'"/>

<xsl:template name="cross-reference">
  <xsl:param name="target" select="."/>
  <xsl:param name="refelem" select="local-name($target)"/>
  <!-- get the xref template -->
  <xsl:param name="xref.text">
    <xsl:call-template name="gentext.xref.text">
      <xsl:with-param name="element.name" select="$refelem"/>
      <xsl:with-param name="default" select="$xref.default.template"/>
    </xsl:call-template>
  </xsl:param>
  <!-- xref template substitution -->
  <xsl:call-template name="subst.xref.text">
    <xsl:with-param name="xref.text" select="$xref.text"/>
    <xsl:with-param name="target" select="$target"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="title-link-to">
  <xsl:param name="target" select="."/>
  <xsl:text>\hyperlink{</xsl:text>
  <xsl:value-of select="$target/@id"/>
  <xsl:text>}{</xsl:text>
  <xsl:choose>
  <xsl:when test="$target/title">
    <xsl:apply-templates select="$target/title" mode="xref"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>[no title]</xsl:text>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="*" mode="xref-to">
  <xsl:param name="target" select="."/>
  <xsl:param name="refelem" select="local-name($target)"/>
  <xsl:message>
    <xsl:text>*** Error: no gentext to create for xref to: "</xsl:text>
    <xsl:value-of select="$refelem"/>
    <xsl:text>"</xsl:text>
  </xsl:message>
  <xsl:text>[?</xsl:text><xsl:value-of select="$refelem"/><xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="step" mode="xref-to">
  <xsl:call-template name="cross-reference"/>
</xsl:template>

<xsl:template match="title" mode="xref">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="book" mode="xref-to">
  <xsl:text>\emph{</xsl:text>
  <xsl:choose>
  <xsl:when test="title">
    <xsl:apply-templates select="title" mode="xref"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates select="bookinfo/title" mode="xref"/>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="dedication|preface|part|chapter|appendix" mode="xref-to">
  <xsl:call-template name="cross-reference"/>
</xsl:template>

<xsl:template match="section|simplesect
                     |sect1|sect2|sect3|sect4|sect5
                     |refsect1|refsect2|refsect3" mode="xref-to">
  <xsl:call-template name="cross-reference"/>
</xsl:template>

<xsl:template match="figure|example|table|equation" mode="xref-to">
  <xsl:call-template name="cross-reference"/>
</xsl:template>

<xsl:template match="variablelist|orderedlist|orderedlist|simplelist|
                     itemizedlist" mode="xref-to">
  <xsl:call-template name="title-link-to"/>
</xsl:template>

<xsl:template match="biblioentry" mode="xref-to">
  <xsl:text>\cite{</xsl:text>
  <xsl:value-of select="abbrev[1]"/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="command" mode="xref">
  <xsl:call-template name="inline.boldseq"/>
</xsl:template>

<xsl:template match="function" mode="xref">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="cmdsynopsis" mode="xref-to">
  <xsl:variable name="command" select="(.//command)[1]"/>
  <xsl:apply-templates select="$command" mode="xref"/>
</xsl:template>

<xsl:template match="funcsynopsis" mode="xref-to">
  <xsl:variable name="func" select="(.//function)[1]"/>
  <xsl:apply-templates select="$func" mode="xref"/>
</xsl:template>

<xsl:template match="bibliography|glossary|index" mode="xref-to">
  <xsl:call-template name="cross-reference"/>
</xsl:template>

<xsl:template match="reference" mode="xref-to">
  <xsl:call-template name="cross-reference"/>
</xsl:template>

<xsl:template match="question|answer" mode="xref-to">
  <xsl:call-template name="cross-reference"/>
</xsl:template>

<xsl:template match="co" mode="xref-to">
  <xsl:apply-templates select="." mode="callout-bug"/>
</xsl:template>

<xsl:template match="co|callout" mode="conumber">
  <xsl:number from="literallayout|programlisting|screen|synopsis|calloutlist"
              level="any"
              format="1"/>
</xsl:template>

</xsl:stylesheet>
