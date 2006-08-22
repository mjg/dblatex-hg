<?xml version='1.0' encoding="utf-8" ?>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
    xmlns:exsl="http://exslt.org/common"
    exclude-result-prefixes="doc exsl" version='1.0'>
  
<!--==================== newtbl table handling ========================-->
<!--=                                                                 =-->
<!--= Copyright (C) 2004-2006 Vistair Systems Ltd (www.vistair.com)   =-->
<!--=                                                                 =-->
<!--= Released under the GNU General Public Licence (GPL)             =-->
<!--= (Commercial and other licences by arrangement)                  =-->
<!--=                                                                 =-->
<!--= Release 23/04/2006 by DCRH                                      =-->
<!--=                                                                 =-->
<!--= Email david@vistair.com with bugs, comments etc                 =-->
<!--=                                                                 =-->
<!--===================================================================-->

<!-- Step though each column, generating a colspec entry for it. If a  -->
<!-- colspec was given in the xml, then use it, otherwise generate a -->
<!-- default one -->
<xsl:template name="tbl.defcolspec" mode="newtbl">
  <xsl:param name="colnum" select="1"/>
  <xsl:param name="colspec"/>
  <xsl:param name="align"/>
  <xsl:param name="rowsep"/>
  <xsl:param name="colsep"/>
  <xsl:param name="cols"/>
  
  <xsl:if test="$colnum &lt;= $cols">
    <xsl:choose>
      <xsl:when test="$colspec/colspec[@colnum = $colnum]">
        <xsl:copy-of select="$colspec/colspec[@colnum = $colnum]"/>
      </xsl:when>
      <xsl:otherwise>
        <colspec colnum='{$colnum}' align='{$align}' star='1'
                 rowsep='{$rowsep}' colsep='{$colsep}' 
                 colwidth='\newtblstarfactor'/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="tbl.defcolspec" mode="newtbl">
      <xsl:with-param name="colnum" select="$colnum + 1"/>
      <xsl:with-param name="align" select="$align"/>
      <xsl:with-param name="rowsep" select="$rowsep"/>
      <xsl:with-param name="colsep" select="$colsep"/>
      <xsl:with-param name="cols" select="$cols"/>
      <xsl:with-param name="colspec" select="$colspec"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>



<!-- replace-string function as XSLT doesn't have one built in. -->
<xsl:template name="replace-string" mode="newtbl">
  <xsl:param name="text"/>
  <xsl:param name="replace"/>
  <xsl:param name="with"/>
  <xsl:choose>
    <xsl:when test="contains($text,$replace)">
      <xsl:value-of select="substring-before($text,$replace)"/>
      <xsl:value-of select="$with"/>
      <xsl:call-template name="replace-string">
        <xsl:with-param name="text"
                        select="substring-after($text,$replace)"/>
        <xsl:with-param name="replace" select="$replace"/>
        <xsl:with-param name="with" select="$with"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$text"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- This template extracts the fixed part of a colwidth specification.
     It should be able to do this:
     a+b+c+d*+e+f -> a+b+c+e+f
     a+b+c+d*     -> a+b+c
     d*+e+f       -> e+f      
-->
<xsl:template name="colfixed.get">
  <xsl:param name="width" select="@colwidth"/>
  <xsl:param name="stared" select="'0'"/>
  
  <xsl:choose>
    <xsl:when test="contains($width, '*')">
      <xsl:variable name="after"
                    select="substring-after(substring-after($width, '*'), '+')"/>
      <xsl:if test="contains(substring-before($width, '*'), '+')">
        <xsl:call-template name="colfixed.get">
          <xsl:with-param name="width" select="substring-before($width, '*')"/>
          <xsl:with-param name="stared" select="'1'"/>
        </xsl:call-template>
        <xsl:if test="$after!=''">
          <xsl:text>+</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:value-of select="$after"/>
    </xsl:when>
    <xsl:when test="$stared='1'">
      <xsl:value-of select="substring-before($width, '+')"/>
      <xsl:if test="contains(substring-after($width, '+'), '+')">
        <xsl:text>+</xsl:text>
        <xsl:call-template name="colfixed.get">
          <xsl:with-param name="width" select="substring-after($width, '+')"/>
          <xsl:with-param name="stared" select="'1'"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$width"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="colstar.get">
  <xsl:param name="width"/>
  <xsl:choose>
    <xsl:when test="contains($width, '+')">
      <xsl:call-template name="colstar.get">
        <xsl:with-param name="width" select="substring-after($width, '+')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="string(number($width))='NaN'">1</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="number($width)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>



