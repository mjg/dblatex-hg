<?xml version='1.0'?>
<!--############################################################################# 
 |	$Id$		
 |- #############################################################################
 |	$Author$
 |
 |   PURPOSE: User and stylesheets XSL variables 
 + ############################################################################## -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
	exclude-result-prefixes="doc" version='1.0'>


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
	
	<title>XSL Variables and Parameters</title>

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


<!--############################################################################# 
 |  COMMON VARIABLES
 |- #############################################################################
 |	$Author$
 |
 + ############################################################################## -->
<xsl:variable name="default-classsynopsis-language">java</xsl:variable>

<xsl:variable name="author.othername.in.middle" select="1"/>
<xsl:variable name="refentry.xref.manvolnum" select="1"/>
<xsl:variable name="funcsynopsis.style">kr</xsl:variable>
<xsl:variable name="funcsynopsis.decoration" select="1"/>
<xsl:variable name="function.parens">0</xsl:variable>
<xsl:variable name="refentry.generate.name" select="1"/>
<xsl:variable name="show.comments" select="1"/>

<xsl:variable name="section.autolabel" select="1"/>
<xsl:variable name="section.label.includes.component.label" select="0"/>
<xsl:variable name="chapter.autolabel" select="1"/>
<xsl:variable name="preface.autolabel" select="0"/>
<xsl:variable name="part.autolabel" select="1"/>
<xsl:variable name="qandadiv.autolabel" select="1"/>
<xsl:variable name="qanda.inherit.numeration" select="1"/>
<xsl:variable name="qanda.defaultlabel">number</xsl:variable>
<xsl:variable name="biblioentry.item.separator">, </xsl:variable>
<xsl:variable name="toc.section.depth">4</xsl:variable>
<xsl:variable name="section.depth">4</xsl:variable>
<xsl:variable name="link.mailto.url"></xsl:variable>
<xsl:variable name="graphic.default.extension"></xsl:variable>
<xsl:variable name="toc.list.type">dl</xsl:variable>
<xsl:variable name="check.idref">1</xsl:variable>



<!--############################################################################# 
 | 	LaTeX VARIABLES
 |- #############################################################################
 |	$Author$
 |
 |   PURPOSE: User and stylesheets XSL variables 
 + ############################################################################## -->
 
<xsl:variable name="latex.override"></xsl:variable>
<xsl:variable name="latex.figure.position">[tbp]</xsl:variable>

<doc:param name="latex.titlepage.file" xmlns="">
	<refpurpose> DB2LaTeX allows using a (externally generated) cover page.  </refpurpose>
	<refdescription>
		<para>
		DB2LaTeX allows using a (externally generated) cover page. The stylesheets
		check for the valuee of the variable <literal>latex.titlepage.file</literal>
		If given, the generated LaTeX code includes an \input{filename}. Otherwise
		it uses the \maketitle command. </para>
		<warning><para>
		Bear in mind that using an external cover page
		breaks the "encapsulation" of docbook. Further revisions of these stylesheets
		will add chunking support, and the automation of the cover file generation.
		</para></warning>
	</refdescription>
</doc:param>
<xsl:variable name="latex.titlepage.file">title</xsl:variable>


<doc:param name="latex.admonition.path" xmlns="">
	<refpurpose> DB2LaTeX graphics admonitions  </refpurpose>
	<refdescription>
		<para>
		</para>
	</refdescription>
</doc:param>
<xsl:variable name="latex.admonition.path">figures</xsl:variable>





<doc:param name="latex.biblio.output" xmlns="">
	<refpurpose> The DB2LaTeX generated bibliography (bibitems) may either
	include all biblioentries found in the document, or only de ones explicitly
	cited with <sgmltag>citation</sgmltag>.  </refpurpose>
	<refdescription>
		<para>Two values are possible either: all or cited.</para>
	</refdescription>
</doc:param>
<xsl:variable name="latex.biblio.output">all</xsl:variable>




<doc:param name="latex.bibfiles" xmlns="">
	<refpurpose>
	Controlling the output of the \bibliography{.bib}.
	</refpurpose>
	<refdescription>
		<para>The value of this parameter is output.</para>
	</refdescription>
</doc:param>
<xsl:variable name="latex.bibfiles">''</xsl:variable>


