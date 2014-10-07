#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use DDG::Test::Goodie;

zci answer_type => 'md5';
zci is_cached   => 1;

ddg_goodie_test(
    [qw( DDG::Goodie::MD5)],
    'md5 digest this!' => test_zci(
        '3838c8fb10a114e6d21203359ef147ad',
        structured_answer => {
            input     => ['digest this!'],
            operation => 'MD5 hash',
            result    => '3838c8fb10a114e6d21203359ef147ad'
        }
    ),
    'duckduckgo md5' => test_zci(
        '96898bb8544fa56b03c08cdc09886c6c',
        structured_answer => {
            input     => ['duckduckgo'],
            operation => 'MD5 hash',
            result    => '96898bb8544fa56b03c08cdc09886c6c'
        }
    ),
    'md5sum the sum of a string' => test_zci(
        'a704c8833f9850cd342ead27207ca1a1',
        structured_answer => {
            input     => ['the sum of a string'],
            operation => 'MD5 hash',
            result    => 'a704c8833f9850cd342ead27207ca1a1'
        }
    ),
    'md5 of password' => test_zci(
        '5f4dcc3b5aa765d61d8327deb882cf99',
        structured_answer => {
            input     => ['password'],
            operation => 'MD5 hash',
            result    => '5f4dcc3b5aa765d61d8327deb882cf99'
        }
    ),
    'md5sum of "this"' => test_zci(
        '9e925e9341b490bfd3b4c4ca3b0c1ef2',
        structured_answer => {
            input     => ['this'],
            operation => 'MD5 hash',
            result    => '9e925e9341b490bfd3b4c4ca3b0c1ef2'
        }
    ),
    'md5 of "this' => test_zci(
        '53d3e72f097a74f6d439fa88b91d5a71',
        structured_answer => {
            input     => ['"this'],
            operation => 'MD5 hash',
            result    => '53d3e72f097a74f6d439fa88b91d5a71'
        }
    ),
    'md5 hash' => test_zci(
        '0800fc577294c34e0b28ad2839435945',
        structured_answer => {
            input     => ['hash'],
            operation => 'MD5 hash',
            result    => '0800fc577294c34e0b28ad2839435945'
        }
    ),
    'md5 hash         ' => test_zci(
        '0800fc577294c34e0b28ad2839435945',
        structured_answer => {
            input     => ['hash'],
            operation => 'MD5 hash',
            result    => '0800fc577294c34e0b28ad2839435945'
        }
    ),
    'md5 hash of' => test_zci(
        '8bf8854bebe108183caeb845c7676ae4',
        structured_answer => {
            input     => ['of'],
            operation => 'MD5 hash',
            result    => '8bf8854bebe108183caeb845c7676ae4'
        }
    ),
    'md5 hash of  password ' => test_zci(
        '5f4dcc3b5aa765d61d8327deb882cf99',
        structured_answer => {
            input     => ['password'],
            operation => 'MD5 hash',
            result    => '5f4dcc3b5aa765d61d8327deb882cf99'
        }
    ),
);

done_testing;
