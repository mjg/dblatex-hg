#!/usr/bin/env perl
    eval 'exec /usr/bin/env perl -S $0 ${1+"$@"}'
        if $running_under_some_shell;

use File::Basename;

%empty_tags = (
  "area"          => '',
  "audiodata"     => '',
  "beginpage"     => '',
  "co"            => '',
  "colspec"       => '',
  "constraint"    => '',
  "footnoteref"   => '',
  "graphic"       => '',
  "imagedata"     => '',
  "inlinegraphic" => '',
  "xref"          => ''
  );

sub parse_entities
{
  local($l) = $_[0];

  $l =~ s/â/\&acirc;/g;
  $l =~ s/à/\&agrave;/g;
  $l =~ s/é/\&eacute;/g;
  $l =~ s/ê/\&ecirc;/g;
  $l =~ s/è/\&egrave;/g;
  $l =~ s/î/\&icirc;/g;
  $l =~ s/ô/\&ocirc;/g;
  $l =~ s/ù/\&ugrave;/g;
  $l =~ s/û/\&ucirc;/g;
  $l =~ s/ü/\&uuml;/g;
  $l =~ s/ç/\&ccedil;/g;

  return $l;
}

#
# variable globale pour la gestion des tags EMPTY
#
@open_tags=();
$take=0;

sub parse_empty_tags
{
  my @tags = split(/(\<)|(\/?\>)/) ;
  my $i,$take;
  
  for($i=0;$i <= $#tags;$i++) {
    $_=$tags[$i];
    if (/^\</) {
      $take++;
      next;
    } elsif (/^(\/?\w+)/ && $take) {
      #store in the array the tag name
      push @open_tags,$1;
      $take=0;
    } elsif (/\>/) { 
	    if (exists $empty_tags{pop(@open_tags)}) {
        #Here we have an empty tag end, just transform it.
	      $tags[$i] =~ s/\/\>/\>/g;
      }
    }
  }
  return join('',@tags);
}

sub parse_xml
{
  local($xmlfile) = $_[0];
  local($sgmlfile) = $_[1];
  local($noheader) = $_[2];
  my $line = "";
  my $file = "";
  my $SGML = "f$sgmlfile";
  my $XML = "f$xmlfile";

  print "$xmlfile -> $sgmlfile\n";

  if (-f $sgmlfile) {
    print "***Warning: $sgmlfile already exists\n";
    system("mv $sgmlfile $sgmlfile~");
  }

  $sgmldir = dirname($sgmlfile);
  if (not(-d $sgmldir)) {
    print "***Warning: creating the directory $sgmldir\n";
    system("mkdir -p $sgmldir");
  }

  open($XML, "<$xmlfile") || die "Cannot open $xmlfile\n";
  open($SGML, ">$sgmlfile") || die "Cannot open $sgmlfile\n";
  
  while (<$XML>) {
    $line = $_;
    if (/\<\?xml .*\?\>/) {
      #just skip the xml description type
      next;
    } 
    if ($noheader == 0) {
      #Don't print .dtd location for sgml
      $line =~ s/\".*\.dtd\"//g;
      if (/doctype/ || /DOCTYPE/) {
        # Change the file header
        $line =~ s/doctype/DOCTYPE/;
        $line =~ s/DOCTYPE ([a-z]*) .*\"/DOCTYPE $1 $system/;
        
      } elsif (/ENTITY.*\.xml/) {
        
        # Get the included file name
        ($file = $line) =~ s/.*\"(.*)\.xml\".*\n/$1/;
 
        # Output follows the main output path
        $outfile = dirname($sgmlfile) . "/$file";

        # The root file directory *is* the root directory
        $outfile =~ s/\.\.\//dotdot\//g;
 
        # Now the included file is the SGML one
        $line =~ s/(.*)\"(.*)\.xml\"/$1\"$outfile.sgml\"/;
 
        # Relative or absolute path?
        if (not($file =~ /^\//)) {
          $file = dirname($sgmlfile) . "/$file";
        }
 
        # The included files need not header
        parse_xml("$file.xml", "$outfile.sgml", 1);
      
      } elsif (/\]\>/) {
        #End of header
        $noheader++;
      }
      print $SGML $line ;
      next;
    } else {
      # Body of the document
      
      # Case of entities
      # $line = parse_entities($line);

      # Case of empty tags
      $line = parse_empty_tags($line);
 
      print $SGML $line;
    }
  }

  close($SGML);
  close($XML);
}

#
# Script start
#
if (not(@ARGV)) {
  print "$0 input.xml [output.sgml]\n";
  exit 1;
}

$system = " PUBLIC \"-//OASIS//DTD DocBook V4.1.2//EN\"";

$xmlfile = $ARGV[0];
$sgmlfile = basename($xmlfile, '.xml');
$sgmlfile = dirname($xmlfile). "/$sgmlfile.sgml";
shift;

if (@ARGV) {
  $sgmlfile = $ARGV[0];
}

parse_xml($xmlfile, $sgmlfile, 0);

