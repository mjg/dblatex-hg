<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
	exclude-result-prefixes="doc" 
	version='1.0'>

<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->

<doc:reference xmlns="">
	<referenceinfo>
	<releaseinfo role="meta">
		$Id$
	</releaseinfo>
	<author>
		<surname>Casellas</surname>
		<firstname>Ramon</firstname>
	</author>
	<copyright><year>2000</year>
		<holder>Ramon Casellas</holder>
	</copyright>
	</referenceinfo>
	
	<title>Verbatim Templates</title>

	<partintro>
		<section><title>Introduction</title>

		<para>This is technical reference documentation for the DocBook XSL
		Stylesheets; it documents (some of) the parameters, templates, and
		other elements of the stylesheets.</para>

		<para>This reference describes the templates and parameters relevant
		to formatting EBNF markup.</para>

		<para>This is not intended to be <quote>user</quote> documentation.
		It is provided for developers writing customization layers for the
		stylesheets, and for anyone who's interested in <quote>how it
		works</quote>.</para>
		</section>
	</partintro>
</doc:reference>


<xsl:template match="screen|literallayout[@class='monospaced']">
<xsl:text>&#10;\begin{verbatim}&#10;</xsl:text>
<xsl:apply-templates mode="latex.verbatim"/>
<xsl:text>&#10;\end{verbatim}&#10;</xsl:text>
</xsl:template>


<doc:param name="literal template" xmlns="">
<refpurpose>Template for <sgmltag>literal</sgmltag></refpurpose>
<refdescription>
Template for literal template
</refdescription>
</doc:param>
<xsl:template match="literal">
<xsl:text>{\verb </xsl:text><xsl:apply-templates mode="latex.verbatim"/><xsl:text>}</xsl:text>
</xsl:template>



<xsl:template match="literallayout">
<xsl:text>&#10;\begin{verbatim}&#10;</xsl:text>
<xsl:apply-templates mode="latex.verbatim"/>
<xsl:text>&#10;\end{verbatim}&#10;</xsl:text>
</xsl:template>

<xsl:template match="address">
<xsl:text>&#10;\begin{verbatim}&#10;</xsl:text>
<xsl:apply-templates mode="latex.verbatim"/>
<xsl:text>&#10;\end{verbatim}&#10;</xsl:text>
</xsl:template>

</xsl:stylesheet>
