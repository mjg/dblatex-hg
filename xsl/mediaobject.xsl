<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    Feuille de style de transformation XML DocBook -> LaTeX 
    ############################################################################ -->


<xsl:template match="videoobject">
  <xsl:apply-templates select="videodata"/>
</xsl:template>

<xsl:template match="audioobject">
  <xsl:apply-templates select="audiodata"/>
</xsl:template>

<xsl:template match="textobject">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="mediaobject|inlinemediaobject">
  <xsl:if test="self::mediaobject">
    <xsl:text>&#10;</xsl:text>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="imageobject">
      <xsl:apply-templates select="imageobject[1]"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="textobject[1]"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="self::mediaobject">
    <xsl:text>&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="imageobject">
  <xsl:text>\fbox{</xsl:text>
  <xsl:apply-templates select="imagedata"/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template name="unit.eval">
  <xsl:param name="length"/>
  <xsl:param name="prop" select="''"/>
  <xsl:choose>
  <!-- percentage of something -->
  <xsl:when test="contains($length, '%') and substring-after($length, '%')=''">
    <xsl:value-of select="number(substring-before($length, '%')) div 100"/>
    <xsl:value-of select="$prop"/>
  </xsl:when>
  <!-- pixel unit is not handled -->
  <xsl:when test="contains($length, 'px') and substring-after($length, 'px')=''">
    <xsl:message>Pixel unit not handled (replaced by pt)</xsl:message>
    <xsl:value-of select="number(substring-before($length, 'px'))"/>
    <xsl:text>pt</xsl:text>
  </xsl:when>
  <!-- no unit provided means pixel -->
  <xsl:when test="$length and (number($length)=$length)">
    <xsl:message>Pixel unit not handled (replaced by pt)</xsl:message>
    <xsl:value-of select="$length"/>
    <xsl:text>pt</xsl:text>
  </xsl:when>
  <!-- hope the unit is handled -->
  <xsl:otherwise>
    <xsl:value-of select="$length"/>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="imagedata" name="imagedata">
  <xsl:variable name="filename">
    <xsl:choose>
    <xsl:when test="@fileref">
      <xsl:value-of select="@fileref"/>
    </xsl:when>
    <xsl:when test="@entityref">
      <xsl:value-of select="unparsed-entity-uri(@entityref)"/>
    </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="width">
    <xsl:call-template name="unit.eval">
      <xsl:with-param name="length" select="@width"/>
      <xsl:with-param name="prop" select="'\linewidth'"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="depth">
    <xsl:call-template name="unit.eval">
      <xsl:with-param name="length" select="@depth"/>
      <xsl:with-param name="prop" select="'\textheight'"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="viewport">
    <xsl:choose>
    <xsl:when test="(@width or @depth) and (@contentwidth or @contentdepth or @scale
                     or @scalefit='0')">
      <xsl:value-of select="1"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="0"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="count(ancestor::figure/mediaobject[imageobject]) &gt; 1">
    <xsl:text>\subfigure[</xsl:text>
    <xsl:value-of select="../../caption"/>
    <xsl:text>]</xsl:text>
  </xsl:if>
  <xsl:text>{</xsl:text>
  <xsl:if test="$viewport=1">
    <xsl:text>\begin{minipage}[c]</xsl:text>
    <xsl:if test="@depth">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="$depth"/>
      <xsl:text>]</xsl:text>
      <xsl:text>[</xsl:text>
      <!-- vertical alignment -->
      <xsl:choose>
      <xsl:when test="@valign='bottom'">
        <xsl:text>b</xsl:text>
      </xsl:when>
      <xsl:when test="@valign='middle'">
        <xsl:text>c</xsl:text>
      </xsl:when>
      <xsl:when test="@valign='top'">
        <xsl:text>t</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>c</xsl:text>
      </xsl:otherwise>
      </xsl:choose>
      <xsl:text>]</xsl:text>
    </xsl:if>
    <xsl:text>{</xsl:text>
    <xsl:choose>
    <xsl:when test="@width">
      <xsl:value-of select="$width"/>
    </xsl:when>
    <xsl:when test="ancestor::mediaobject">
      <xsl:text>\linewidth</xsl:text>
    </xsl:when>
    <!-- TODO: inline viewport area should be as wide as the graphic -->
    <!--  <xsl:text>\figwidth</xsl:text> -->
    <xsl:otherwise>
      <xsl:text>\linewidth</xsl:text>
    </xsl:otherwise>
    </xsl:choose>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <!-- horizontal alignment -->
  <xsl:choose>
  <xsl:when test="@align='center'">
    <xsl:text>\centering </xsl:text>
  </xsl:when>
  <xsl:when test="@align='left'">
    <xsl:text>\raggedright </xsl:text>
  </xsl:when>
  <xsl:when test="@align='right'">
    <xsl:text>\raggedleft </xsl:text>
  </xsl:when>
  </xsl:choose>
  <xsl:text>{\includegraphics[</xsl:text>
  <xsl:choose>
    <!-- content area spec -->
    <xsl:when test="@contentwidth or @contentdepth"> 
      <xsl:choose>
      <xsl:when test="contains(@contentwidth, '%') and
                      substring-after(@contentwidth, '%')=''">
        <xsl:text>scale=</xsl:text>
        <xsl:value-of select="number(substring-before(@contentwidth, '%')) div 100"/>
      </xsl:when>
      <xsl:when test="contains(@contentdepth, '%') and
                      substring-after(@contentdepth, '%')=''">
        <xsl:text>scale=</xsl:text>
        <xsl:value-of select="number(substring-before(@contentdepth, '%')) div 100"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="@contentwidth">
          <xsl:text>width=</xsl:text>
          <xsl:call-template name="unit.eval">
            <xsl:with-param name="length" select="@contentwidth"/>
          </xsl:call-template>
          <xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:if test="@contentdepth">
          <xsl:text>height=</xsl:text>
          <xsl:call-template name="unit.eval">
            <xsl:with-param name="length" select="@contentdepth"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <!-- scaling -->
    <xsl:when test="@scale"> 
      <xsl:text>scale=</xsl:text>
      <xsl:value-of select="number(@scale) div 100"/>
    </xsl:when>
    <!-- only content area spec with scalefit -->
    <xsl:when test="not(@scalefit) or @scalefit='1'">
      <xsl:if test="@width">
        <xsl:text>width=</xsl:text>
        <xsl:value-of select="$width"/>
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:if test="@depth">
        <xsl:text>height=</xsl:text>
        <xsl:value-of select="$depth"/>
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>keepaspectratio=true</xsl:text>
    </xsl:when>
  </xsl:choose>
  <xsl:if test="@format = 'PRN'">
    <xsl:text>,angle=270</xsl:text>
  </xsl:if>
  <xsl:text>]{</xsl:text>
  <xsl:value-of select="$filename"/>
  <xsl:text>}}\quad&#10;</xsl:text>
  <xsl:if test="$viewport=1">
    <xsl:text>\end{minipage}&#10;</xsl:text>
  </xsl:if>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>


</xsl:stylesheet>