<!-- Ensure each column has a colspec and each colspec has a valid column -->
<!-- number, width, alignment, colsep, rowsep -->
<xsl:template match="colspec" mode="newtbl">
  <xsl:param name="colnum" select="1"/>
  <xsl:param name="align"/>
  <xsl:param name="colsep"/>
  <xsl:param name="rowsep"/>
  
  <xsl:copy>
    <xsl:for-each select="@*"><xsl:copy/></xsl:for-each>
    <xsl:if test="not(@colnum)">
      <xsl:attribute name="colnum"><xsl:value-of select="$colnum"/>
      </xsl:attribute>
    </xsl:if>
    <!-- Find out if the column width contains fixed width -->
    <xsl:variable name="fixed">
      <xsl:call-template name="colfixed.get"/>
    </xsl:variable>
    
    <xsl:if test="$fixed!=''">
      <xsl:attribute name="fixedwidth">
        <xsl:value-of select="$fixed"/>
      </xsl:attribute>
    </xsl:if>
    <!-- Replace '*' with our to-be-computed factor -->
    <xsl:if test="contains(@colwidth,'*')">
      <xsl:attribute name="colwidth">
        <xsl:call-template name="replace-string" mode="newtbl">
          <xsl:with-param name="text" select="@colwidth"/>
          <xsl:with-param name="replace">*</xsl:with-param>
          <xsl:with-param name="with">\newtblstarfactor</xsl:with-param>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:attribute name="star">
        <xsl:call-template name="colstar.get">
          <xsl:with-param name="width" select="substring-before(@colwidth, '*')"/>
        </xsl:call-template>
      </xsl:attribute>
    </xsl:if>
    <!-- No colwidth specified? Assume '*' -->
    <xsl:if test="not(string(@colwidth))">
      <xsl:attribute name="colwidth">\newtblstarfactor</xsl:attribute>
      <xsl:attribute name="star">1</xsl:attribute>
    </xsl:if>
    <xsl:if test="not(@align)">
      <xsl:attribute name="align"><xsl:value-of select="$align"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="not(@rowsep)">
      <xsl:attribute name="rowsep"><xsl:value-of select="$rowsep"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="not(@colsep)">
      <xsl:attribute name="colsep"><xsl:value-of select="$colsep"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:copy>
  
  <xsl:variable name="nextcolnum">
    <xsl:choose>
      <xsl:when test="@colnum"><xsl:value-of select="@colnum + 1"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$colnum + 1"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:apply-templates mode="newtbl"
                       select="following-sibling::colspec[1]">
    <xsl:with-param name="colnum" select="$nextcolnum"/>
    <xsl:with-param name="align" select="$align"/>
    <xsl:with-param name="colsep" select="$colsep"/>
    <xsl:with-param name="rowsep" select="$rowsep"/>
  </xsl:apply-templates>
</xsl:template>



<!-- Generate a complete set of colspecs for each column in the table -->
<xsl:template name="tbl.colspec" mode="newtbl">
  <xsl:param name="align"/>
  <xsl:param name="rowsep"/>
  <xsl:param name="colsep"/>
  <xsl:param name="cols"/>
  
  <!-- First, get the colspecs that have been specified -->
  <xsl:variable name="givencolspec">
    <xsl:apply-templates mode="newtbl" select="colspec[1]">
      <xsl:with-param name="align" select="$align"/>
      <xsl:with-param name="rowsep" select="$rowsep"/>
      <xsl:with-param name="colsep" select="$colsep"/>
    </xsl:apply-templates>
  </xsl:variable>
  
  <!-- Now generate colspecs for each missing column -->
  <xsl:call-template name="tbl.defcolspec" mode="newtbl">
    <xsl:with-param name="colspec" select="exsl:node-set($givencolspec)"/>
    <xsl:with-param name="cols" select="$cols"/>
    <xsl:with-param name="align" select="$align"/>
    <xsl:with-param name="rowsep" select="$rowsep"/>
    <xsl:with-param name="colsep" select="$colsep"/>
  </xsl:call-template>
</xsl:template>