<doc:param name="latex.bibwidelabel" xmlns="">
	<refpurpose> The DB2LaTeX generated bibliography (bibitems) may either
	include all biblioentries found in the document, or only de ones explicitly
	cited with <sgmltag>citation</sgmltag>.  </refpurpose>
	<refdescription>
		<para>The environment bibliography accepts a parameter that indicates
		the widest label, which is used to correctly format the bibliography
		output. The value of this parameter is output inside the
		<literal>\begin{thebibliography[]}</literal> LaTeX command.</para>
	</refdescription>
</doc:param>
<xsl:variable name="latex.bibwidelabel">WIDELABEL</xsl:variable>


<xsl:variable name="latex.use.babel">1</xsl:variable>
<xsl:variable name="latex.use.isolatin1">1</xsl:variable>
<xsl:variable name="latex.use.hyperref">1</xsl:variable>
<xsl:variable name="latex.use.fancyvrb">1</xsl:variable>
<xsl:variable name="latex.use.fancybox">1</xsl:variable>
<xsl:variable name="latex.use.fancyhdr">1</xsl:variable>
<xsl:variable name="latex.use.subfigure">1</xsl:variable>
<xsl:variable name="latex.use.rotating">1</xsl:variable>
<xsl:variable name="latex.use.makeidx">1</xsl:variable>

<xsl:variable name="latex.fancyhdr.lh">Left Header</xsl:variable>
<xsl:variable name="latex.fancyhdr.ch">Center Header</xsl:variable>
<xsl:variable name="latex.fancyhdr.rh">Right Header</xsl:variable>
<xsl:variable name="latex.fancyhdr.lf">Left Footer</xsl:variable>
<xsl:variable name="latex.fancyhdr.cf">Center Footer</xsl:variable>
<xsl:variable name="latex.fancyhdr.rf">Right Footer</xsl:variable>

<doc:param name="latex.pdf.support" xmlns="">
	<refpurpose> Controls the output of LaTeX commands to support the generation 
	of PDF files.</refpurpose>
	<refdescription>
		<para>If this parameter is set to 1, the stylesheets generate code to 
		detect if it is either <literal>latex</literal> or <literal>pdflatex</literal>
		the shell command that is being used to compile the LaTeX text file. Some
		packages (<literal>graphicx</literal>, <literal>hyperref</literal>) are used
		with the right parameters. Finally, the graphic extensions declared, to use in
		<literal>\includegraphics</literal> commands depends also on which command is
		being used. If this parameter is set to zero, such code is not generated (which 
		does not mean that the file cannot compile with pdflatex, but some strange issues 
		may appear). <emphasis>DEFAULT: 1</emphasis> Only more code is generated. 
		</para>
	</refdescription>
</doc:param>
<xsl:variable name="latex.pdf.support">1</xsl:variable>




<doc:param name="latex.math.support" xmlns="">
	<refpurpose> Controls the output of LaTeX packages and commands to support 
	documents with math commands and environments..</refpurpose>
	<refdescription>
		<para>If this parameter is set to 1, the stylesheets generate code to 
		<emphasis>DEFAULT: 1</emphasis> Only more code is generated. 
		</para>
	</refdescription>
</doc:param>
<xsl:variable name="latex.math.support">1</xsl:variable>



<doc:param name="latex.output.revhistory" xmlns="">
	<refpurpose> Controls  if the revision history table is generated as the first document 
	table.
	</refpurpose>
	<refdescription>
		<para>If this parameter is set to 1, the stylesheets generate code to 
		<emphasis>DEFAULT: 1</emphasis> Only more code is generated. 
		</para>
	</refdescription>
</doc:param>
<xsl:variable name="latex.output.revhistory">1</xsl:variable>




<doc:param name="latex.book.varsets" xmlns="">
	<refpurpose> 
	All purpose commands to change text width, height, counters, etc.
	</refpurpose>
	<refdescription>
	</refdescription>
</doc:param>
<xsl:variable name="latex.book.varsets">
<xsl:text>\setlength{\textwidth}{16.5cm}&#10;</xsl:text>
<xsl:text>\setlength{\textheight}{22.2cm}&#10;</xsl:text>
<xsl:text>\setlength{\hoffset}{-2cm}&#10;</xsl:text>
<xsl:text>\setlength{\voffset}{-.9in}&#10;</xsl:text>
</xsl:variable>

<doc:param name="latex.book.begindocument" xmlns="">
	<refpurpose> 
	Begin document command
	</refpurpose>
	<refdescription>
	</refdescription>
