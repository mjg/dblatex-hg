<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<!-- ################
     # biblio setup #
     ################ -->

<xsl:template name="biblio.setup">
  <xsl:if test="$latex.biblio.style!='' and //bibliography">
    <xsl:text>\bibliographystyle{</xsl:text>
    <xsl:value-of select="$latex.biblio.style"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
</xsl:template>


<!-- ##################
     # biblio section #
     ################## -->

<xsl:template name="biblio.title">
  <xsl:choose>
  <xsl:when test="title|bibliographyinfo/title">
    <xsl:call-template name="normalize-scape">
      <xsl:with-param name="string" select="(title|bibliographyinfo/title)[1]"/>
    </xsl:call-template>
  </xsl:when>
  <xsl:when test="ancestor::article">
    <xsl:text>\refname</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>\bibname</xsl:text>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- we can have a list of entries to process, or a bibtex file -->
<xsl:template name="biblioentry.process">
  <xsl:param name="level"/>
  <xsl:choose>
  <xsl:when test="count(bibioentry|bibliomixed)=1 and
                  bibliomixed[processing-instruction('bibtex')]">
    <xsl:call-template name="bibtex.process">
      <xsl:with-param name="level" select="$level"/>
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
    <xsl:call-template name="bibentries.process">
      <xsl:with-param name="level" select="$level"/>
    </xsl:call-template>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="bibentries.process">
  <xsl:param name="level"/>

  <xsl:text>\begin{btSect}{}&#10;</xsl:text>

  <!-- display the heading -->
  <xsl:if test="$level &gt;= 0">
    <xsl:call-template name="map.sect.level">
      <xsl:with-param name="level" select="$level"/>
    </xsl:call-template>
    <xsl:text>{</xsl:text>
    <xsl:call-template name="biblio.title"/>
    <xsl:text>}&#10;</xsl:text>
    <xsl:call-template name="label.id"/>
  </xsl:if>

  <xsl:text>\begin{bibgroup}&#10;</xsl:text>
  <xsl:text>\begin{thebibliography}{</xsl:text>
  <xsl:value-of select="$latex.bibwidelabel"/>
  <xsl:text>}&#10;</xsl:text>
  <xsl:if test="biblioentry">
    <xsl:choose>
    <xsl:when test="$latex.biblio.output ='cited'">
      <xsl:apply-templates select="biblioentry" mode="bibliography.cited">
        <xsl:sort select="./abbrev"/>
        <xsl:sort select="./@xreflabel"/>
        <xsl:sort select="./@id"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="biblioentry">
        <xsl:sort select="./abbrev"/>
        <xsl:sort select="./@xreflabel"/>
        <xsl:sort select="./@id"/>
      </xsl:apply-templates>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
  <xsl:if test="bibliomixed">
    <xsl:apply-templates select="bibliomixed"/>
  </xsl:if>
  <xsl:text>&#10;\end{thebibliography}&#10;</xsl:text>
  <xsl:text>\end{bibgroup}&#10;</xsl:text>
  <xsl:text>\end{btSect}&#10;</xsl:text>
</xsl:template>


<!-- ################
     # bibtex files #
     ################ -->

<xsl:template name="bibtex.process">
  <xsl:param name="level"/>
  <xsl:variable name="pi"
                select="bibliomixed/processing-instruction('bibtex')"/>

  <!-- take all the details from the bibtex PI -->
  <xsl:variable name="bibfiles">
    <xsl:call-template name="pi-attribute">
      <xsl:with-param name="pis" select="$pi"/>
      <xsl:with-param name="attribute" select="'bibfiles'"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="bibstyle">
    <xsl:call-template name="pi-attribute">
      <xsl:with-param name="pis" select="$pi"/>
      <xsl:with-param name="attribute" select="'bibstyle'"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="print">
    <xsl:call-template name="pi-attribute">
      <xsl:with-param name="pis" select="$pi"/>
      <xsl:with-param name="attribute" select="'mode'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:text>\begin{btSect}</xsl:text>

  <!-- specific style to apply? -->
  <xsl:if test="$bibstyle!=''">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="$bibstyle"/>
    <xsl:text>]</xsl:text>
  </xsl:if>

  <!-- the bibtex files to use (fallback to global parameter) -->
  <xsl:text>{</xsl:text>
  <xsl:choose>
  <xsl:when test="$bibfiles!=''">
    <xsl:value-of select="$bibfiles"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="$latex.bibfiles"/>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:text>}&#10;</xsl:text>

  <!-- display the heading -->
  <xsl:if test="$level &gt;= 0">
    <xsl:call-template name="map.sect.level">
      <xsl:with-param name="level" select="$level"/>
    </xsl:call-template>
    <xsl:text>{</xsl:text>
    <xsl:call-template name="biblio.title"/>
    <xsl:text>}&#10;</xsl:text>
    <xsl:call-template name="label.id"/>
  </xsl:if>

  <!-- things before the entries -->
  <xsl:apply-templates select="*[not(self::bibliomixed)]"/>

  <!-- the entries to show depend on the print mode -->
  <xsl:choose>
  <xsl:when test="$print='cited'">
    <xsl:text>\btPrintCited&#10;</xsl:text>
  </xsl:when>
  <xsl:when test="$print='notcited'">
    <xsl:text>\btPrintNotCited&#10;</xsl:text>
  </xsl:when>
  <xsl:when test="$print='all'">
    <xsl:text>\btPrintAll&#10;</xsl:text>
  </xsl:when>
  <xsl:when test="$latex.biblio.output='cited'">
    <xsl:text>\btPrintCited&#10;</xsl:text>
  </xsl:when>
  <xsl:when test="$latex.biblio.output='notcited'">
    <xsl:text>\btPrintNotCited&#10;</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>\btPrintAll&#10;</xsl:text>
  </xsl:otherwise>
  </xsl:choose>

  <xsl:text>\end{btSect}&#10;</xsl:text>