<!-- Create a blank entry element. We check the 'entries' node-set -->
<!-- to see if we should copy an entry from the row above instead -->
<xsl:template name="tbl.blankentry" mode="newtbl">
  <xsl:param name="colnum"/>
  <xsl:param name="colend"/>
  <xsl:param name="rownum"/>
  <xsl:param name="colspec"/>
  <xsl:param name="entries"/>
  
  <xsl:if test="$colnum &lt;= $colend">
    <xsl:choose>
      <xsl:when test="$entries/entry[@colstart=$colnum and 
                      @rowend &gt;= $rownum]">
        <!-- Just copy this entry then -->
        <xsl:copy-of select="$entries/entry[@colstart=$colnum]"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- No rowspan entry found from the row above, so create a blank -->
        <entry colstart='{$colnum}' colend='{$colnum}' 
               rowstart='{$rownum}' rowend='{$rownum}'
               colsep='{$colspec/colspec[@colnum=$colnum]/@colsep}'
               defrowsep='{$colspec/colspec[@colnum=$colnum]/@rowsep}'
               align='{$colspec/colspec[@colnum=$colnum]/@align}'/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:variable name="nextcol">
      <xsl:choose>
        <xsl:when test="$entries/entry[@colstart=$colnum and 
                        @rowend &gt;= $rownum]">
          <xsl:value-of select="$entries/entry[@colstart=$colnum]/@colend"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$colnum"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="tbl.blankentry" mode="newtbl">
      <xsl:with-param name="colnum" select="$nextcol + 1"/>
      <xsl:with-param name="colend" select="$colend"/>
      <xsl:with-param name="rownum" select="$rownum"/>
      <xsl:with-param name="colspec" select="$colspec"/>
      <xsl:with-param name="entries" select="$entries"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>



