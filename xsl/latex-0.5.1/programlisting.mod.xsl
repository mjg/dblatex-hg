<?xml version='1.0'?>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
	exclude-result-prefixes="doc" 
	version='1.0'>

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
	
	<title>ProgramListing Templates</title>

	<partintro>
		<section><title>Introduction</title>

		<para>This is technical reference documentation for the DocBook XSL
		Stylesheets; it documents (some of) the parameters, templates, and
		other elements of the stylesheets.</para>
		<para>This reference describes the templates and parameters relevant
		to formatting DocBook Programlisting markup.</para>
		</section>
	</partintro>
</doc:reference>

<doc:template name="programlisting" xmlns="">
	<refpurpose> programlisting XSL template </refpurpose>
	<refdescription>
		<para>Outputs <literal>\begin{verbatim}</literal>,
		applies templates with <literal>latex.programlisting</literal> mode
		and outputs <literal>\end{verbatim}</literal>. </para>
		<formalpara><title>Remarks and Bugs</title>
		<itemizedlist>
		<listitem><para> The template for abstract/title is defined EMPTY.</para></listitem>
		</itemizedlist>
		</formalpara>
	</refdescription>
</doc:template>
<xsl:template match="programlisting">
<xsl:text>&#10;\begin{verbatim}&#10;</xsl:text>
	<xsl:apply-templates mode="latex.programlisting"/>
<xsl:text>&#10;\end{verbatim}&#10;</xsl:text>
</xsl:template>



</xsl:stylesheet>