</doc:param>
<xsl:variable name="latex.book.begindocument">
<xsl:text>\begin{document}&#10;</xsl:text>
</xsl:variable>





<doc:param name="latex.book.afterauthor" xmlns="">
	<refpurpose> 
	LaTeX code that is output after the author (e.g. 
	<literal>\makeindex, \makeglossary</literal>
	</refpurpose>
	<refdescription>
	</refdescription>
</doc:param>
<xsl:variable name="latex.book.afterauthor">
<xsl:text>% --------------------------------------------&#10;</xsl:text>
<xsl:text>\makeindex&#10;</xsl:text>
<xsl:text>\makeglossary&#10;</xsl:text>
<xsl:text>% --------------------------------------------&#10;</xsl:text>
</xsl:variable>




<doc:param name="latex.book.end" xmlns="">
	<refpurpose> 
	LaTeX code that is output  at the end of the document
	<literal>\end{document}</literal>
	</refpurpose>
	<refdescription>
	</refdescription>
</doc:param>
<xsl:variable name="latex.book.end">
<xsl:text>% --------------------------------------------&#10;</xsl:text>
<xsl:text>% End of document&#10;</xsl:text>
<xsl:text>% --------------------------------------------&#10;</xsl:text>
<xsl:text>\end{document}&#10;</xsl:text>
</xsl:variable>



<!--############################################################################# 
 | 	XSL VARIABLES FOR ARTICLES	
 |- #############################################################################
 |	$Author$
 |
 + ############################################################################## -->



<doc:param name="latex.article.begindocument" xmlns="">
	<refpurpose> The begin document </refpurpose>
	<refdescription>The value of this variable is output from the article template
	<xref linkend="tmpl:article"/> after the author command. The default value
	(shown below) is just the begin document command. Users of the XSL LaTeX
	stylesheet may override this parameter in order to output what they want.
	</refdescription>
	<refreturn><literal>\begin{document}</literal></refreturn>
</doc:param>
<xsl:variable name="latex.article.begindocument">
<xsl:text>\begin{document}&#10;</xsl:text>
</xsl:variable>


<doc:param name="latex.article.maketitle" xmlns="">
	<refpurpose> Controls what is output after the LaTeX preamble. Basically the <literal>\maketitle</literal>
	</refpurpose>
	<refdescription>
	<para>Default Values</para>
	<screen><![CDATA[
	\setlength{\textwidth}{16.5cm}
	\setlength{\textheight}{22.2cm}
	\setlength{\hoffset}{-2cm}
	\setlength{\voffset}{-.9in}
	\renewcommand\floatpagefraction{.9}
	\renewcommand\topfraction{.9}
	\renewcommand\bottomfraction{.9}
	\renewcommand\textfraction{.1}
	]]></screen>
	</refdescription>
</doc:param>

<xsl:variable name="latex.article.varsets">
<xsl:text>
\setlength{\textwidth}{16.5cm}
\setlength{\textheight}{22.2cm}
\setlength{\hoffset}{-2cm}
\setlength{\voffset}{-.9in}
\renewcommand\floatpagefraction{.9}
\renewcommand\topfraction{.9}
\renewcommand\bottomfraction{.9}
\renewcommand\textfraction{.1}
</xsl:text>
</xsl:variable>




<doc:param name="latex.article.maketitle" xmlns="">
	<refpurpose> Controls what is output after the LaTeX preamble. Basically the <literal>\maketitle</literal>
	</refpurpose>
	<refdescription>
	<para>Default Values</para>
	<screen><![CDATA[
	\maketitle
	]]></screen>
	</refdescription>
</doc:param>
<xsl:variable name="latex.article.maketitle">
<xsl:text>&#10;</xsl:text>
<xsl:text>\maketitle&#10;</xsl:text>
</xsl:variable>


<doc:param name="latex.article.end" xmlns="">
	<refpurpose> Controls what is output at the end of the article. Basically the <literal>\end{document}</literal>
	command, with some markup comments.	</refpurpose>
	<refdescription>
	</refdescription>
</doc:param>
<xsl:variable name="latex.article.end">
<xsl:text>&#10;</xsl:text>
<xsl:text>% --------------------------------------------&#10;</xsl:text>
<xsl:text>% End of document&#10;</xsl:text>
<xsl:text>% --------------------------------------------&#10;</xsl:text>
<xsl:text>\end{document}&#10;</xsl:text>
</xsl:variable>



</xsl:stylesheet>

