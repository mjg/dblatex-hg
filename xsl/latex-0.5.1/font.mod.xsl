<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
	exclude-result-prefixes="doc" version='1.0'>

<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->

 
<doc:param name="latex.document.font" xmlns="">
	<refpurpose> Document Font  </refpurpose>
	<refdescription>
	Possible values: default, times, palatcm, charter, helvet, palatino, avant, newcent, bookman
	</refdescription>
</doc:param>
<xsl:param name="latex.document.font">palatino</xsl:param>

<!-- 
If you want to change explicitly to a certain font, use the command \fontfamily{XYZ}\selectfont whereby XYZ can be set to: pag for Adobe AvantGarde, pbk for Adobe Bookman, pcr for Adobe Courier, phv for Adobe Helvetica, pnc for Adobe NewCenturySchoolbook, ppl for Adobe Palatino, ptm for Adobe Times Roman, pzc for Adobe ZapfChancery 
-->

</xsl:stylesheet>