<!-- Returns a RTF of entry elements. rowsep, colsep and align are all -->
<!-- extracted from spanspec/colspec as required -->
<!-- Skipped columns have blank entry elements created -->
<!-- Existing entry elements in the given entries node-set are checked to -->
<!-- see if they should extend into this row and are copied if so -->
<!-- Each element is given additional attributes: -->
<!-- rowstart = The top row number of the table this entry -->
<!-- rowend = The bottom row number of the table this entry -->
<!-- colstart = The starting column number of this entry -->
<!-- colend = The ending column number of this entry -->
<!-- defrowsep = The default rowsep value inherited from the entry's span -->
<!--     or colspec -->
<xsl:template match="entry" mode="newtbl.buildentries">
  <xsl:param name="colnum"/>
  <xsl:param name="rownum"/>
  <xsl:param name="colspec"/>
  <xsl:param name="spanspec"/>
  <xsl:param name="frame"/>
  <xsl:param name="entries"/>
  
  <xsl:variable name="cols" select="count($colspec/*)"/>
  
  <xsl:if test="$colnum &lt;= $cols">
    
    <!-- Do we have an existing entry element from a previous row that -->
    <!-- should be copied into this row? -->
    <xsl:choose><xsl:when test="$entries/entry[@colstart=$colnum and 
                                @rowend &gt;= $rownum]">
      <!-- Just copy this entry then -->
      <xsl:copy-of select="$entries/entry[@colstart=$colnum]"/>
      
      <!-- Process the next column using this current entry -->
      <xsl:apply-templates mode="newtbl.buildentries" select=".">
        <xsl:with-param name="colnum" 
                        select="$entries/entry[@colstart=$colnum]/@colend + 1"/>
        <xsl:with-param name="rownum" select="$rownum"/>
        <xsl:with-param name="colspec" select="$colspec"/>
        <xsl:with-param name="spanspec" select="$spanspec"/>
        <xsl:with-param name="frame" select="$frame"/>
        <xsl:with-param name="entries" select="$entries"/>
      </xsl:apply-templates>
      </xsl:when><xsl:otherwise>
      <!-- Get any span for this entry -->
      <xsl:variable name="span">
        <xsl:if test="@spanname and $spanspec[@spanname=current()/@spanname]">
          <xsl:copy-of select="$spanspec[@spanname=current()/@spanname]"/>
        </xsl:if>
      </xsl:variable>
      
      <!-- Get the starting column number for this cell -->
      <xsl:variable name="colstart">
        <xsl:choose>
          <!-- Check colname first -->
          <xsl:when test="$colspec/colspec[@colname=current()/@colname]">
            <xsl:value-of
                select="$colspec/colspec[@colname=current()/@colname]/@colnum"/>
          </xsl:when>
          <!-- Now check span -->
          <xsl:when test="exsl:node-set($span)/spanspec/@namest">
            <xsl:value-of select="$colspec/colspec[@colname=
                                  exsl:node-set($span)/spanspec/@namest]/@colnum"/>
          </xsl:when>
          <!-- Now check namest attribute -->
          <xsl:when test="@namest">
            <xsl:value-of select="$colspec/colspec[@colname=
                                  current()/@namest]/@colnum"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$colnum"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <!-- Get the ending column number for this cell -->
      <xsl:variable name="colend">
        <xsl:choose>
          <!-- Check span -->
          <xsl:when test="exsl:node-set($span)/spanspec/@nameend">
            <xsl:value-of select="$colspec/colspec[@colname=
                                  exsl:node-set($span)/spanspec/@nameend]/@colnum"/>
          </xsl:when>
          <!-- Check nameend attribute -->
          <xsl:when test="@nameend">
            <xsl:value-of select="$colspec/colspec[@colname=
                                  current()/@nameend]/@colnum"/>
          </xsl:when>
          <!-- Otherwise end == start -->
          <xsl:otherwise>
            <xsl:value-of select="$colstart"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <!-- Does this entry want to start at a later column? -->
      <xsl:if test="$colnum &lt; $colstart">
        <!-- If so, create some blank entries to fill in the gap -->
        <xsl:call-template name="tbl.blankentry" mode="newtbl">
          <xsl:with-param name="colnum" select="$colnum"/>
          <xsl:with-param name="colend" select="$colstart - 1"/>
          <xsl:with-param name="colspec" select="$colspec"/>
          <xsl:with-param name="rownum" select="$rownum"/>
          <xsl:with-param name="entries" select="$entries"/>
        </xsl:call-template>
      </xsl:if>
      
      <!-- Get the colsep override from this entry or its span -->
      <xsl:variable name="colsep">
        <xsl:choose>
          <!-- Entry element override -->
          <xsl:when test="@colsep"><xsl:value-of select="@colsep"/></xsl:when>
          <!-- Then any span present -->
          <xsl:when test="exsl:node-set($span)/spanspec/@colsep">
            <xsl:value-of select="exsl:node-set($span)/spanspec/@colsep"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- Otherwise take from colspec -->
            <xsl:value-of select="$colspec/colspec[@colnum=$colstart]/@colsep"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <!-- Get the default rowsep for this entry -->
      <xsl:variable name="defrowsep">
        <xsl:choose>
          <!-- Check any span present -->
          <xsl:when test="exsl:node-set($span)/spanspec/@rowsep">
            <xsl:value-of select="exsl:node-set($span)/spanspec/@rowsep"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- Otherwise take from colspec -->
            <xsl:value-of select="$colspec/colspec[@colnum=$colstart]/@rowsep"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <!-- Generate cell alignment -->
      <xsl:variable name="align">
        <xsl:choose>
          <!-- Entry element attribute first -->
          <xsl:when test="string(@align)">
            <xsl:value-of select="@align"/>
          </xsl:when>
          <!-- Then any span present -->
          <xsl:when test="exsl:node-set($span)/spanspec/@align">
            <xsl:value-of select="exsl:node-set($span)/spanspec/@align"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- Otherwise take from colspec -->
            <xsl:value-of select="$colspec/colspec[@colnum=$colstart]/@align"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:copy>
        <xsl:for-each select="@*"><xsl:copy/></xsl:for-each>
        <xsl:attribute name="colstart">
          <xsl:value-of select="$colstart"/>
        </xsl:attribute>
        <xsl:attribute name="colend">
          <xsl:value-of select="$colend"/>
        </xsl:attribute>
        <xsl:attribute name="rowstart">
          <xsl:value-of select="$rownum"/>
        </xsl:attribute>
        <xsl:attribute name="rowend">
          <xsl:choose>
            <xsl:when test="@morerows and @morerows > 0">
              <xsl:value-of select="@morerows + $rownum"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$rownum"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="colsep">
          <xsl:value-of select="$colsep"/>
        </xsl:attribute>
        <xsl:attribute name="defrowsep">
          <xsl:value-of select="$defrowsep"/>
        </xsl:attribute>
        <xsl:attribute name="align">
          <xsl:value-of select="$align"/>
        </xsl:attribute>
        <!-- Process the output here, to stay in the document context. -->
        <!-- In RTF entries the document links/refs are lost -->
        <xsl:element name="output">
          <xsl:apply-templates select="." mode="output"/>
        </xsl:element>
      </xsl:copy>
      
      <!-- See if we've run out of entries for the current row -->
      <xsl:if test="$colend &lt; $cols and not(following-sibling::entry[1])">
        <!-- Create more blank entries to pad the row -->
        <xsl:call-template name="tbl.blankentry" mode="newtbl">
          <xsl:with-param name="colnum" select="$colend + 1"/>
          <xsl:with-param name="colend" select="$cols"/>
          <xsl:with-param name="colspec" select="$colspec"/>
          <xsl:with-param name="rownum" select="$rownum"/>
          <xsl:with-param name="entries" select="$entries"/>
        </xsl:call-template>
      </xsl:if>
      
      <xsl:apply-templates mode="newtbl.buildentries" 
                           select="following-sibling::entry[1]">
        <xsl:with-param name="colnum" select="$colend + 1"/>
        <xsl:with-param name="rownum" select="$rownum"/>
        <xsl:with-param name="colspec" select="$colspec"/>
        <xsl:with-param name="spanspec" select="$spanspec"/>
        <xsl:with-param name="frame" select="$frame"/>
        <xsl:with-param name="entries" select="$entries"/>
      </xsl:apply-templates>
    </xsl:otherwise></xsl:choose>
  </xsl:if>  <!-- $colnum <= $cols -->