</xsl:template>


<!-- ################
     # bibliography #
     ################ -->

<xsl:template match="bibliography">
  <xsl:message>Processing Bibliography</xsl:message>
  <xsl:message><xsl:text>Output Mode: </xsl:text>
    <xsl:value-of select="$latex.biblio.output"/>
  </xsl:message>
  <xsl:text>% ------------------------------------------- &#10;</xsl:text>
  <xsl:text>% Bibliography&#10;</xsl:text>
  <xsl:text>% ------------------------------------------- &#10;</xsl:text>

  <!-- get the section level -->
  <xsl:variable name="level">
    <xsl:call-template name="get.sect.level"/>
  </xsl:variable>

  <xsl:choose>
  <xsl:when test="biblioentry|bibliomixed">
    <!-- process the entries -->
    <xsl:call-template name="biblioentry.process">
      <xsl:with-param name="level" select="$level"/>
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
    <!-- no entries here, only a section block -->
    <xsl:call-template name="map.sect.level">
      <xsl:with-param name="level" select="$level"/>
    </xsl:call-template>
    <xsl:text>{</xsl:text>
    <xsl:call-template name="biblio.title"/>
    <xsl:text>}&#10;</xsl:text>
    <xsl:call-template name="label.id"/>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:apply-templates select="bibliodiv"/> 
</xsl:template>

<xsl:template match="bibliography/title"/>
<xsl:template match="bibliography/subtitle"/>
<xsl:template match="bibliography/titleabbrev"/>

<!-- ###############
     #  bibliodiv  #
     ############### -->

<xsl:template match="bibliodiv">
  <xsl:message>Processing Bibliography - Bibliodiv</xsl:message>
  <xsl:variable name="level">
    <xsl:call-template name="get.sect.level">
      <xsl:with-param name="n" select="parent::bibliography"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:call-template name="biblioentry.process">
    <xsl:with-param name="level" select="$level+1"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="bibliodiv/title"/>

<!-- ###############
     #  bibliolist #
     ############### -->

