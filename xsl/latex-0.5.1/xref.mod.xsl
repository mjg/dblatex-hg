<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE: Manage XREFs
 + ############################################################################## -->



<xsl:template match="anchor">
<xsl:call-template name="label.id"/>
</xsl:template>


<!-- 
	This template returns 1 if there exists somewhere an xref
    whose linkend is the target's id.
-->	

<xsl:template name="id.is.xrefed">
	<xsl:param name="i" select="1"/>
	<xsl:param name="target" select="."/>
	<xsl:param name="xrefs" select="//xref"/>
	<xsl:choose>
		<xsl:when test="xrefs[i]/@linkend = 'target/@id'">
			<xsl:value-of select="1"/>
		</xsl:when>
		<xsl:when test="i = count(xrefs)">
			<xsl:value-of select="0"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="id.is.xrefed">
				<xsl:with-param name="i" select="i+1"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- called to process an xreflabel...you might use this to make  -->
<!-- xreflabels come out in the right font for different targets, -->
<!-- for example. 								-->
<xsl:template name="xref.xreflabel">
	<xsl:param name="target" select="."/>
	<xsl:value-of select="$target/@xreflabel"/>
</xsl:template>


<xsl:template match="xref">
<xsl:variable name="targets" select="id(@linkend)"/>
<xsl:variable name="target" select="$targets[1]"/>
<xsl:variable name="refelem" select="local-name($target)"/>
<xsl:call-template name="check.id.unique"><xsl:with-param name="linkend" select="@linkend"/></xsl:call-template>
<xsl:choose>
	<xsl:when test="$refelem=''">
      	<xsl:message><xsl:text>XRef to nonexistent id: </xsl:text><xsl:value-of select="@linkend"/></xsl:message>
		<xsl:text>XrefId[???]</xsl:text>
	</xsl:when>

	<!-- If an xreflabel has been specified for the target ... -->
	<xsl:when test="$target/@xreflabel">
	<xsl:if test="$latex.use.hyperref=1">
	<xsl:text>\hyperlink{</xsl:text><xsl:value-of select="$target/@id"/><xsl:text>}</xsl:text>
	</xsl:if>
	<xsl:text>{ [</xsl:text>
	<xsl:call-template name="xref.xreflabel">
		<xsl:with-param name="target" select="$target"/>
	</xsl:call-template>
	<xsl:text>] } </xsl:text>
	</xsl:when>

	<!-- If an xreflabel has not been specified for the target ... -->
	<xsl:otherwise>
        <xsl:choose>
		<xsl:when test="@endterm">
			<xsl:variable name="etargets" select="id(@endterm)"/>
			<xsl:variable name="etarget" select="$etargets[1]"/>
			<xsl:choose>
			<xsl:when test="count($etarget) = 0">
				<xsl:message>
				  <xsl:value-of select="count($etargets)"/>
				  <xsl:text>Endterm points to nonexistent ID: </xsl:text>
				  <xsl:value-of select="@endterm"/>
				</xsl:message>
				<xsl:text>[NONEXISTENT ID]</xsl:text>
			</xsl:when>
			<xsl:otherwise>
			<xsl:if test="$latex.use.hyperref=1">
				<xsl:text> \hyperlink{</xsl:text>
				<xsl:value-of select="$etarget/@id"/>
				<xsl:text>}</xsl:text>
				<xsl:text>{</xsl:text>
				<xsl:apply-templates select="$etarget" mode="xref.text"/>
				<xsl:text>}</xsl:text>
			</xsl:if>
			<xsl:if test="$latex.use.hyperref=0">
				<xsl:apply-templates select="$etarget" mode="xref.text"/>
			</xsl:if>
		      	</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:if test="$latex.use.hyperref=1">
				<xsl:text> \hyperlink{</xsl:text>
				<xsl:value-of select="$target/@id"/>
				<xsl:text>}</xsl:text>
				<xsl:text>{</xsl:text>
				<xsl:apply-templates select="$target" mode="xref-to"/>
				<xsl:text>}</xsl:text>
			</xsl:if>
			<xsl:if test="$latex.use.hyperref=0">
	        	    	<xsl:apply-templates select="$target" mode="xref-to"/>
			</xsl:if>
	        </xsl:otherwise>
	</xsl:choose>
        </xsl:otherwise>
