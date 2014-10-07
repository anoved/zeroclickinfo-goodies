package DDG::Goodie::MD5;
# ABSTRACT: Calculate the MD5 digest of a string.

use DDG::Goodie;
use Digest::MD5 qw(md5_base64 md5_hex);
use Encode qw(encode);

zci answer_type => 'md5';
zci is_cached => 1;

primary_example_queries 'md5 digest this!';
secondary_example_queries 'duckduckgo md5',
                          'md5sum the sum of a string';

name 'MD5';
description 'Calculate the MD5 digest of a string.';
code_url 'https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/MD5.pm';
category 'transformations';

triggers startend => 'md5', 'md5sum';

handle remainder => sub {
    my $rem = shift;

    $rem =~ s/^hash\s+(.*\S+)/$1/;    # Remove 'hash' in queries like 'md5 hash this'
    $rem =~ s/^of\s+(.*\S+)/$1/;      # Remove 'of' in queries like 'md5 hash of this'
    $rem =~ s/^"(.*)"$/$1/;           # Remove quotes

    return unless ($rem =~ /^\s*(.*\S+)/);

    my $str = $1;
    # The string is encoded to get the utf8 representation instead of
    # perls internal representation of strings, before it's passed to
    # the md5 subroutine.
    my $md5 = md5_hex(encode "utf8", $str);
    return $md5,
      structured_answer => {
        input     => [$str],
        operation => 'MD5 hash',
        result    => $md5
      };
};

1;
