<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<!-- Table group formatting expecting texclean post-processing -->

<xsl:template name="tgroup.build">
  <xsl:param name="kind"/>
  <xsl:variable name="align" select="@align"/>
  <xsl:variable name="cols" select="@cols"/>
  <xsl:variable name="colspecs" select="colspec"/>
  <xsl:variable name="frame" select="parent::*/@frame"/>

  <xsl:text>%%% parse_table %%%&#10;</xsl:text>
  <xsl:call-template name="resizetable">
    <xsl:with-param name="pos" select="'1'"/>
    <xsl:with-param name="variacols" select="@cols"/>
    <xsl:with-param name="colspecs" select="colspec"/>
  </xsl:call-template>

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

  <xsl:if test="not($frame) or
                ($frame!='sides' and $frame!='none' and $frame!='bottom')">
    <xsl:text>\hline &#10;</xsl:text>
  </xsl:if>
  <xsl:apply-templates/>
  <xsl:if test="not($frame) or
                ($frame!='sides' and $frame!='none' and $frame!='top')">
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
  <xsl:if test="not(ancestor::*[@rowsep]) or
                ((ancestor::*[@rowsep])[last()])[@rowsep='1']">
    <xsl:text>\hline &#10;</xsl:text>
    <xsl:text>\hline &#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="informaltable/tgroup/thead/row[position()=last()]">
  <xsl:text>\rowcolor[gray]{.9} &#10;</xsl:text>
  <xsl:apply-templates/>
  <xsl:variable name="hline">
    <xsl:if test="not(ancestor::*[@rowsep]) or
                  ((ancestor::*[@rowsep])[last()])[@rowsep='1']">
      <xsl:text>\hline &#10;</xsl:text>
    </xsl:if>
  </xsl:variable>
  <xsl:value-of select="$hline"/>
  <xsl:text>\endhead &#10;</xsl:text> 
  <xsl:value-of select="$hline"/>
</xsl:template>

<xsl:template match="thead/row/entry">
  <xsl:apply-templates/>
  <xsl:choose>
  <xsl:when test="position()=last()">
    <xsl:text> \tabularnewline &#10;</xsl:text> 
  </xsl:when>
  <xsl:otherwise>
    <xsl:text> &amp; </xsl:text> 
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- the function gives the colnum of a colspec by selecting the closest preceding
     colspecs having a (@colnum) attribute set. If no preceding with @colnum,
     colnum is the count of colspecs -->

<xsl:template name="give.colspec.num">
  <xsl:param name="n"/>
  <xsl:choose>
  <!-- to be faster let's check the node first -->
  <xsl:when test="$n/@colnum">
    <xsl:value-of select="$n/@colnum"/>
  </xsl:when>
  <xsl:otherwise>
    <!-- $n/colnum = $np/@colmum + position($n) - position($np) -->
    <xsl:variable name="prev" select="$n/preceding-sibling::colspec"/>
    <xsl:variable name="p" select="count($prev)"/>
    <xsl:variable name="np" select="(($prev[position()&lt;=$p])[@colnum])[last()]"/>
    <xsl:choose>
    <xsl:when test="$np">
      <xsl:variable name="off" select="$p - count($np/preceding-sibling::colspec)"/>
      <xsl:value-of select="$off + $np/@colnum"/>
    </xsl:when>
    <!-- no previous colspec with @colnum, then colnum = position -->
    <xsl:otherwise>
      <xsl:value-of select="$p+1"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="build.colspan">
  <xsl:param name="n1" select="@namest"/>
  <xsl:param name="n2" select="@nameend"/>
  <xsl:param name="nspec" select="."/>
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
    <xsl:call-template name="build.vframe"/>
  </xsl:if>
  <!-- cell alignment -->
  <xsl:call-template name="build.align">
    <xsl:with-param name="small" select="'1'"/>
    <xsl:with-param name="align">
      <xsl:choose>
      <xsl:when test="@align">
        <xsl:value-of select="@align"/>
      </xsl:when>
      <xsl:when test="$nspec/@align">
        <xsl:value-of select="$nspec/@align"/>
      </xsl:when>
      <xsl:when test="$c1/@align">
        <xsl:value-of select="$c1/@align"/>
      </xsl:when>
      <xsl:when test="ancestor::*[@align]">
        <xsl:value-of select="((ancestor::*[@align])[last()])/@align"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'left'"/>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
  </xsl:call-template>
  <!-- the right colsep depends on @frame if last or @colsep if not -->
  <xsl:choose>
  <xsl:when test="$p2 &lt; ancestor::tgroup/@cols">
    <xsl:call-template name="build.colsep">
      <xsl:with-param name="nspec" select="$nspec"/>
    </xsl:call-template>
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
      <xsl:with-param name="nspec" select="$span"/>
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates/>
  </xsl:otherwise>
  </xsl:choose>
  <!-- for Perl post-processing -->
  <xsl:if test="@namest or @colname">
    <xsl:text>%&lt;num=</xsl:text>
    <xsl:variable name="name">
      <xsl:choose>
      <xsl:when test="@colname">
        <xsl:value-of select="@colname"/>
      </xsl:when>
      <xsl:when test="@namest">
        <xsl:value-of select="@namest"/>
      </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="give.colspec.num">
      <xsl:with-param name="n" select="ancestor::*/colspec[@colname=$name]"/>
    </xsl:call-template>
    <xsl:text>&gt;%&#10;</xsl:text>
  </xsl:if>
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
    <xsl:text>p{\tsize}</xsl:text>
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


