<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->


<!-- These templates define the "default behavior" for info
     elements.  Even if you don't process the *info wrappers,
     some of these elements are needed because the elements are
     processed from named templates that are called with modes.
     Since modes aren't sticky, these rules apply. 
     (TODO: clarify this comment) -->


<xsl:template match="corpauthor">
	<xsl:apply-templates/>
</xsl:template>


<xsl:template match="jobtitle">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="orgname">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="orgdiv">
	<xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>
