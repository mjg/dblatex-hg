<?xml version='1.0'?>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$												
 |														
 |   PURPOSE:
 |	This template matches a book. 
 + ############################################################################## -->

<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
	exclude-result-prefixes="doc" version='1.0'>

<!-- DOCUMENTATION -->
<doc:template id="tmpl:book" name="Book XSL Template" xmlns="">
	<refpurpose>Book XSL Template</refpurpose>
	<refdescription>
		<para> Most DocBook documents are either articles or books, so the book 
		XSL template <xref linkend="tmpl:book"/> is one classical entry point 
		when processign docbook documents.</para>
		
		<formalpara><title>Tasks</title>
		<itemizedlist>
		<listitem><para>Calls <literal>latex.book.end</literal> template.</para></listitem>
		</itemizedlist>
		</formalpara>
		
		<formalpara><title>Remarks and Bugs</title>
		<itemizedlist>
		<listitem><para> EMPTY templates: book/title and book/subtitle</para></listitem>
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
		<para>Outputs the LaTeX Code corresponding to a book.</para>
	</refreturn>
</doc:template>

<!-- XSL TEMPLATE -->
<xsl:template match="book">
<xsl:call-template name="generate.latex.book.preamble"/>
<!-- Output title information -->
<xsl:text>\title{</xsl:text>
	<xsl:choose>
            <xsl:when test="./title">
			<xsl:value-of select="normalize-space(./title)"/>
            </xsl:when>
            <xsl:otherwise>
			<xsl:value-of select="normalize-space(./bookinfo/title)"/>
            </xsl:otherwise>
	</xsl:choose>
<xsl:text>}&#10;</xsl:text>
<!-- Output author information -->
<xsl:text>\author{</xsl:text>
	<xsl:choose>
            <xsl:when test="bookinfo/authorgroup">
      		<xsl:apply-templates select="bookinfo/authorgroup"/>
            </xsl:when>
            <xsl:otherwise>
      		<xsl:apply-templates select="bookinfo/author"/>
            </xsl:otherwise>
	</xsl:choose>
<xsl:text>}&#10;</xsl:text>

<xsl:value-of select="$latex.book.afterauthor"/>
<xsl:text>&#10;\setcounter{tocdepth}{</xsl:text><xsl:value-of select="$toc.section.depth"/><xsl:text>}&#10;</xsl:text>
<xsl:text>&#10;\setcounter{secnumdepth}{</xsl:text><xsl:value-of select="$section.depth"/><xsl:text>}&#10;</xsl:text>
<xsl:value-of select="$latex.book.begindocument"/>
<xsl:text>\long\def\hyper@section@backref#1#2#3{%&#10;</xsl:text>
<xsl:text>\typeout{BACK REF #1 / #2 / #3}%&#10;</xsl:text>
<xsl:text>\hyperlink{#3}{#2}}&#10;</xsl:text>
<xsl:text>&#10;</xsl:text>
<!-- Include external Cover page if specified -->
<xsl:text>&#10;\InputIfFileExists{</xsl:text><xsl:value-of select="$latex.titlepage.file"/>
<xsl:text>}{\typeout{WARNING: Using cover page</xsl:text>
<xsl:value-of select="$latex.titlepage.file"/>
<xsl:text>}}</xsl:text>
<xsl:text>{\maketitle}&#10;</xsl:text>
<xsl:call-template name="label.id"/>
<!-- APPLY TEMPLATES -->
<xsl:apply-templates/>
<xsl:value-of select="$latex.book.end"/>
</xsl:template>


<!-- EMPTY TEMPLATES -->
<xsl:template match="book/title"/>
<xsl:template match="book/subtitle"/>
<xsl:template match="book/bookinfo/title"/>

<!-- Only process revision history by now in bookinfo -->
<xsl:template match="book/bookinfo">
    <xsl:apply-templates select="revhistory" />
</xsl:template>

</xsl:stylesheet>