<!-- The right column separator is defined by the closest @colsep
     value (i.e. the node attribute or the immediate ancestor).
     If not defined the default behaviour is to have a column
  -->

<xsl:template name="build.colsep">
  <xsl:param name="nspec" select="."/>
  <xsl:variable name="n" select="(ancestor-or-self::*[@colsep])[last()]"/>
  <xsl:choose>
  <xsl:when test="$nspec/@colsep">
    <xsl:if test="$nspec/@colsep='1'">
      <xsl:text>|</xsl:text>
    </xsl:if>
  </xsl:when>
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

<xsl:template name="star.count">
  <xsl:param name="width"/>
  <xsl:param name="count" select="'0'"/>

  <!-- Part to parse -->
  <xsl:variable name="w0">
    <xsl:choose>
    <xsl:when test="contains($width, '+')">
      <xsl:value-of select="substring-before($width, '+')"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$width"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Get the star count -->
  <xsl:variable name="val">
    <xsl:choose>
    <xsl:when test="contains($w0, '*')">
      <xsl:variable name="factor" select="substring-before($w0, '*')"/>
      <xsl:choose>
      <xsl:when test="$factor=''">
        <xsl:value-of select="'1'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$factor"/>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="'0'"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Update the star count, and work on the other part if any -->
  <xsl:choose>
  <xsl:when test="contains($width, '+')">
    <xsl:call-template name="star.count">
      <xsl:with-param name="width" select="substring-after($width, '+')"/>
      <xsl:with-param name="count" select="$count + $val"/>
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="$count + $val"/>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="fixed.select">
  <xsl:param name="width"/>
  <xsl:param name="fixed" select="''"/>

  <!-- Part to parse -->
  <xsl:variable name="w0">
    <xsl:choose>
    <xsl:when test="contains($width, '+')">
      <xsl:value-of select="substring-before($width, '+')"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$width"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Filter the fixed width -->
  <xsl:variable name="val">
    <xsl:if test="not(contains($w0, '*'))">
      <xsl:value-of select="$w0"/>
    </xsl:if>
  </xsl:variable>

  <!-- Update the fixed pattern, and work on the other part if any -->
  <xsl:variable name="newfixed">
    <xsl:if test="$fixed!=''">
      <xsl:value-of select="$fixed"/>
      <xsl:if test="$val!=''">
        <xsl:text>+</xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:value-of select="$val"/>
  </xsl:variable>
  
  <xsl:choose>
  <xsl:when test="contains($width, '+')">
    <xsl:call-template name="fixed.select">
      <xsl:with-param name="width" select="substring-after($width, '+')"/>
      <xsl:with-param name="fixed" select="$newfixed"/>
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="$newfixed"/>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Summarize the total fixed width and stars for the entire table -->

<xsl:template name="resizetable">
  <xsl:param name="pos"/>
  <xsl:param name="variacols"/>
  <xsl:param name="fixedwidth" select="''"/>
  <xsl:param name="colspecs"/>

  <xsl:variable name="spec" select="$colspecs[position()=$pos]"/>
  <xsl:choose>
  <xsl:when test="$spec">
    <xsl:variable name="cw" select="$spec/@colwidth"/>

    <!-- Number of stars contained in this colwidth -->
    <xsl:variable name="this.star">
      <xsl:choose>
      <xsl:when test="$cw">
        <xsl:call-template name="star.count">
          <xsl:with-param name="width" select="$cw"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- No colwidth mean '*' -->
        <xsl:value-of select="'1'"/>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
 
    <!-- Fixed size update -->
    <xsl:variable name="width">
      <xsl:variable name="this.fixed">
        <xsl:call-template name="fixed.select">
          <xsl:with-param name="width" select="$cw"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="$fixedwidth!=''">
        <xsl:value-of select="$fixedwidth"/>
        <xsl:if test="$this.fixed!=''">
          <xsl:text>+</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:value-of select="$this.fixed"/>
    </xsl:variable>
 
    <xsl:call-template name="resizetable">
      <xsl:with-param name="pos" select="$pos + 1"/>
      <xsl:with-param name="variacols" select="$variacols + $this.star -1"/>
      <xsl:with-param name="fixedwidth" select="$width"/>
      <xsl:with-param name="colspecs" select="$colspecs"/>
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
    <!-- All the colspecs are done, so write the latex command -->
    <xsl:if test="$variacols &gt; 0">
      <xsl:text>\resizetable{</xsl:text>
      <xsl:value-of select="$variacols"/>
      <xsl:text>}{</xsl:text>
      <xsl:value-of select="@cols"/>
      <xsl:text>}{</xsl:text>
      <xsl:value-of select="$fixedwidth"/>
      <xsl:text>}{</xsl:text>
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
    <xsl:call-template name="replace-string" mode="newtbl">
      <xsl:with-param name="text" select="@colwidth"/>
      <xsl:with-param name="replace">*</xsl:with-param>
      <xsl:with-param name="with">\tsize</xsl:with-param>
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>\tsize</xsl:text>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:text>}</xsl:text>

  <!-- print the column separator -->
  <xsl:if test="$rem > 0">
    <xsl:call-template name="build.colsep"/>
  </xsl:if>
</xsl:template>


</xsl:stylesheet>
