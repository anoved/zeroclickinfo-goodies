#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use DDG::Test::Goodie;

# prove -Ilib t/PaceCalculator.t

zci answer_type => 'pacecalculator';

ddg_goodie_test(

	[
	'DDG::Goodie::PaceCalculator'
	],
	
	'1km 2:30 mile pace' => test_zci('Pace: 4:01/mile'),

);

done_testing;