<xsl:template match="bibliolist">
  <xsl:call-template name="biblioentry.process">
    <xsl:with-param name="level" select="'-1'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="bibliodiv/title"/>

<!-- ###############
     # biblioentry #
     ############### -->

<xsl:template match="biblioentry" mode="bibliography.cited">
  <xsl:param name="bibid" select="@id"/>
  <xsl:param name="ab">
    <xsl:call-template name="bibitem.label"/>
  </xsl:param>
  <xsl:variable name="nx" select="//xref[@linkend=$bibid]"/>
  <xsl:variable name="nc" select="//citation[text()=$ab]"/>
  <xsl:if test="count($nx) &gt; 0 or count($nc) &gt; 0">
    <xsl:call-template name="biblioentry.output"/>
  </xsl:if>
</xsl:template>

<xsl:template match="biblioentry" mode="bibliography.all">
  <xsl:call-template name="biblioentry.output"/>
</xsl:template>

<xsl:template match="biblioentry">
  <xsl:call-template name="biblioentry.output"/>
</xsl:template>

<xsl:template match="biblioentry/title">
  <xsl:text>\emph{</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>

<!-- biblioentry engine -->

<xsl:template name="bibitem.label">
  <xsl:choose>
  <xsl:when test="@xreflabel">
    <xsl:value-of select="normalize-space(@xreflabel)"/> 
  </xsl:when>
  <xsl:when test="abbrev">
    <xsl:apply-templates select="abbrev" mode="bibliography.mode"/> 
  </xsl:when>
  <xsl:when test="@id">
    <xsl:value-of select="normalize-space(@id)"/> 
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>UNKNOWN</xsl:text>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="bibitem">
  <xsl:variable name="tag">
    <xsl:call-template name="bibitem.label"/>
  </xsl:variable>
  <xsl:text>&#10;</xsl:text>
  <xsl:text>\bibitem</xsl:text>
  <xsl:if test="$tag!='UNKNOWN'">
    <xsl:text>[</xsl:text>
    <xsl:call-template name="normalize-scape">
      <xsl:with-param name="string" select="$tag"/>
    </xsl:call-template>
    <xsl:text>]</xsl:text> 
  </xsl:if>
  <xsl:text>{</xsl:text>
  <xsl:value-of select="$tag"/>
  <xsl:text>}&#10;</xsl:text> 
</xsl:template>

<xsl:template name="biblioentry.output">
  <xsl:call-template name="bibitem"/>
  <!-- first, biblioentry information (if any) -->
  <xsl:variable name="data" select="subtitle|
                                    volumenum|
                                    edition|
                                    copyright|
                                    publisher|
                                    pubdate|
                                    pagenums|
                                    isbn|
                                    issn|
                                    biblioid|
                                    releaseinfo|
                                    pubsnumber"/>
  <xsl:apply-templates select="author|authorgroup" mode="bibliography.mode"/>
  <xsl:if test="title">
    <xsl:if test="author|authorgroup">
      <xsl:value-of select="$biblioentry.item.separator"/>
    </xsl:if>
    <xsl:apply-templates select="title"/>
  </xsl:if>
  <xsl:if test="$data">
    <xsl:for-each select="$data">
      <xsl:value-of select="$biblioentry.item.separator"/>
      <xsl:apply-templates select="." mode="bibliography.mode"/> 
    </xsl:for-each>
    <xsl:text>.</xsl:text>
  </xsl:if>
  <!-- then, biblioset information (if any) -->
  <xsl:for-each select="biblioset">
    <xsl:text>&#10;&#10;</xsl:text>
    <xsl:apply-templates select="." mode="bibliography.mode"/>
  </xsl:for-each>
  <xsl:call-template name="label.id"/> 
  <xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="bibliomixed">
  <xsl:call-template name="bibitem"/>
  <xsl:apply-templates select="." mode="bibliography.mode"/>
  <xsl:text>&#10;</xsl:text>
</xsl:template>


<!-- by default no specific behaviour -->

<xsl:template match="*" mode="bibliography.mode">
  <xsl:apply-templates mode="bibliography.mode"/>
</xsl:template>

<!-- specific behaviour for bibliography -->

<xsl:template match="biblioset" mode="bibliography.mode">
  <xsl:if test="author|authorgroup">
    <xsl:apply-templates select="author|authorgroup" mode="bibliography.mode"/>
    <xsl:value-of select="$biblioentry.item.separator"/>
  </xsl:if>
  <xsl:apply-templates select="title" mode="bibliography.mode"/>
  <xsl:for-each select="subtitle|
                        volumenum|
                        edition|
                        copyright|
                        publisher|
                        pubdate|
                        pagenums|
                        isbn|
                        issn|
                        biblioid|
                        pubsnumber">
    <xsl:value-of select="$biblioentry.item.separator"/>
    <xsl:apply-templates select="." mode="bibliography.mode"/> 
  </xsl:for-each>
  <xsl:text>.</xsl:text>
</xsl:template>

<xsl:template match="biblioset/title|biblioset/citetitle" 
              mode="bibliography.mode">
  <xsl:variable name="relation" select="../@relation"/>
  <xsl:choose>
    <xsl:when test="$relation='article'">
      <xsl:call-template name="dingbat">
        <xsl:with-param name="dingbat">ldquo</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
      <xsl:call-template name="dingbat">
        <xsl:with-param name="dingbat">rdquo</xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Biblioid depends on its class -->
<xsl:template match="biblioid" mode="bibliography.mode">
  <xsl:choose>
    <xsl:when test="@class='doi'">
      <xsl:text>DOI</xsl:text>
    </xsl:when>
    <xsl:when test="@class='isbn'">
      <xsl:text>ISBN</xsl:text>
    </xsl:when>
    <xsl:when test="@class='issn'">
      <xsl:text>ISSN</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>
        <xsl:text>The biblioid class '</xsl:text>
        <xsl:value-of select="@class"/>
        <xsl:text>' not supported!</xsl:text>
      </xsl:message>
      <xsl:value-of select="@class"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text> </xsl:text>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="author" mode="bibliography.mode">
  <xsl:variable name="authorsstring">
    <xsl:call-template name="person.name"/>
  </xsl:variable>
  <xsl:value-of select="normalize-space($authorsstring)"/>
</xsl:template>

<xsl:template match="authorgroup" mode="bibliography.mode">
  <xsl:variable name="authorsstring">
    <xsl:call-template name="person.name.list"/>
  </xsl:variable>
  <xsl:value-of select="normalize-space($authorsstring)"/>
</xsl:template>

<xsl:template match="editor" mode="bibliography.mode">
    <xsl:call-template name="person.name"/>
    <xsl:value-of select="$biblioentry.item.separator"/>
</xsl:template>

<xsl:template match="copyright" mode="bibliography.mode">
  <xsl:call-template name="gentext.element.name"/>
  <xsl:call-template name="gentext.space"/>
  <xsl:call-template name="dingbat">
    <xsl:with-param name="dingbat">copyright</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="gentext.space"/>
  <xsl:apply-templates select="year" mode="bibliography.mode"/>
  <xsl:call-template name="gentext.space"/>
  <xsl:apply-templates select="holder" mode="bibliography.mode"/>
</xsl:template>

<xsl:template match="year" mode="bibliography.mode">
  <xsl:apply-templates/>
  <xsl:if test="position()!=last()">
    <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>


<!-- to manage entities correctly (such as &amp;) -->
<xsl:template match="subtitle|volumenum|edition|
                     pubdate|pagenums|isbn|issn|
                     holder|publishername|releaseinfo" mode="bibliography.mode">
  <xsl:apply-templates/>
</xsl:template>

<!-- suppressed things -->
<xsl:template match="printhistory" mode="bibliography.mode"/>
<xsl:template match="abstract" mode="bibliography.mode"/>
<xsl:template match="authorblurb" mode="bibliography.mode"/>


</xsl:stylesheet>
