# -*- perl -*-
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl XML-LibXML-LazyBuilder.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 10;
BEGIN { use_ok('XML::LibXML::LazyBuilder') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use XML::LibXML::LazyBuilder qw/:all/;

{
    my $e = E "hoge";
    isa_ok ($e, 'CODE');
    my $d = DOM $e;
    isa_ok ($d, 'XML::LibXML::Document');

    is ($d->firstChild->tagName, "hoge", "tag name");
}

{
    my $e = E hoge => {at1 => "val1", at2 => "val2"};
    my $d = DOM $e;
    is ($d->firstChild->getAttribute ("at1"), "val1", "attribute");
    is ($d->firstChild->getAttribute ("at2"), "val2", "attribute");

    # cloning
    my $d2 = DOM $e;
    $d2->firstChild->setAttribute ("at1", "val1'");
    is ($d->firstChild->getAttribute ("at1"), "val1", "original");
    is ($d2->firstChild->getAttribute ("at1"), "val1'", "clone");
}

{
    my $d = DOM (E (hoge => {}, "content"));
    is ($d->firstChild->textContent, "content", "text content");
}

{
    my $d = DOM (E A => {}, ((E B => {}, ((E "C"),
					  (E "D"))),
			     (E E => {}, ((E "F"),
					  (E "G")))));
    is ($d->firstChild->firstChild->nextSibling->firstChild->nextSibling->tagName,
	"G", "child nodes");
}
