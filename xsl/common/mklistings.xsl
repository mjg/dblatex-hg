<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                version='1.0'>

<!-- ********************************************************************
     $Id$
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://docbook.sf.net/release/xsl/current/ for
     copyright and other information.

     ******************************************************************** -->

<xsl:param name="textdata.default.encoding"></xsl:param>
<xsl:param name="current.dir">.</xsl:param>

<!-- * This stylesheet is derivated from the insertfile.xsl stylesheet from
     * the DocBook Project (thanks Michael). It makes a listing tree of the
     * external text files referenced in the document, with each reference
     * replaced with corresponding Xinclude instance.
     * 
     *   <textobject><textdata fileref="foo.txt">
     *   <imagedata format="linespecific" fileref="foo.txt">
     *   <inlinegraphic format="linespecific" fileref="foo.txt">
     *
     * Those become in the result tree:
     *
     *   <listing type="textdata">
     *     <xi:include href="foo.txt" parse="text"/></listing>
     *   <listing type="imagedata">
     *     <xi:include href="foo.txt" parse="text"/></listing>
     *   <listing type="inlinegraphic">
     *     <xi:include href="foo.txt" parse="text"/></listing>
     *
     * It also works as expected with entityref in place of fileref,
     * and copies over the value of the <textdata> encoding attribute (if
     * found). It is basically intended as an alternative to using the
     * DocBook XSLT Java insertfile() extension.
-->

<!-- ==================================================================== -->

<xsl:template name="get.external.filename">
  <xsl:variable name="filename">
  <xsl:choose>
    <xsl:when test="@entityref">
      <xsl:value-of select="unparsed-entity-uri(@entityref)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="@fileref"/>
    </xsl:otherwise>
  </xsl:choose>
  </xsl:variable>
  <xsl:choose>
  <xsl:when test="starts-with($filename, '/') or
                  contains($filename, ':')">
    <!-- it has absolute path or a uri scheme so it is an absolute uri -->
    <xsl:value-of select="$filename"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="$current.dir"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="$filename"/>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ==================================================================== -->
 
<xsl:template match="textdata|
                    imagedata[@format='linespecific']|
                    inlinegraphic[@format='linespecific']" mode="lstid">
 <xsl:number from="/"
             level="any"
             format="1"/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="textobject[child::textdata[@entityref|@fileref]]">
  <xsl:apply-templates select="textdata"/>
</xsl:template>

<xsl:template match="textdata[@entityref|@fileref]">
  <xsl:variable name="filename">
    <xsl:call-template name="get.external.filename"/>
  </xsl:variable>
  <xsl:variable name="encoding">
    <xsl:choose>
      <xsl:when test="@encoding">
        <xsl:value-of select="@encoding"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$textdata.default.encoding"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="lstid">
    <xsl:apply-templates select="." mode="lstid"/>
  </xsl:variable>
  <listing type="textdata" lstid="{$lstid}">
    <xi:include href="{$filename}" parse="text" encoding="{$encoding}"/></listing>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template
    match="inlinemediaobject
           [child::imageobject
           [child::imagedata
           [@format = 'linespecific' and
           (@entityref|@fileref)]]]">
  <xsl:apply-templates select="imageobject/imagedata"/>
</xsl:template>

<xsl:template match="imagedata
                     [@format = 'linespecific' and
                     (@entityref|@fileref)]">
  <xsl:variable name="filename">
    <xsl:call-template name="get.external.filename"/>
  </xsl:variable>
  <xsl:variable name="lstid">
    <xsl:apply-templates select="." mode="lstid"/>
  </xsl:variable>
  <listing type="imagedata"  lstid="{$lstid}">
    <xi:include href="{$filename}" parse="text"
                encoding="{$textdata.default.encoding}"/></listing>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="inlinegraphic
                     [@format = 'linespecific' and
                     (@entityref|@fileref)]">
  <xsl:variable name="filename">
    <xsl:call-template name="get.external.filename"/>
  </xsl:variable>
  <xsl:variable name="lstid">
    <xsl:apply-templates select="." mode="lstid"/>
  </xsl:variable>
  <listing type="inlinegraphic" lstid="{$lstid}">
    <xi:include href="{$filename}" parse="text"
                encoding="{$textdata.default.encoding}"/></listing>
</xsl:template>

<!-- ==================================================================== -->

<!-- browse the tree -->
<xsl:template match="node() | @*">
  <xsl:apply-templates select="@* | node()"/>
</xsl:template>

<xsl:template match="/">
  <listings xmlns:xi="http://www.w3.org/2001/XInclude">
  <xsl:apply-templates/>
  </listings>
</xsl:template>

</xsl:stylesheet>
