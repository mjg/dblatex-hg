<?xml version='1.0'?>
<!--############################################################################# 
 |	$Id$		
 |- #############################################################################
 |	$Author$												
 |														
 |   PURPOSE: 
 | 	This is the "parent" stylesheet. The used "modules" are included here.
 |	output encoding text in ISO-8859-1 indented.
 + ############################################################################## -->

<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
	exclude-result-prefixes="doc" version='1.0'>
 
<xsl:output method="text" encoding="ISO-8859-1" indent="yes"/>

<xsl:include href="../common/l10n.xsl"/>
<xsl:include href="../common/common.xsl"/>

<xsl:include href="VERSION.xml"/>
<xsl:include href="vars.mod.xsl"/>
<xsl:include href="latex.mapping.xsl"/>
<xsl:include href="preamble.mod.xsl"/>
<xsl:include href="font.mod.xsl"/>
<xsl:include href="labelid.mod.xsl"/>

<xsl:include href="book.mod.xsl"/>
<xsl:include href="part.mod.xsl"/>
<xsl:include href="article.mod.xsl"/>

<xsl:include href="dedication.mod.xsl"/>
<xsl:include href="preface.mod.xsl"/>
<xsl:include href="toc_lot.mod.xsl"/>
<xsl:include href="chapter.mod.xsl"/>
<xsl:include href="appendix.mod.xsl"/>
<xsl:include href="sections.mod.xsl"/>
<xsl:include href="bridgehead.mod.xsl"/>

<xsl:include href="abstract.mod.xsl"/>
<xsl:include href="biblio.mod.xsl"/>
<xsl:include href="revision.mod.xsl"/>

<xsl:include href="admonition.mod.xsl"/>
<xsl:include href="verbatim.mod.xsl"/>
<xsl:include href="email.mod.xsl"/>
<xsl:include href="sgmltag.mod.xsl"/>
<xsl:include href="citation.mod.xsl"/>
<xsl:include href="qandaset.mod.xsl"/>
<xsl:include href="procedure.mod.xsl"/>
<xsl:include href="lists.mod.xsl"/>
<xsl:include href="callout.mod.xsl"/>


<xsl:include href="figure.mod.xsl"/>
<xsl:include href="graphic.mod.xsl"/>
<xsl:include href="mediaobject.mod.xsl"/>

<xsl:include href="index.mod.xsl"/>


<xsl:include href="xref.mod.xsl"/>
<xsl:include href="formal.mod.xsl"/>
<xsl:include href="example.mod.xsl"/>
<xsl:include href="table.mod.xsl"/>
<xsl:include href="inline.mod.xsl"/>
<xsl:include href="programlisting.mod.xsl"/>
<xsl:include href="authorgroup.mod.xsl"/>
<xsl:include href="html.mod.xsl"/>
<xsl:include href="dingbat.mod.xsl"/>
<xsl:include href="info.mod.xsl"/>
<xsl:include href="keywords.mod.xsl"/>
<xsl:include href="refentry.mod.xsl"/>
<xsl:include href="component.mod.xsl"/>
<xsl:include href="glossary.mod.xsl"/>
<xsl:include href="block.mod.xsl"/>


<xsl:include href="synop-oop.mod.xsl"/>
<xsl:include href="synop-struct.mod.xsl"/>

<xsl:include href="pi.mod.xsl"/>

<xsl:include href="footnote.mod.xsl"/>

<xsl:include href="texmath.mod.xsl"/>
<xsl:include href="mathelem.mod.xsl"/>

<xsl:include href="para.mod.xsl"/>
<xsl:include href="msgset.mod.xsl"/>
<xsl:include href="../errors.xsl"/>
<xsl:include href="normalize-scape.mod.xsl"/>

</xsl:stylesheet>