</xsl:template>



<!-- Output the current entry node -->
<xsl:template match="entry" mode="newtbl">
  <xsl:param name="colspec"/>
  <xsl:param name="context"/>
  <xsl:param name="frame"/>
  <xsl:param name="rownum"/>
  <xsl:param name="valign"/>
  
  <xsl:variable name="cols" select="count($colspec/*)"/>
  <!--
      <xsl:if test="@colstart &gt; $cols">
      <xsl:message>BANG</xsl:message>
      </xsl:if>
  -->
  
  <xsl:if test="@colstart &lt;= $cols">
    
    <!--  <xsl:variable name="wordwrap" select="@align = 'justify' or para"/> -->
    <xsl:variable name="wordwrap" select="true()"/>
    
    <!-- Generate the column spec for this column -->
    <xsl:text>\multicolumn{</xsl:text>
    <xsl:value-of select="@colend - @colstart + 1"/>
    <xsl:text>}{</xsl:text>
    <xsl:call-template name="tbl.colfmt" mode="newtbl">
      <xsl:with-param name="colstart" select="@colstart"/>
      <xsl:with-param name="colend" select="@colend"/>
      <xsl:with-param name="colsep" select="@colsep"/>
      <xsl:with-param name="colspec" select="$colspec"/>
      <xsl:with-param name="frame" select="$frame"/>
      <xsl:with-param name="valign" select="$valign"/>
    </xsl:call-template>
    <xsl:text>}{</xsl:text>
    
    <!-- Put everything inside a multirow if required -->
    <xsl:if test="@morerows and @morerows > 0">
      <!-- Multirow doesn't use setlength and hence our calc stuff doesn't -->
      <!-- work. Do it manually then -->
      <xsl:if test="$wordwrap">
        <xsl:text>\setlength{\newtblcolwidth}{</xsl:text>
        <!-- Put the column width here for line wrapping -->
        <xsl:call-template name="tbl.colwidth" mode="newtbl">
          <xsl:with-param name="col" select="@colstart"/>
          <xsl:with-param name="colend" select="@colend"/>
          <xsl:with-param name="colspec" select="$colspec"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
      </xsl:if>
      <xsl:text>\multirowii{</xsl:text>
      <xsl:value-of select="@morerows + 1"/>
      <xsl:choose>
        <xsl:when test="$wordwrap">
          <xsl:text>}{</xsl:text>
          <!-- Only output the contents of this row if it's on the correct -->
          <!-- row -ve width means don't output the cell contents, but maybe -->
          <!-- just output a height spacer. -->
          <xsl:if test="@rowstart != $rownum">
            <xsl:text>-</xsl:text>
          </xsl:if>
          <xsl:text>\newtblcolwidth}{</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>}{*}{</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    
    <!-- Do rotate if required. What to do about line wrapping though?? -->
    <xsl:if test="@rotate and @rotate != 0">
      <xsl:text>\rotatebox{90}{</xsl:text>
    </xsl:if>
    
    <xsl:if test="$wordwrap">  
      <xsl:choose>
        <xsl:when test="@align = 'left'">
          <xsl:text>\raggedright</xsl:text>
        </xsl:when>
        <xsl:when test="@align = 'right'">
          <xsl:text>\raggedleft</xsl:text>
        </xsl:when>
        <xsl:when test="@align = 'center'">
          <xsl:text>\centering</xsl:text>
        </xsl:when>
        <xsl:when test="@align = 'justify'"></xsl:when>
        <xsl:otherwise>
          <xsl:message>Word-wrapped alignment <xsl:value-of 
          select="@align"/> not supported</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>  
    
    <!-- Apply some default formatting depending on context -->
    <xsl:choose>
      <xsl:when test="$context = 'thead'">
        <xsl:value-of select="$newtbl.format.thead"/>
      </xsl:when>
      <xsl:when test="$context = 'tbody'">
        <xsl:value-of select="$newtbl.format.tbody"/>
      </xsl:when>
      <xsl:when test="$context = 'tfoot'">
        <xsl:value-of select="$newtbl.format.tfoot"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Unknown context <xsl:value-of select="$context"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    
    <!-- Dump out the entry contents -->
    <xsl:text>%&#10;</xsl:text>
    <xsl:choose>
      <xsl:when test="output">
        <xsl:value-of select="output"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="output"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>%&#10;</xsl:text>
    
    <!-- Close off multirow if required -->
    <xsl:if test="@morerows and @morerows > 0">
      <xsl:text>}</xsl:text>
    </xsl:if>
    
    <!-- Close off rotate if required -->
    <xsl:if test="@rotate and @rotate != 0">
      <xsl:text>}</xsl:text>
    </xsl:if>
    
    <!-- End of the multicolumn -->
    <xsl:text>}</xsl:text>
    
    <!-- Put in the column separator -->
    <xsl:if test="@colend != $cols">
      <xsl:text>&amp;</xsl:text>
    </xsl:if>
    
  </xsl:if> <!-- colstart > cols -->
  
</xsl:template>


<!-- Process the entry content, and remove spurious empty lines -->
<xsl:template match="entry" mode="output">
  <xsl:call-template name="normalize-border">
    <xsl:with-param name="string">
      <xsl:apply-templates/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<!-- Process each row in turn -->
<xsl:template match="row" mode="newtbl">
  <xsl:param name="rownum"/>
  <xsl:param name="rows"/>
  <xsl:param name="colspec"/>
  <xsl:param name="spanspec"/>
  <xsl:param name="frame"/>
  <xsl:param name="oldentries"/>
  
  <!-- Build the entry node-set -->
  <xsl:variable name="entries">
    <xsl:choose>
      <xsl:when test="entry[1]">
        <xsl:apply-templates mode="newtbl.buildentries" select="entry[1]">
          <xsl:with-param name="colnum" select="1"/>
          <xsl:with-param name="rownum" select="$rownum"/>
          <xsl:with-param name="colspec" select="$colspec"/>
          <xsl:with-param name="spanspec" select="$spanspec"/>
          <xsl:with-param name="frame" select="$frame"/>
          <xsl:with-param name="entries" select="exsl:node-set($oldentries)"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="exsl:node-set($oldentries)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- Now output each entry -->
  <xsl:variable name="context" select="local-name(..)"/>
  <xsl:apply-templates select="exsl:node-set($entries)" mode="newtbl">
    <xsl:with-param name="colspec" select="$colspec"/>
    <xsl:with-param name="frame" select="$frame"/>
    <xsl:with-param name="context" select="$context"/>
    <xsl:with-param name="rownum" select="$rownum"/>
    <xsl:with-param name="valign" select="@valign"/>
  </xsl:apply-templates>
  
  <!-- End this row -->
  <xsl:text>\tabularnewline&#10;</xsl:text>
  
  <!-- Store any rowsep for this row -->
  <xsl:variable name="thisrowsep" select="@rowsep"/>
  
  <!-- Now process rowseps -->
  <xsl:for-each select="exsl:node-set($entries)/*">
    <!-- Only do rowsep for this col if it's not spanning this row and -->
    <!-- not the last row -->
    <xsl:if test="@rowend = $rownum and @rowend != $rows">
      <xsl:variable name="dorowsep">
        <xsl:choose>
          <!-- Entry rowsep override -->
          <xsl:when test="@rowsep">
            <xsl:value-of select="@rowsep"/>
          </xsl:when>
          <!-- Row rowsep override -->
          <xsl:when test="$thisrowsep">
            <xsl:value-of select="$thisrowsep"/>
          </xsl:when>
          <!-- Else use the default for this column -->
          <xsl:otherwise>
            <xsl:value-of select="@defrowsep"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="$dorowsep = 1">
        <xsl:text>\cline{</xsl:text>
        <xsl:value-of select="@colstart"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@colend"/>
        <xsl:text>}</xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:for-each>

  <xsl:choose>
    <xsl:when test="following-sibling::row[1]">
      <xsl:apply-templates mode="newtbl" select="following-sibling::row[1]">
        <xsl:with-param name="rownum" select="$rownum + 1"/>
        <xsl:with-param name="rows" select="$rows"/>
        <xsl:with-param name="colspec" select="$colspec"/>
        <xsl:with-param name="spanspec" select="$spanspec"/>
        <xsl:with-param name="frame" select="$frame"/>
        <xsl:with-param name="oldentries" select="$entries"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:when test="local-name(..) = 'tfoot'">
    </xsl:when>
    <xsl:otherwise>
      <!-- Ask to table to end the head -->
      <xsl:if test="local-name(..) = 'thead'">
        <xsl:apply-templates select="ancestor::table|ancestor::informaltable"
                             mode="newtbl.endhead"/>
      </xsl:if>

      <xsl:apply-templates mode="newtbl" 
                           select="(../following-sibling::tbody/row)[1]">
        <xsl:with-param name="rownum" select="$rownum + 1"/>
        <xsl:with-param name="rows" select="$rows"/>
        <xsl:with-param name="colspec" select="$colspec"/>
        <xsl:with-param name="spanspec" select="$spanspec"/>
        <xsl:with-param name="frame" select="$frame"/>
        <xsl:with-param name="oldentries" select="$entries"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>



<!-- Calculate column width between two columns -->
<xsl:template name="tbl.colwidth" mode="newtbl">
  <xsl:param name="col"/>
  <xsl:param name="colend"/>
  <xsl:param name="colspec"/>
  
  <xsl:value-of select="$colspec/colspec[@colnum=$col]/@colwidth"/>
  
  <xsl:if test="$col &lt; $colend">
    <xsl:text>+2\tabcolsep+</xsl:text>
    <xsl:call-template name="tbl.colwidth" mode="newtbl">
      <xsl:with-param name="col" select="$col + 1"/>
      <xsl:with-param name="colend" select="$colend"/>
      <xsl:with-param name="colspec" select="$colspec"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>



<!-- Generate a latex column specifier, possibly surrounded by '|' -->
<xsl:template name="tbl.colfmt" mode="newtbl">
  <xsl:param name="colstart"/>
  <xsl:param name="colend"/>
  <xsl:param name="frame"/>
  <xsl:param name="colsep"/>
  <xsl:param name="colspec"/>
  <xsl:param name="valign"/>
  
  <xsl:variable name="cols" select="count($colspec/*)"/>
  
  <!-- Need a colsep to the left? - only if first column and frame says so -->
  <xsl:if test="$colstart = 1 and ($frame = 'all' or $frame = 'sides')">
    <xsl:text>|</xsl:text>
  </xsl:if>
  
  <!-- Get the column width -->
  <xsl:variable name="width">
    <xsl:call-template name="tbl.colwidth" mode="newtbl">
      <xsl:with-param name="col" select="$colstart"/>
      <xsl:with-param name="colend" select="$colend"/>
      <xsl:with-param name="colspec" select="$colspec"/>
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:choose>
    <xsl:when test="$valign = 'top'">
      <xsl:text>p</xsl:text>
    </xsl:when>
    <xsl:when test="$valign = 'bottom'">
      <xsl:text>b</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>m</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
  
  <xsl:text>{</xsl:text>
  <xsl:value-of select="$width"/>
  <xsl:text>}</xsl:text>
  
  <!-- Need a colsep to the right? - only if last column and frame says -->
  <!-- so, or we are not the last column and colsep says so  -->
  
  <xsl:if test="($colend = $cols and ($frame = 'all' or $frame = 'sides')) or 
                ($colend != $cols and $colsep = 1)">
    <xsl:text>|</xsl:text>
  </xsl:if>
</xsl:template>



<!-- The main starting point of the table handling -->
<xsl:template match="tgroup" mode="newtbl">
  <xsl:param name="tabletype">tabular</xsl:param>
  <xsl:text>
\begingroup%
  </xsl:text>
  
  <!-- Get the number of columns -->
  <xsl:variable name="cols">
    <xsl:choose>
      <xsl:when test="@cols">
        <xsl:value-of select="@cols"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="count(tbody/row[1]/entry)"/>
        <xsl:message>Warning: table's tgroup lacks cols attribute. 
        Assuming <xsl:value-of select="count(tbody/row[1]/entry)"/>.
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- Get the number of rows -->
  <xsl:variable name="rows" select="count(*/row)"/>
  
  <xsl:if test="$rows = 0">
    <xsl:message>Warning: 0 rows</xsl:message>
  </xsl:if>

  <!-- Find the table width -->
  <xsl:variable name="width">
    <xsl:choose>
      <xsl:when test="../@width">
        <xsl:value-of select="../@width"/>
      </xsl:when>
      <xsl:otherwise>\linewidth-2\tabcolsep</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- Get default align -->
  <xsl:variable name="align" 
                select="@align|parent::node()[not(*/@align)]/@align"/>
  
  <!-- Get default colsep -->
  <xsl:variable name="colsep" 
                select="@colsep|parent::node()[not(*/@colsep)]/@colsep"/>
  
  <!-- Get default rowsep -->
  <xsl:variable name="rowsep" 
                select="@rowsep|parent::node()[not(*/@rowsep)]/@rowsep"/>
  
  <!-- Now the frame style -->
  <xsl:variable name="frame">
    <xsl:choose>
      <xsl:when test="../@frame">
        <xsl:value-of select="../@frame"/>
      </xsl:when>
      <xsl:otherwise>all</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- Build up a complete colspec for each column -->
  <xsl:variable name="colspec">
    <xsl:call-template name="tbl.colspec" mode="newtbl">
      <xsl:with-param name="cols" select="$cols"/>
      <xsl:with-param name="rowsep">
        <xsl:choose>
          <xsl:when test="$rowsep"><xsl:value-of select="$rowsep"/>
          </xsl:when>
          <xsl:when test="$newtbl.default.rowsep">
            <xsl:value-of select="$newtbl.default.rowsep"/>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="colsep">
        <xsl:choose>
          <xsl:when test="$colsep"><xsl:value-of select="$colsep"/>
          </xsl:when>
          <xsl:when test="$newtbl.default.colsep">
            <xsl:value-of select="$newtbl.default.colsep"/>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="align">
        <xsl:choose>
          <xsl:when test="$align"><xsl:value-of select="$align"/>
          </xsl:when>
          <xsl:otherwise>left</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  
  <!-- Get all the spanspecs as an RTF -->
  <xsl:variable name="spanspec" select="spanspec"/>
  
  <!-- Now get latex to calculate the 'spare' width of the table -->
  <!-- (Table width - widths of all specified columns - gaps between columns) -->
  <xsl:text>\setlength{\newtblsparewidth}{</xsl:text>
  <xsl:value-of select="$width"/>
  <xsl:for-each select="exsl:node-set($colspec)/*">
    <xsl:if test="@fixedwidth">
      <xsl:text>-</xsl:text>
      <xsl:value-of select="translate(@fixedwidth,'+','-')"/>
    </xsl:if>
    <xsl:text>-2\tabcolsep</xsl:text>
  </xsl:for-each>
  <xsl:text>}%&#10;</xsl:text>
  
  <!-- Now get latex to calculate widths of cols with starred colwidths -->
  
  <xsl:variable name="numunknown" 
                select="sum(exsl:node-set($colspec)/colspec/@star)"/>
  <!-- If we have at least one such col, then work out how wide it should -->
  <!-- be -->
  <xsl:if test="$numunknown &gt; 0">
    <xsl:text>\setlength{\newtblstarfactor}{\newtblsparewidth / \real{</xsl:text>
    <xsl:value-of select="$numunknown"/>
    <xsl:text>}}%&#10;</xsl:text>
  </xsl:if>
  
  <!-- Start the table declaration -->
  <xsl:text>\begin{</xsl:text>
  <xsl:value-of select="$tabletype"/>
  <xsl:text>}{</xsl:text>
  
  <!-- The initial column definition -->
  <xsl:for-each select="exsl:node-set($colspec)/*">
    <xsl:text>l</xsl:text>
  </xsl:for-each>
  <xsl:text>}</xsl:text>
  
  <!-- Need a top line? -->
  <xsl:if test="$frame = 'all' or $frame = 'top' or $frame = 'topbot'">
    <xsl:text>\hline</xsl:text>
  </xsl:if>
  <xsl:text>&#10;</xsl:text>

  <!-- Go through each row, starting with the header -->
  <xsl:apply-templates mode="newtbl" select="((thead|tbody)/row)[1]">
    <xsl:with-param name="rownum" select="1"/>
    <xsl:with-param name="rows" select="$rows"/>
    <xsl:with-param name="frame" select="$frame"/>
    <xsl:with-param name="colspec" select="exsl:node-set($colspec)"/>
    <xsl:with-param name="spanspec" select="exsl:node-set($spanspec)"/>
  </xsl:apply-templates>

  <!-- Go through each footer row -->
  <xsl:apply-templates mode="newtbl" select="tfoot/row[1]">
    <xsl:with-param name="rownum" select="count(thead/row|tbody/row)+1"/>
    <xsl:with-param name="rows" select="$rows"/>
    <xsl:with-param name="frame" select="$frame"/>
    <xsl:with-param name="colspec" select="exsl:node-set($colspec)"/>
    <xsl:with-param name="spanspec" select="exsl:node-set($spanspec)"/>
  </xsl:apply-templates>

  <!-- Need a bottom line? -->
  <xsl:if test="$frame = 'all' or $frame = 'bottom' or $frame = 'topbot'">
    <xsl:text>\hline</xsl:text>
  </xsl:if>
  <xsl:text>&#10;</xsl:text>
  
  <xsl:text>\end{</xsl:text>
  <xsl:value-of select="$tabletype"/>
  <xsl:text>}\endgroup%&#10;</xsl:text>
</xsl:template>

</xsl:stylesheet>
