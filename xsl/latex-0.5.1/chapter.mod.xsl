<?xml version='1.0'?>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->

<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
        exclude-result-prefixes="doc" version='1.0'>


<doc:template name="XSL template for chapter" xmlns="">
	<refpurpose> XSL template for chapter.</refpurpose>
	<refdescription>
		<para> This is the main entry point for a <sgmltag class="start">chapter</sgmltag> subtree.
		This template processes any chapter. Outputs <literal>\chapter{title}</literal>, calls 
		template named element.and.label and apply-templates. Since chapters only apply in books, 
		some assumptions could be done in order to optimize the stylesheet behaviour.</para>
		
		<formalpara><title>Remarks and Bugs</title>
		<itemizedlist>
		<listitem><para> EMPTY templates: chapter/title, chapter/titleabbrev, chapter/subtitle, chapter/docinfo|chapterinfo.</para></listitem>
		</itemizedlist>
		</formalpara>
		
		<formalpara><title>Affected by</title> element.and.label
		</formalpara>
	</refdescription>
</doc:template>

<xsl:template match="chapter">
<xsl:text>&#10;</xsl:text>
<xsl:text>% ----------------------------------------------------------------- 		&#10;</xsl:text>
<xsl:text>% Chapter </xsl:text><xsl:value-of select="normalize-space(title)"/><xsl:text>  &#10;</xsl:text>
<xsl:text>% ----------------------------------------------------------------- 		&#10;</xsl:text>
<xsl:call-template name="element.and.label"/>
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="chapter/title"></xsl:template>
<xsl:template match="chapter/titleabbrev"></xsl:template>
<xsl:template match="chapter/subtitle"></xsl:template>
<xsl:template match="chapter/docinfo|chapterinfo"></xsl:template>


</xsl:stylesheet>
