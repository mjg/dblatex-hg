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

<!-- DOCUMENTATION -->
<doc:template name="abstract" xmlns="">
<refpurpose> Abstract XSL template.  </refpurpose>
<refdescription>
<para>Outputs <literal>\begin{abstract}</literal>,
applies templates and outputs <literal>\end{abstract}</literal>. </para>
<formalpara><title>Remarks and Bugs</title>
<itemizedlist>
	<listitem><para> The title of the abstract is lost.</para></listitem>
	<listitem><para> The template for abstract/title is defined EMPTY.</para></listitem>
</itemizedlist>
</formalpara>
<formalpara><title>Default Behaviour</title>
<screen>
% --------------------------------------------
% Abstract 
% --------------------------------------------
\begin{abstract}
	... [ Applied templates here ]
\end{abstract}
</screen>
</formalpara>
</refdescription>
</doc:template>

<!-- TEMPLATE -->
<xsl:template match="abstract">
<xsl:text>&#10;</xsl:text>
<xsl:text>% --------------------------------------------&#10;</xsl:text>
<xsl:text>% Abstract &#10;</xsl:text>
<xsl:text>% --------------------------------------------&#10;</xsl:text>
<xsl:text>\begin{abstract}&#10;</xsl:text>
	<xsl:apply-templates/>
<xsl:text>&#10;</xsl:text>
<xsl:text>\end{abstract}&#10;</xsl:text>
</xsl:template>

<xsl:template match="abstract/title"/>

</xsl:stylesheet>
