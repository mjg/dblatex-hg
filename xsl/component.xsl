<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template match="preface|colophon|dedication">
  <xsl:call-template name="element.and.label"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="dedication/title"></xsl:template>
<xsl:template match="dedication/subtitle"></xsl:template>
<xsl:template match="dedication/titleabbrev"></xsl:template>
<xsl:template match="colophon/title"></xsl:template>
<xsl:template match="preface/title"></xsl:template>
<xsl:template match="preface/titleabbrev"></xsl:template>
<xsl:template match="preface/subtitle"></xsl:template>
<xsl:template match="preface/docinfo|prefaceinfo"></xsl:template>

<!-- preface sect{1-5} mapped like sections -->

<xsl:template match="preface//sect1|
                     preface//sect2|
                     preface//sect3|
                     preface//sect4|
                     preface//sect5">
  <xsl:call-template name="map.sect.level">
    <xsl:with-param name="name" select="local-name(.)"/>
  </xsl:call-template>
  <xsl:call-template name="title.and.label"/>
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>
