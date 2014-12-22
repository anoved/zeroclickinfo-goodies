package DDG::Goodie::PaceCalculator;
# ABSTRACT: Calculate running pace.

use DDG::Goodie;

# with 'DDG::GoodieRole::NumberStyler';
# my $number_re = number_style_regex();

triggers end => "pace";

# table of unit expressions to meters
my %unit_distances = (
	qr/met(?:er|re)s?/ => 1,
	qr/(?:km|kilomet(?:er|re)s?)/ => 1000,
	qr/miles?/ => 1609
);

my $unit_dists = join("|", keys(%unit_distances));
my $unit_re = qr/$unit_dists/;

my $time_re = qr/\d+:\d\d(?:\.\d+)?/;
my $pace_re = qr/(?<pacetime>$time_re)\/(?<paceunit>$unit_re)/;
my $count_re = qr/\d+(?:\.\d+)?/;

# table of named distances to meters
my %named_distances = (
	"marathon" => 42195,
	"half marathon" => 21098
);

# assemble re of exact matches for named distance keys
my $named_dists = join("|", map(quotemeta, keys(%named_distances)));
my $distunit_re = qr/(?<count>$count_re) ?(?<unit>$unit_re)/;
my $distance_re = qr/$named_dists|$distunit_re/;

my $resultunit_re = qr/(?:\s+(?<result>$unit_re))?/;

# Returns seconds in HH:MM:SS format.
# hacky, doesn't handle decimal seconds
sub FormatTime {
	my $seconds = shift;
	my $minutes = 0;
	my $hours = 0;
	if ($seconds >= 60) {
		$minutes = int($seconds/60);
		$seconds = $seconds - ($minutes * 60);
	}
	if ($minutes >= 60) {
		$hours = int($minutes/60);
		$minutes = $minutes - ($hours * 60);
	}
	return sprintf('%02d:%02d:%02d', $hours, $minutes, $seconds);
}

# Return meter equivalent of given unit.
sub MetersPerUnit {
	my $unit = shift;
	for my $re (keys %unit_distances) {
		return $unit_distances{$re} if $unit =~ /$re/;
	}
}

# Returns time in seconds.
# Cannot handle seconds only; cannot handle hours.
sub SimplifyTime {
	my $time = shift;
	$time =~ m/(\d+):(\d\d(?:\.\d+)?)/;	
	return ($1 * 60) + $2;
}

# Returns distance in meters.
sub SimplifyDistance {
	my $dist = shift;
	return $named_distances{$dist} if exists $named_distances{$dist};
	return $+{count} * MetersPerUnit($+{unit}) if $dist =~ m/$distunit_re/;
}

# Returns pace in seconds per meter.
sub SimplifyPace {
	my $pace = shift;
	return SimplifyTime($+{pacetime}) / MetersPerUnit($+{paceunit}) if $pace =~ m/$pace_re/;
}

sub SolveForPace {
	my ($time, $dist, $resultunit) = @_;
	my $permeter = SimplifyTime($time) / SimplifyDistance($dist);
	my $perunit = $permeter * MetersPerUnit($resultunit);
	return "Pace: " . FormatTime($perunit) . "/$resultunit";
}

sub SolveForDistance {
	my ($time, $pace, $resultunit) = @_;
	my $meters = SimplifyTime($time) / SimplifyPace($pace);
	return "Distance: " . $meters / MetersPerUnit($resultunit) . " $resultunit";
}

sub SolveForTime {
	my ($dist, $pace) = @_;
	my $seconds = SimplifyDistance($dist) * SimplifyPace($pace);
	return "Time: " . FormatTime($seconds);
}

handle remainder => sub {
	if (m/^(?<time>$time_re) (?<dist>$distance_re)$resultunit_re$/ or m/^(?<dist>$distance_re) (?<time>$time_re)$resultunit_re$/) {
		my $resultunit = exists $+{result} ? $+{result} : exists $+{unit} ? $+{unit} : 'mile';
		return SolveForPace($+{time}, $+{dist}, $resultunit);
	} elsif (m/^(?<time>$time_re) (?<pace>$pace_re)$resultunit_re$/ or m/^(?<pace>$pace_re) (?<time>$time_re)$resultunit_re$/) {
		my $resultunit = exists $+{result} ? $+{result} : exists $+{paceunit} ? $+{paceunit} : 'mile';
		return SolveForDistance($+{time}, $+{pace}, $resultunit);
	} elsif (m/^(?<dist>$distance_re) (?<pace>$pace_re)$/ or m/^(?<pace>$pace_re) (?<dist>$distance_re)$/) {
		return SolveForTime($+{dist}, $+{pace});
	} else {
		return;
	}
};

1;
