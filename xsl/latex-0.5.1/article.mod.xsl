<?xml version='1.0' encoding="iso-8859-1"?>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$												
 |														
 |   PURPOSE: Template for articles.
 |   
 + ############################################################################## -->

<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
	exclude-result-prefixes="doc" version='1.0'>

<!-- DOCUMENTATION -->
<doc:template name="article" xmlns="">
	<refpurpose>Article XSL Template</refpurpose>
	<refdescription>
		<para> Most DocBook documents are either articles or books, so the article
		XSL template <xref linkend="tmpl:article"/> is one classical entry point 
		when processign docbook documents.</para>
		
		<formalpara><title>Tasks</title>
		<itemizedlist>
		<listitem><para>Calls <literal>generate.latex.article.preamble</literal>.</para></listitem>
		<listitem><para>Outputs \title, \author, getting the information from its children.</para></listitem>
		<listitem><para>Calls <literal>latex.article.begindocument</literal>.</para></listitem>
		<listitem><para>Calls <literal>latex.article.maketitle.</literal></para></listitem>
		<listitem><para>Applies templates.</para></listitem>
		<listitem><para>Calls <literal>latex.article.end</literal> template.</para></listitem>
		</itemizedlist>
		</formalpara>
		
		<formalpara><title>Remarks and Bugs</title>
		<itemizedlist>
		<listitem><para> EMPTY templates: article/title and article/subtitle</para></listitem>
		</itemizedlist>
		</formalpara>
	</refdescription>
	<refparam>
		<variablelist>
		<varlistentry>
			<term>colwidth</term>
			<listitem>
			<para>The CALS column width specification.</para>
			</listitem>
		</varlistentry>
		</variablelist>
	</refparam>
	<refreturn>
		<para>Outputs the LaTeX Code corresponding to an article.</para>
	</refreturn>
</doc:template>


<!-- ARTICLE TEMPLATE -->
<xsl:template match="article">
<!-- Output LaTeX preamble -->
<xsl:call-template name="generate.latex.article.preamble"/>
<!-- Get and output article title -->
<xsl:variable name="article.title">
<xsl:choose>
	<xsl:when test="./title"> <xsl:value-of select="./title"/> </xsl:when>
      <xsl:when test="./articleinfo/title"> <xsl:value-of select="./articleinfo/title"/> </xsl:when>
      <xsl:otherwise> <xsl:value-of select="./artheader/title"/> </xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:text>\title{</xsl:text>
<xsl:call-template name="normalize-scape"> 
	<xsl:with-param name="string" select="$article.title"/>
</xsl:call-template>
<xsl:text>}&#10;</xsl:text>
<!-- Display author information --> 
<xsl:text>\author{</xsl:text>
<xsl:choose>
	<xsl:when test="artheader/author">		<xsl:apply-templates select="artheader/author"/>	</xsl:when>
	<xsl:when test="artheader/authorgroup">	<xsl:apply-templates select="artheader/authorgroup"/>	</xsl:when>
      <xsl:when test="articleinfo/author">	<xsl:apply-templates select="articleinfo/author"/>	</xsl:when>
	<xsl:when test="articleinfo/authorgroup">	<xsl:apply-templates select="articleinfo/authorgroup"/></xsl:when>
      <xsl:otherwise><xsl:apply-templates select="author"/></xsl:otherwise>
</xsl:choose>
<xsl:text>}&#10;</xsl:text>
<!-- Display  begindocument command -->
<xsl:value-of select="$latex.article.begindocument"/>
<xsl:value-of select="$latex.article.maketitle"/>
<xsl:apply-templates/>
<xsl:value-of select="$latex.article.end"/>
</xsl:template>



<xsl:template match="article/artheader|article/articleinfo">
    <xsl:apply-templates select="abstract"/>
</xsl:template>

<!-- EMPTY TEMPLATES -->
<xsl:template match="article/title"></xsl:template>
<xsl:template match="article/subtitle"></xsl:template>
</xsl:stylesheet>

