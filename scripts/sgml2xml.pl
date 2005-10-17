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
  "textdata"      => '',
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
$first_empty = 0;

sub parse_empty_tags
{
  local($l) = $_[0];
  my @tags = split('<', $l);
  my $nline = "";
  my $i;

  $nline = $tags[0];
  
  if ($first_empty) {
      if ($nline =~ />/) {
        $nline =~ s/\/>/>/;
        $nline =~ s/>/\/>/;
        $first_empty = 0;
      } else {
        print "not closed yet!\n";
        $first_empty = 1;
      }
  }

  for ($i=1; $i<=$#tags; $i++) {
    $tag = $tags[$i];
    $ntag = "<$tags[$i]";
    chomp $tag;
    $tag =~ s/([^ \/>]*).*/$1/;

    if ($force_empty) {
      $t = $tags[$i];
      print "$t \n";
    }
    
    if (exists $empty_tags{"$tag"}) {
      if ($ntag =~ />/) {
        $ntag =~ s/\/>/>/;
        $ntag =~ s/>/\/>/;
        $first_empty = 0;
      } else {
        $first_empty = 1;
      }
    }
    $nline .= "$ntag";
  }
  return "$nline";
}

sub parse_sgml
{
  local($sgmlfile) = $_[0];
  local($xmlfile) = $_[1];
  local($noheader) = $_[2];
  my $line = "";
  my $file = "";
  my $SGML = "f$sgmlfile";
  my $XML = "f$xmlfile";

  print "$sgmlfile -> $xmlfile\n";

  if (-f $xmlfile) {
    print "***Warning: $xmlfile already exists\n";
    system("mv $xmlfile $xmlfile~");
  }

  $xmldir = dirname($xmlfile);
  if (not(-d $xmldir)) {
    # print "***Warning: creating the directory $xmldir\n";
    system("mkdir -p $xmldir");
  }

  open($SGML, "<$sgmlfile") || die "Cannot open $sgmlfile\n";
  open($XML, ">$xmlfile") || die "Cannot open $xmlfile\n";

  # Print first the XML head
  print $XML "<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>\n";

  while (<$SGML>) {
    $line = $_;
    if ((/doctype/ || /DOCTYPE/) && $noheader == 0) {
      # Change the file header
      $line =~ s/doctype/DOCTYPE/;
      $line =~ s/DOCTYPE ([a-z]*) .*\"/DOCTYPE $1 $system/;
 
      print $XML "\n$line";
 
      $noheader++;
    }
    else {
      # Case of entities
      # $line = parse_entities($line);

      # Case of empty tags
      $line = parse_empty_tags($line);
 
      # Case of included files
      if (/ENTITY.*\.sgml/) {
        # Get the included file name
        ($file = $line) =~ s/.*\"(.*)\.sgml\".*\n/$1/;
 
        # Output follows the main output path
        $outfile = dirname($xmlfile) . "/$file";

        # The root file directory *is* the root directory
        $outfile =~ s/\.\.\//dotdot\//g;
 
        # Now the included file is the XML one
        $line =~ s/(.*)\"(.*)\.sgml\"/$1\"$outfile.xml\"/;
#        $line =~ s/(.*)\"(.*)\.sgml\"/$1\"$file.xml\"/;
 
        # Relative or absolute path?
        if (not($file =~ /^\//)) {
          $file = dirname($sgmlfile) . "/$file";
        }
 
        # The included files need not header
        parse_sgml("$file.sgml", "$outfile.xml", 1);
      }
      print $XML $line;
    }
  }

  close($SGML);
  close($XML);
}

#
# Script start
#
if (not(@ARGV)) {
  print "$0 {dtdfile|-} input.sgml [output.xml]\n";
  exit 1;
}

if ($ARGV[0] eq '-') {
  $dtdurl = "http://www.oasis-open.org/docbook/xml/4.1.2/docbookx.dtd";
  $system = " PUBLIC \"-//OASIS//DTD DocBook XML V4.1.2//EN\"\n    \"$dtdurl\"";
} else {
  $system = " SYSTEM \"file://$ARGV[0]\"";
}
shift;

$sgmlfile = $ARGV[0];
$xmlfile = basename($sgmlfile, '.sgml');
$xmlfile = dirname($sgmlfile). "/$xmlfile.xml";
shift;

if (@ARGV) {
  $xmlfile = $ARGV[0];
}

parse_sgml($sgmlfile, $xmlfile, 0);

