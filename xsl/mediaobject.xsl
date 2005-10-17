<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<!-- Mediaobject/imagedata parameters -->
<xsl:param name="imagedata.default.scale">pagebound</xsl:param>
<xsl:param name="mediaobject.caption.style">\slshape</xsl:param>


<xsl:template match="videoobject">
  <xsl:apply-templates select="videodata"/>
</xsl:template>

<xsl:template match="audioobject">
  <xsl:apply-templates select="audiodata"/>
</xsl:template>

<xsl:template match="textobject">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="mediaobject/caption">
  <xsl:text>{</xsl:text>
  <xsl:value-of select="$mediaobject.caption.style"/>
  <xsl:text> </xsl:text>
  <xsl:call-template name="normalize-scape">
    <xsl:with-param name="string" select="."/>
  </xsl:call-template>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="mediaobject|inlinemediaobject">
  <xsl:variable name="figcount"
                select="count(ancestor::figure/mediaobject[imageobject])"/>
  <!--
  within a figure don't put each mediaobject into a separate paragraph, 
  to let the subfigures correctly displayed.
  -->
  <xsl:if test="self::mediaobject and not(parent::figure)">
    <xsl:text>&#10;</xsl:text>
    <xsl:text>\begin{minipage}[c]{\linewidth}&#10;</xsl:text>
    <xsl:text>\begin{center}&#10;</xsl:text>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="imageobject">
      <xsl:apply-templates select="imageobject[1]"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="textobject[1]"/>
    </xsl:otherwise>
  </xsl:choose>
  <!-- print the caption if not in a float, or is single -->
  <xsl:if test="caption and ($figcount &lt;= 1)">
    <xsl:text>\begin{center}&#10;</xsl:text>
    <xsl:apply-templates select="caption"/>
    <xsl:text>\end{center}&#10;</xsl:text>
  </xsl:if> 
  <xsl:if test="self::mediaobject and not(parent::figure)">
    <xsl:text>\end{center}&#10;</xsl:text>
    <xsl:text>\end{minipage}&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="imageobject">
  <xsl:variable name="figcount"
                select="count(ancestor::figure/mediaobject[imageobject])"/>
  <xsl:if test="$figcount &gt; 1">
    <!-- space before subfigure to prevent from strange behaviour with other
         subfigures -->
    <xsl:text> \subfigure[</xsl:text>
    <xsl:apply-templates select="../caption"/>
    <xsl:text>]{</xsl:text>
  </xsl:if>
  <xsl:if test="$latex.figure.boxed = '1'">
    <xsl:text>\fbox{</xsl:text>
  </xsl:if>
  <xsl:apply-templates select="imagedata"/>
  <xsl:if test="$latex.figure.boxed = '1'">
    <xsl:text>}</xsl:text>
  </xsl:if>
  <xsl:if test="$figcount &gt; 1">
    <xsl:text>}</xsl:text>
  </xsl:if>
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

<xsl:template name="image.default.set">
  <xsl:choose>
  <xsl:when test="$imagedata.default.scale='pagebound'">
    <!-- use the natural size up to the page boundaries -->
    <xsl:text>width=\imgwidth,height=\imgheight,keepaspectratio=true</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <!-- put the parameter value as is -->
    <xsl:value-of select="$imagedata.default.scale"/>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- the latex macro to use to include a graphic depends on the environment -->
<xsl:template name="graphic.begin.get">
  <xsl:choose>
  <xsl:when test="ancestor::imageobjectco">
    <xsl:apply-templates select="ancestor::imageobjectco" mode="graphic.begin"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>\includegraphics</xsl:text>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="graphic.end.get">
  <xsl:if test="ancestor::imageobjectco">
    <xsl:apply-templates select="ancestor::imageobjectco" mode="graphic.end"/>
  </xsl:if>
</xsl:template>

<xsl:template match="imagedata" name="imagedata">
  <xsl:variable name="graphic.begin">
    <xsl:call-template name="graphic.begin.get"/>
  </xsl:variable>
  <xsl:variable name="graphic.end">
    <xsl:call-template name="graphic.end.get"/>
  </xsl:variable>

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
  <!-- viewport is valid only if there's some viewport spec, and content or
       scale. TDG says that viewport spec without content/scale and scalefit=0
       is ignored. -->
  <xsl:variable name="viewport">
    <xsl:choose>
    <xsl:when test="(@width or @depth) and
                    (@contentwidth or @contentdepth or @scale)">
      <xsl:value-of select="1"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="0"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:text>{</xsl:text>
  <xsl:if test="$viewport=1">
    <xsl:text>\begin{minipage}[c]</xsl:text>
    <xsl:if test="@depth">
      <!-- depth -->
      <xsl:text>[</xsl:text>
      <xsl:value-of select="$depth"/>
      <xsl:text>]</xsl:text>
      <xsl:text>[</xsl:text>
      <!-- vertical alignment (meaningfull only with depth) -->
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
    <!-- width -->
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

  <!-- find out the natural image size -->
  <xsl:if test="$imagedata.default.scale='pagebound'">
    <xsl:text>\imgevalsize{</xsl:text>
    <xsl:value-of select="$filename"/>
    <xsl:text>}</xsl:text>
  </xsl:if>
  <xsl:text>{</xsl:text>
  <xsl:value-of select="$graphic.begin"/>
  <xsl:text>[</xsl:text>
  <!-- TDG says that content, scale and scalefit are mutually exclusive -->
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
    <!-- only viewport area spec with scalefit -->
    <xsl:when test="(not(@scalefit) or @scalefit='1') and (@width or @depth)">
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
      <!-- TDG says that scale to fit cannot be anamorphic -->
      <xsl:text>keepaspectratio=true</xsl:text>
    </xsl:when>
    <!-- default scaling (if any) -->
    <xsl:otherwise>
      <xsl:call-template name="image.default.set"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="@format = 'PRN'">
    <xsl:text>,angle=270</xsl:text>
  </xsl:if>
  <xsl:text>]{</xsl:text>
  <xsl:value-of select="$filename"/>
  <xsl:text>}</xsl:text>
  <xsl:value-of select="$graphic.end"/>
  <xsl:text>}\quad&#10;</xsl:text>
  <xsl:if test="$viewport=1">
    <xsl:text>\end{minipage}&#10;</xsl:text>
  </xsl:if>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>


</xsl:stylesheet>