</xsl:choose>
</xsl:template>


<!-- ==================================================================== 
	Let LaTeX manage the numbering.. Otherwise sty files that 
	do specify another numberic (e.g I,II, get messed)
-->

<xsl:template name="number.xref">
<xsl:text> \ref{</xsl:text><xsl:value-of select="@id"/><xsl:text>} </xsl:text>
</xsl:template>

	
<xsl:template name="cross-reference">
<xsl:param name="target" select="."/>
<xsl:param name="refelem" select="local-name($target)"/>
<xsl:param name="xref.text">
	<xsl:call-template name="gentext.xref.text">
	<xsl:with-param name="element.name" select="$refelem"/>
	<xsl:with-param name="default">%g %n</xsl:with-param>
	</xsl:call-template>
</xsl:param>
<xsl:call-template name="subst.xref.text">
	<xsl:with-param name="xref.text" select="$xref.text"/>
	<xsl:with-param name="target" select="$target"/>
</xsl:call-template>
</xsl:template>





<xsl:template match="*" mode="xref-to">
<xsl:param name="target" select="."/>
<xsl:param name="refelem" select="local-name($target)"/>
<xsl:message>
	<xsl:text>[Don't know what gentext to create for xref to: "</xsl:text>
	<xsl:value-of select="$refelem"/>
	<xsl:text>"]</xsl:text>
</xsl:message>
<xsl:text>UNKGENTEXT</xsl:text><xsl:value-of select="$refelem"/>
</xsl:template>

<xsl:template match="figure|example|table|equation" mode="xref-to">
<xsl:param name="target" select="."/>
<xsl:param name="refelem" select="local-name($target)"/>
<xsl:call-template name="cross-reference">
    <xsl:with-param name="target" select="$target"/>
</xsl:call-template>
</xsl:template>


<xsl:template match="book|dedication|preface|part|chapter|appendix" mode="xref-to">
<xsl:param name="target" select="."/>
<xsl:param name="refelem" select="local-name($target)"/>
<xsl:call-template name="cross-reference">
    <xsl:with-param name="target" select="$target"/>
</xsl:call-template>
</xsl:template>

<xsl:template match="cmdsynopsis" mode="xref-to">
<xsl:param name="target" select="."/>
<xsl:param name="refelem" select="local-name($target)"/>
<xsl:variable name="command" select="($target//command)[1]"/>
	<xsl:apply-templates select="$command" mode="xref"/>
</xsl:template>

<xsl:template match="funcsynopsis" mode="xref-to">
<xsl:param name="target" select="."/>
<xsl:param name="refelem" select="local-name($target)"/>
<xsl:variable name="func" select="($target//function)[1]"/>
	<xsl:apply-templates select="$func" mode="xref"/>
</xsl:template>


<xsl:template match="biblioentry" mode="xref-to">
<!-- handles both biblioentry and bibliomixed -->
<xsl:param name="target" select="."/>
<xsl:param name="refelem" select="local-name($target)"/>
<xsl:text>[</xsl:text>
<xsl:choose>
	<xsl:when test="local-name($target/*[1]) = 'abbrev'">
		<xsl:apply-templates select="$target/*[1]"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="@id"/>
	</xsl:otherwise>
</xsl:choose>
<xsl:text>]</xsl:text>
</xsl:template>



<xsl:template match="bibliography|glossary|index" mode="xref-to">
<xsl:param name="target" select="."/>
<xsl:param name="refelem" select="local-name($target)"/>
<xsl:call-template name="cross-reference">
	<xsl:with-param name="target" select="$target"/>
</xsl:call-template>
</xsl:template>


<xsl:template match="section|simplesect
                     |sect1|sect2|sect3|sect4|sect5
                     |refsect1|refsect2|refsect3" mode="xref-to">
<xsl:param name="target" select="."/>
<xsl:param name="refelem" select="local-name($target)"/>
<xsl:call-template name="cross-reference">
	<xsl:with-param name="target" select="$target"/>
</xsl:call-template>
</xsl:template>

<xsl:template match="question|answer" mode="xref-to">
<xsl:param name="target" select="."/>
<xsl:param name="refelem" select="local-name($target)"/>
<xsl:call-template name="cross-reference">
	<xsl:with-param name="target" select="$target"/>
</xsl:call-template>
</xsl:template>

<xsl:template match="reference" mode="xref-to">
<xsl:param name="target" select="."/>
<xsl:param name="refelem" select="local-name($target)"/>
<xsl:call-template name="cross-reference">
	<xsl:with-param name="target" select="$target"/>
</xsl:call-template>
</xsl:template>

<xsl:template match="co" mode="xref-to">
  <xsl:param name="target" select="."/>
  <xsl:param name="refelem" select="local-name($target)"/>
  <xsl:apply-templates select="$target" mode="callout-bug"/>
</xsl:template>

<xsl:template match="co" mode="conumber">
  <xsl:number from="literallayout|programlisting|screen|synopsis"
              level="single"
              format="1"/>
</xsl:template>


<xsl:template match="book" mode="xref-to">
<xsl:param name="target" select="."/>
<xsl:param name="refelem" select="local-name($target)"/>
<xsl:variable name="title">
	<xsl:choose>
		<xsl:when test="$target/title">
			<xsl:apply-templates select="$target/title" mode="xref"/>
		</xsl:when>
		<xsl:otherwise>
        		<xsl:apply-templates select="$target/bookinfo/title" mode="xref"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>
<xsl:text>{\em </xsl:text> <xsl:copy-of select="$title"/> <xsl:text>} </xsl:text>
</xsl:template>


<xsl:template match="command" mode="xref">
  <xsl:call-template name="inline.boldseq"/>
</xsl:template>

<xsl:template match="function" mode="xref">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>



<xsl:template match="link">
<xsl:variable name="targets" select="id(@linkend)"/>
<xsl:variable name="target" select="$targets[1]"/>
<xsl:choose>
	<xsl:when test=".!=''">
	  	<xsl:text>\href{#</xsl:text><xsl:value-of select="@linkend"/> 
		<xsl:text>}{ </xsl:text><xsl:copy-of select="normalize-space(.)"/><xsl:text>} </xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  	<xsl:text>\hyperlink{#</xsl:text><xsl:value-of select="@linkend"/> 
		<xsl:text>}{ </xsl:text><xsl:copy-of select="normalize-space(@endterm)"/><xsl:text> } </xsl:text>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="ulink">
<xsl:text>\href{ \url{</xsl:text>
<!-- Unparsed URL. No char is scaped (The \url command should take care of this) -->
<xsl:value-of select="@url"/> 
<xsl:text>}}</xsl:text>
<xsl:text>{{\tt </xsl:text>
<!-- LaTeX chars are scaped. Each / except the :// is mapped to a /\- -->
<xsl:apply-templates mode="slash.hyphen"/>
<xsl:text>}}</xsl:text>
</xsl:template>

<xsl:template match="olink">
	<xsl:apply-templates/>
</xsl:template>


<xsl:template name="title.xref">
<xsl:param name="target" select="."/>
<xsl:choose>
	<xsl:when test="name($target) = 'figure'
                    or name($target) = 'example'
                    or name($target) = 'equation'
                    or name($target) = 'table'
                    or name($target) = 'dedication'
                    or name($target) = 'preface'
                    or name($target) = 'bibliography'
                    or name($target) = 'glossary'
                    or name($target) = 'index'
                    or name($target) = 'setindex'
                    or name($target) = 'colophon'">
      <!-- xsl:call-template name="gentext.startquote"/ -->
	<xsl:text>"</xsl:text>
      <xsl:apply-templates select="$target" mode="title.content"/>
      <!-- xsl:call-template name="gentext.endquote"/ -->
	<xsl:text>"</xsl:text>
	</xsl:when>
	<xsl:otherwise>
      	<xsl:text>{\em </xsl:text><xsl:apply-templates select="$target" mode="title.content"/><xsl:text> }</xsl:text>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="title" mode="xref">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="command" mode="xref">
<xsl:call-template name="inline.boldseq"/>
</xsl:template>

<xsl:template match="function" mode="xref">
<xsl:call-template name="inline.monoseq"/>
</xsl:template>

</xsl:stylesheet>
