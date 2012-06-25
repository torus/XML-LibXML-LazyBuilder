package XML::LibXML::LazyBuilder;

use 5.008000;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use XML::LibXML::LazyBuilder ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	E DOM
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.03';


# Preloaded methods go here.

use XML::LibXML;

sub E ($;$@) {
    my ($name, $attr, @contents) = @_;

    sub {
	my ($dom) = @_;

	my $elem = $dom->createElement ($name);
	if (ref ($attr) eq 'HASH') {
	    while (my ($n, $v) = each %$attr) {
		$elem->setAttribute ($n, $v);
	    }
	}

	for my $child (@contents) {
	    if (ref $child) {
		$elem->appendChild ($child->($dom));
	    } else {
		$elem->appendTextNode ($child);
	    }
	}

	$elem;
    }
}

sub DOM ($;$$) {
    my ($elem, $ver, $enc) = @_;

    my $dom = XML::LibXML::Document->new ($ver || "1.0", $enc || "utf-8");
    $dom->setDocumentElement ($elem->($dom));

    $dom;
}

1;
__END__

=head1 NAME

XML::LibXML::LazyBuilder - easy and lazy way to create XML document for XML::LibXML

=head1 SYNOPSIS

  use XML::LibXML::LazyBuilder;

  {
      package XML::LibXML::LazyBuilder;
      $d = DOM (E A => {at1 => "val1", at2 => "val2"},
                ((E B => {}, ((E "C"),
                              (E D => {}, "Content of D"))),
                 (E E => {}, ((E F => {}, "Content of F"),
                              (E "G")))));
  }

=head1 DESCRIPTION

You can describe XML documents like simple function call instead of
using createElement, appendChild, etc...

=head2 FUNCTIONS

=over 4

=item E

    E "tagname", \%attr, @children

Creats CODEREF that generates C<XML::LibXML::Element> which tag name
is given by first argument.  Rest arguments are list of text content
or child element created by C<E> (so you can nest C<E>).

Since the output of this function is CODEREF, the creation of actual
C<XML::LibXML::Element> object will be delayed until C<DOM> function
is called.

=item DOM

    DOM \&docroot, $var, $enc

Generates C<XML::LibXML::Document> object actually.  First argument is
a CODEREF created by C<E> function.  C<$var> is version number of XML
docuemnt, C<"1.0"> by default.  C<$enc> is encoding, C<"utf-8"> by
default.

=back

=head2 EXPORT

None by default.

=over 4

=item :all

Exports C<E> and C<DOM>.

=back

=head2 EXAMPLES

I recommend to use C<package> statement in a small scope so that you
can use short function name and avoid to pollute global name space.

  my $d;
  {
      package XML::LibXML::LazyBuilder;
      $d = DOM (E A => {at1 => "val1", at2 => "val2"},
                ((E B => {}, ((E "C"),
                              (E D => {}, "Content of D"))),
                 (E E => {}, ((E F => {}, "Content of F"),
                              (E "G")))));
  }

Then, C<< $d->toString >> will generate XML like this:

  <?xml version="1.0" encoding="utf-8"?>
  <A at1="val1" at2="val2"><B><C/><D>Content of D</D></B><E><F>Content of F</F><G/></E></A>

=head1 SEE ALSO

L<XML::LibXML>

=head1 AUTHOR

Toru Hisai, E<lt>toru@torus.jpE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Toru Hisai

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
