<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<xsl:template match="table">
  <xsl:call-template name="resizetable">
    <xsl:with-param name="pos" select="'1'"/>
    <xsl:with-param name="variacols" select="tgroup/@cols"/>
    <xsl:with-param name="fixedcols" select="'0'"/>
    <xsl:with-param name="fixedwidth" select="'0'"/>
    <xsl:with-param name="colspecs" select="./tgroup/colspec"/>
  </xsl:call-template>
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
  <xsl:text>\begin{table}[htbp]&#10;</xsl:text>
  <xsl:if test="$size!='normal'">
    <xsl:text>\begin{</xsl:text>
    <xsl:value-of select="$size"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:text>\begin{center}&#10;</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>&#10;\end{center}&#10;</xsl:text>
  <xsl:if test="$size!='normal'">
    <xsl:text>\end{</xsl:text>
    <xsl:value-of select="$size"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:text>&#10;\caption{</xsl:text>
  <xsl:choose> 
    <xsl:when test="title">
      <xsl:call-template name="normalize-scape">
        <xsl:with-param name="string" select="title"/>
      </xsl:call-template>
    </xsl:when> 
    <xsl:otherwise>
      <xsl:text>*** Title expected</xsl:text>
    </xsl:otherwise> 
  </xsl:choose>
  <xsl:text>}&#10;</xsl:text>
  <xsl:call-template name="label.id"/>
  <xsl:text>\end{table}&#10;</xsl:text>
  <xsl:if test="@orient='land'">
    <xsl:text>\end{landscape}&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="informaltable">
  <xsl:call-template name="resizetable">
    <xsl:with-param name="pos" select="'1'"/>
    <xsl:with-param name="variacols" select="tgroup/@cols"/>
    <xsl:with-param name="fixedcols" select="'0'"/>
    <xsl:with-param name="fixedwidth" select="'0'"/>
    <xsl:with-param name="colspecs" select="./tgroup/colspec"/>
  </xsl:call-template>
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
  <xsl:if test="$size!='normal'">
    <xsl:text>\begin{</xsl:text>
    <xsl:value-of select="$size"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:text>\begin{center}&#10;</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>\end{center}&#10;</xsl:text>
  <xsl:if test="$size!='normal'">
    <xsl:text>\end{</xsl:text>
    <xsl:value-of select="$size"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:if test="@orient='land'">
    <xsl:text>\end{landscape}&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template name="tgroup.build">
  <xsl:param name="kind"/>
  <xsl:variable name="align" select="@align"/>
  <xsl:variable name="cols" select="@cols"/>
  <xsl:variable name="colspecs" select="colspec"/>
  <xsl:variable name="frame" select="parent::*/@frame"/>

  <xsl:text>\begin{</xsl:text>
  <xsl:value-of select="$kind"/>
  <xsl:text>}{</xsl:text>

  <xsl:call-template name="build.vframe"/>

  <xsl:call-template name="build.colinfos">
    <xsl:with-param name="pos" select="1"/>
    <xsl:with-param name="num" select="1"/>
    <xsl:with-param name="cnb" select="$cols"/>
  </xsl:call-template>

  <xsl:call-template name="build.vframe"/>
  <xsl:text>}&#10;</xsl:text>

  <xsl:if test="$frame!='sides' and $frame!='none' and $frame!='bottom'">
    <xsl:text>\hline &#10;</xsl:text>
  </xsl:if>
  <xsl:apply-templates/>
  <xsl:if test="$frame!='sides' and $frame!='none' and $frame!='top'">
    <xsl:text>\hline &#10;</xsl:text>
  </xsl:if>

  <xsl:text>\end{</xsl:text>
  <xsl:value-of select="$kind"/>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>

<xsl:template match="tgroup">
  <xsl:call-template name="tgroup.build">
  <!-- Maybe we should use tabular... -->
  <xsl:with-param name="kind" select="'longtable'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="informaltable/tgroup">
  <xsl:call-template name="tgroup.build">
    <xsl:with-param name="kind" select="'longtable'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="colspec"></xsl:template>
<xsl:template match="spanspec"></xsl:template>

<xsl:template match="thead|tfoot">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tbody">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tbody/row|thead/row|tfoot/row">
  <xsl:if test="../thead">
    <xsl:text>\rowcolor[gray]{.9} &#10;</xsl:text>
  </xsl:if>
  <xsl:apply-templates/>

  <!-- The rule below the last row in the table is controlled by the 
       Frame attribute of the enclosing Table or InformalTable and the RowSep 
       of the last row is ignored. If unspecified, this attribute is 
       inherited from enclosing elements. -->

  <xsl:if test="position() != last()">
    <xsl:choose>
    <!-- first, the node @rowsep -->
    <xsl:when test="@rowsep">
      <xsl:if test="@rowsep='1'"> 
        <xsl:text>\hline &#10;</xsl:text>
      </xsl:if>
    </xsl:when>
    <!-- then, the @rowsep specified for the current column -->
    <!--
    <xsl:when test="ancestor::*/colspec[@rowsep]">
      <xsl:variable name="r">
        <xsl:call-template name="give.colspec.rowsep">
          <xsl:with-param name="set" select="ancestor::*/colspec"/>
          <xsl:with-param name="match" select="position()"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="$r='1'">
        <xsl:text>\hline &#10;</xsl:text>
      </xsl:if>
    </xsl:when>
    -->
    <!-- last, the closest enclosing element @rowsep -->
    <xsl:when test="ancestor::*[@rowsep]">
      <xsl:if test="((ancestor::*[@rowsep])[last()])[@rowsep='1']">
        <xsl:text>\hline &#10;</xsl:text>
      </xsl:if>
    </xsl:when>
    <!-- by default a row separator -->
    <xsl:otherwise>
      <xsl:text>\hline &#10;</xsl:text>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template name="give.colspec.rowsep">
  <xsl:param name="set"/>
  <xsl:param name="match"/>
  <xsl:param name="num" select="'1'"/>
  <xsl:param name="pos" select="'1'"/>

  <xsl:variable name="n" select="$set[position()=$pos]"/>

  <xsl:choose>
  <xsl:when test="$n">
    <!-- shift to the actual colnum -->
    <xsl:variable name="rnum">
      <xsl:choose>
      <xsl:when test="$n[@colnum]">
        <xsl:value-of select="$n/@colnum"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$num"/>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
    <xsl:when test="$rnum = $match">
      <!-- found -->
      <xsl:choose>
      <xsl:when test="$n[@rowsep]">
        <xsl:value-of select="$n/@rowsep"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'1'"/>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$rnum &lt; $match">
      <!-- continue -->
      <xsl:call-template name="give.colspec.rowsep">
        <xsl:with-param name="set" select="$set"/>
        <xsl:with-param name="match" select="$match"/>
        <xsl:with-param name="pos" select="$pos + 1"/>
        <xsl:with-param name="num" select="$rnum + 1"/>
      </xsl:call-template>
    </xsl:when>
    <!-- not found, default value -->
    <xsl:otherwise>
      <xsl:value-of select="'1'"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:when>
  <!-- no more colspec, default value -->
  <xsl:otherwise>
    <xsl:value-of select="'1'"/>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="thead/row[position()=last()]">
  <xsl:text>\rowcolor[gray]{.9} &#10;</xsl:text>
  <xsl:apply-templates/>
  <xsl:if test="../../../tgroup[@rowsep='1'] and @rowsep!='0'">
    <xsl:text>\hline &#10;</xsl:text>
    <xsl:text>\hline &#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="informaltable/tgroup/thead/row[position()=last()]">
  <xsl:text>\rowcolor[gray]{.9} &#10;</xsl:text>
  <xsl:apply-templates/>
  <xsl:if test="../../../tgroup[@rowsep='1'] and @rowsep!='0'">
    <xsl:text>\hline &#10;</xsl:text>
  </xsl:if>
  <xsl:text>\endhead &#10;</xsl:text> 
  <xsl:if test="../../../tgroup[@rowsep='1'] and @rowsep!='0'">
    <xsl:text>\hline &#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="thead/row/entry">
<xsl:apply-templates/><xsl:text> &amp; </xsl:text> 
</xsl:template>

<xsl:template match="thead/row/entry[position()=last()]">
<xsl:apply-templates/><xsl:text> \tabularnewline &#10;</xsl:text> 
</xsl:template>

<!-- the function gives the number of a colspec by scanning the preceding
     colspecs until the first whose number (@colnum)
     is set, or if not the count of colspecs -->

<xsl:template name="give.colspec.num">
  <xsl:param name="n"/>
  <xsl:param name="num" select="0"/>
  <xsl:choose>
  <xsl:when test="$n">
    <xsl:choose>
    <xsl:when test="$n/@colnum">
      <xsl:value-of select="$n/@colnum + $num"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="give.colspec.num">
        <xsl:with-param name="n" select="$n/preceding-sibling::colspec"/>
        <xsl:with-param name="num" select="$num + 1"/>
      </xsl:call-template>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="$num"/>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="build.colspan">
  <xsl:param name="n1" select="@namest"/>
  <xsl:param name="n2" select="@nameend"/>
  <xsl:variable name="c1" select="ancestor::*/colspec[@colname=$n1]"/>
  <xsl:variable name="c2" select="ancestor::*/colspec[@colname=$n2]"/>
  <xsl:variable name="p1">
    <xsl:call-template name="give.colspec.num">
      <xsl:with-param name="n" select="$c1"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="p2">
    <xsl:call-template name="give.colspec.num">
      <xsl:with-param name="n" select="$c2"/>
    </xsl:call-template>
  </xsl:variable>
  <!-- colspan -->
  <xsl:text>\multicolumn{</xsl:text>
  <xsl:value-of select="$p2 - $p1 + 1"/>
  <xsl:text>}{</xsl:text>
  <!-- the 1st left colsep depends on @frame -->
  <xsl:if test="$p1 = 1">
    <xsl:call-template name="build.colsep"/>
  </xsl:if>
  <!-- todo: align -->
  <xsl:text>c</xsl:text>
  <!-- the right colsep depends on @frame if last or @colsep if not -->
  <xsl:choose>
  <xsl:when test="$p2 &lt; ancestor::tgroup/@cols">
    <xsl:call-template name="build.colsep"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:call-template name="build.vframe"/>
  </xsl:otherwise>
  </xsl:choose>
  <!-- the cell content -->
  <xsl:text>}{</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="tbody/row/entry">
  <xsl:choose>
  <xsl:when test="@morerows">
    <xsl:text>\multirow{</xsl:text>
    <xsl:value-of select="@morerows+1"/>
    <xsl:text>}*{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:when>
  <xsl:when test="@namest and @nameend">
    <xsl:call-template name="build.colspan"/>
  </xsl:when>
  <xsl:when test="@spanname">
    <xsl:variable name="s" select="@spanname"/>
    <xsl:variable name="span" select="ancestor::*/spanspec[@spanname=$s]"/>
    <xsl:call-template name="build.colspan">
      <xsl:with-param name="n1" select="$span/@namest"/>
      <xsl:with-param name="n2" select="$span/@nameend"/>
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates/>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:choose>
  <xsl:when test="position()=last()">
    <xsl:text> \tabularnewline &#10;</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text> &amp; </xsl:text>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="build.colinfos">
  <xsl:param name="pos"/>
  <xsl:param name="num"/>
  <xsl:param name="cnb"/>

  <xsl:variable name="spec" select="colspec[position()=$pos]"/>
  <xsl:choose>
  <xsl:when test="$spec">
    <xsl:variable name="undef">
      <xsl:choose>
        <xsl:when test="$spec[@colnum > $num]">
          <xsl:value-of select="$spec/@colnum - $num"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Create the previous omitted colspecs. -->
    <xsl:if test="$undef!=0">
      <xsl:call-template name="build.colinfo.default">
        <xsl:with-param name="colno" select="$undef"/>
      </xsl:call-template>
    </xsl:if>

    <!-- Create the current colspec. -->
    <xsl:apply-templates select="$spec" mode="build">
      <xsl:with-param name="rem" select="$cnb - $num - $undef"/>
    </xsl:apply-templates>

    <xsl:call-template name="build.colinfos">
      <xsl:with-param name="pos" select="$pos + 1"/>
      <xsl:with-param name="num" select="$num + $undef + 1"/>
      <xsl:with-param name="cnb" select="$cnb"/>
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
    <!-- Create the last undefined colspecs. -->
    <xsl:if test="$cnb &gt;= $num">
      <xsl:call-template name="build.colinfo.default">
        <xsl:with-param name="colno" select="$cnb - $num + 1"/>
        <xsl:with-param name="chklast" select="'1'"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- Default columns list building, when no colspec specified. -->

<xsl:template name="build.colinfo.default">
  <xsl:param name="colno"/>
  <xsl:param name="chklast" select="'0'"/>
  <xsl:if test="$colno>=1">
    <xsl:call-template name="build.align">
      <xsl:with-param name="align" select="((ancestor::*[@align])[last])/@align"/>
      <xsl:with-param name="small" select="'0'"/>
    </xsl:call-template>
    <xsl:text>p{\tsize{1}}</xsl:text>
    <!-- no separator for the last one -->
    <xsl:if test="$colno>1 or $chklast!='1'">
      <xsl:call-template name="build.colsep"/>
    </xsl:if>
    <xsl:call-template name="build.colinfo.default">
      <xsl:with-param name="colno" select="$colno - 1"/>
      <xsl:with-param name="chklast" select="$chklast"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<!-- The rigth column separator is defined by the closest @colsep
     value (i.e. the node attribute or the immediate ancestor).
     If not defined the default behaviour is to have a column
  -->

<xsl:template name="build.colsep">
  <xsl:variable name="n" select="(ancestor-or-self::*[@colsep])[last()]"/>
  <xsl:choose>
  <xsl:when test="$n">
    <xsl:if test="$n/@colsep='1'">
      <xsl:text>|</xsl:text>
    </xsl:if>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>|</xsl:text>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="build.vframe">
  <xsl:variable name="n" select="ancestor::*[@frame]"/>
  <xsl:if test="not($n) or $n/@frame='all' or $n/@frame='sides'">
    <xsl:text>|</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template name="build.align">
  <xsl:param name="small"/>
  <xsl:param name="align"/>
  <xsl:choose>
  <xsl:when test="$small='0'">
    <xsl:choose>
    <xsl:when test="$align='center'">
      <xsl:text>&gt;{\centering}</xsl:text>
    </xsl:when>
    <xsl:when test="$align='justify'">
      <xsl:text>&gt;{\centering}</xsl:text>
    </xsl:when>
    <xsl:when test="$align='right'">
      <xsl:text>&gt;{\raggedleft}</xsl:text>
    </xsl:when>
    <xsl:when test="$align='left'">
      <xsl:text>&gt;{\raggedright}</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>&gt;{\raggedright}</xsl:text>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:when>
  <xsl:otherwise>
    <xsl:choose>
    <xsl:when test="$align='center'">
      <xsl:text>c</xsl:text>
    </xsl:when>
    <xsl:when test="$align='justify'">
      <xsl:text>c</xsl:text>
    </xsl:when>
    <xsl:when test="$align='right'">
      <xsl:text>r</xsl:text>
    </xsl:when>
    <xsl:when test="$align='left'">
      <xsl:text>l</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>l</xsl:text>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- Evalue le redimensionnement d'une table -->

<xsl:template name="resizetable">
  <xsl:param name="pos"/>
  <xsl:param name="variacols"/>
  <xsl:param name="fixedcols"/>
  <xsl:param name="fixedwidth"/>
  <xsl:param name="colspecs"/>

  <xsl:variable name="spec" select="$colspecs[position()=$pos]"/>
  <xsl:choose>
  <xsl:when test="$spec">
    <xsl:variable name="cw" select="$spec/@colwidth"/>

    <!-- Nombre supplementaire de colonnes proportionnelles (virtuelles) a
         ajouter -->
    <xsl:variable name="coladded">
      <xsl:choose>
      <xsl:when test="contains($cw, '*')">
        <xsl:variable name="p" select="substring-before($cw, '*')"/>
        <xsl:choose>
        <xsl:when test="$p &gt;= 1">
          <xsl:value-of select="$p - 1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'0'"/>
        </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="contains($cw, 'cm')">
        <xsl:value-of select="'-1'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'0'"/>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Indique si la colonne est de taille fixe -->
    <xsl:variable name="colfixed">
      <xsl:choose>
      <xsl:when test="contains($cw, 'cm')">
        <xsl:value-of select="'1'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'0'"/>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Taille fixe a retrancher pour cette colonne -->
    <xsl:variable name="width">
      <xsl:choose>
      <xsl:when test="contains($cw, 'cm')">
        <xsl:variable name="p" select="substring-before($cw, 'cm')"/>
        <xsl:choose>
        <xsl:when test="$p">
          <xsl:value-of select="$p"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'0'"/>
        </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'0'"/>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="resizetable">
      <xsl:with-param name="pos" select="$pos + 1"/>
      <xsl:with-param name="variacols" select="$variacols + $coladded"/>
      <xsl:with-param name="fixedcols" select="$fixedcols + $colfixed"/>
      <xsl:with-param name="fixedwidth" select="$fixedwidth + $width"/>
      <xsl:with-param name="colspecs" select="$colspecs"/>
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
    <!-- L'ensemble des colspecs est traite, on produit la commande latex -->
    <xsl:if test="$variacols &gt; 0">
      <xsl:text>\resizetable{</xsl:text>
      <xsl:value-of select="$variacols"/>
      <xsl:text>}{</xsl:text>
      <xsl:value-of select="$fixedcols"/>
      <xsl:text>}{</xsl:text>
      <xsl:value-of select="$fixedwidth"/>
      <xsl:text>cm}{</xsl:text>
      <xsl:if test="@orient='land'">
        <xsl:text>land</xsl:text>
      </xsl:if>
      <xsl:text>}&#10;</xsl:text>
    </xsl:if>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="colspec" mode="build">
  <!-- La caracteristique d'alignement est soit celle de du colspec courant,
       et si non definie celle du tgroup parent. -->
  <xsl:param name="rem"/>
  <xsl:variable name="al" select="((ancestor-or-self::*[@align])[last()])/@align"/>

  <!-- Le mode d'alignement a produire depend si une taille de colonne est
       definie. -->
  <xsl:call-template name="build.align">
    <xsl:with-param name="align" select="$al"/>
    <xsl:with-param name="small" select="0"/>
  </xsl:call-template>
  <xsl:text>p{</xsl:text>
  <xsl:choose>
  <xsl:when test="@colwidth">
    <xsl:choose>
    <xsl:when test="contains(@colwidth, 'cm')">
      <xsl:value-of select="@colwidth"/>
    </xsl:when>
    <xsl:when test="contains(@colwidth, '*') and substring-before(@colwidth, '*')!=''">
      <xsl:text>\tsize{</xsl:text>
      <xsl:value-of select="substring-before(@colwidth, '*')"/>
      <xsl:text>}</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>\tsize{1}</xsl:text>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>\tsize{1}</xsl:text>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:text>}</xsl:text>

  <!-- print the column separator -->
  <xsl:if test="$rem > 0">
    <xsl:call-template name="build.colsep"/>
  </xsl:if>
</xsl:template>


</xsl:stylesheet>
