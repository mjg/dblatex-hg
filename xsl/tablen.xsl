<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<!-- Upper table and informaltable templates. They make the wrapper environment
     depending of the kind of table (floating, landscape, role) and call the
     actual newtbl engine. The $newtbl.use parameter is now obsolete. -->

<xsl:param name="newtbl.format.thead">\bfseries%&#10;</xsl:param>
<xsl:param name="newtbl.format.tbody"/>
<xsl:param name="newtbl.format.tfoot"/>
<xsl:param name="newtbl.default.colsep" select="'1'"/>
<xsl:param name="newtbl.default.rowsep" select="'1'"/>
<xsl:param name="newtbl.use.hhline" select="'0'"/>
<xsl:param name="newtbl.use" select="'1'"/> <!-- no more used -->
<xsl:param name="table.title.top" select="'0'"/>
<xsl:param name="table.default.position" select="'[htbp]'"/>


<xsl:template match="table">
  <!-- do we need to change text size? -->
  <xsl:variable name="size">
    <xsl:choose>
    <xsl:when test="@role='small' or @role='footnotesize' or
                    @role='scriptsize' or @role='tiny'">
      <xsl:value-of select="@role"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>normal</xsl:text>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:if test="@orient='land'">
    <xsl:text>\begin{landscape}&#10;</xsl:text>
  </xsl:if>
  <xsl:text>\begin{table}</xsl:text>
  <!-- table placement preference -->
  <xsl:choose>
    <xsl:when test="@floatstyle != ''">
      <xsl:value-of select="@floatstyle"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$table.default.position"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>&#10;</xsl:text>
  <!-- title caption before the table -->
  <xsl:if test="$table.title.top='1'">
    <xsl:apply-templates select="title"/>
  </xsl:if>
  <xsl:if test="$size!='normal'">
    <xsl:text>\begin{</xsl:text>
    <xsl:value-of select="$size"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:text>\begin{center}&#10;</xsl:text>
  <!-- do the actual work -->
  <xsl:apply-templates select="tgroup" mode="newtbl">
    <xsl:with-param name="tabletype" select="'longtable'"/>
  </xsl:apply-templates>
  <xsl:text>&#10;\addtocounter{table}{-1}&#10;</xsl:text>
  <xsl:text>&#10;\end{center}&#10;</xsl:text>
  <xsl:if test="$size!='normal'">
    <xsl:text>\end{</xsl:text>
    <xsl:value-of select="$size"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:if test="$table.title.top='0'">
    <xsl:apply-templates select="title"/>
  </xsl:if>
  <xsl:text>\end{table}&#10;</xsl:text>
  <xsl:if test="@orient='land'">
    <xsl:text>\end{landscape}&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="table/title">
  <xsl:text>&#10;\caption{</xsl:text>
  <xsl:call-template name="normalize-scape">
    <xsl:with-param name="string" select="."/>
  </xsl:call-template>
  <xsl:text>}&#10;</xsl:text>
  <xsl:call-template name="label.id">
    <xsl:with-param name="object" select="parent::table"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="informaltable">
  <!-- do we need to change text size? -->
  <xsl:variable name="size">
    <xsl:choose>
    <xsl:when test="@role='small' or @role='footnotesize' or
                    @role='scriptsize' or @role='tiny'">
      <xsl:value-of select="@role"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>normal</xsl:text>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- are we a nested table? -->
  <xsl:variable name="nested" select="ancestor::entry"/>

  <!-- longtables cannot be nested -->
  <xsl:variable name="tabletype">
    <xsl:choose>
    <xsl:when test="$nested">tabular</xsl:when>
    <xsl:otherwise>longtable</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="@orient='land'">
    <xsl:text>\begin{landscape}&#10;</xsl:text>
  </xsl:if>
  <xsl:if test="$size!='normal'">
    <xsl:text>\begin{</xsl:text>
    <xsl:value-of select="$size"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:choose>
  <xsl:when test="not($nested)">
    <xsl:text>&#10;{\centering </xsl:text>
    <!-- do the actual work -->
    <xsl:apply-templates select="tgroup" mode="newtbl">
      <xsl:with-param name="tabletype" select="$tabletype"/>
    </xsl:apply-templates>
    <xsl:if test="$tabletype='longtable'">
      <xsl:text>&#10;\addtocounter{table}{-1}&#10;</xsl:text>
    </xsl:if>
    <xsl:text>}&#10;</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates select="tgroup" mode="newtbl">
      <xsl:with-param name="tabletype" select="$tabletype"/>
      <xsl:with-param name="tablewidth" select="'\linewidth'"/>
    </xsl:apply-templates>
    <xsl:if test="$tabletype='longtable'">
      <xsl:text>&#10;\addtocounter{table}{-1}&#10;</xsl:text>
    </xsl:if>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="$size!='normal'">
    <xsl:text>\end{</xsl:text>
    <xsl:value-of select="$size"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:if test="@orient='land'">
    <xsl:text>\end{landscape}&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<!-- Hook for the newtbl to decide what to do after the table head,
     depending on the type of table used.
-->
<xsl:template match="table|informaltable" mode="newtbl.endhead">
  <xsl:param name="tabletype"/>
  <xsl:if test="$tabletype='longtable'">
    <!-- longtable endhead -->
    <xsl:text>\endhead&#10;</xsl:text>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
