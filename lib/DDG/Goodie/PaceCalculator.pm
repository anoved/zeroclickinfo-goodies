package DDG::Goodie::PaceCalculator;
# ABSTRACT: Calculate running pace.

use DDG::Goodie;

triggers end => "pace";

# table of unit expressions to meters
my %unit_distances = (
	qr/met(?:er|re)s?/ => 1,
	qr/(?:km?|kilomet(?:er|re)s?)/ => 1000,
	qr/miles?/ => 1609
);

my $unit_dists = join("|", keys(%unit_distances));
my $unit_re = qr/$unit_dists/;

my $time_re = qr/(?<time>(?:(?<hours>\d+):)?(?<minutes>\d+):(?<seconds>\d\d(?:\.\d+)?))/;
my $pace_re = qr/(?<pace>(?<pacetime>$time_re)\/(?<paceunit>$unit_re))/;
my $count_re = qr/\d+(?:\.\d+)?/;

# table of named distances to meters
my %named_distances = (
	"marathon" => 42195,
	"half marathon" => 21098
);

# assemble re of exact matches for named distance keys
my $named_dists = join("|", map(quotemeta, keys(%named_distances)));
my $distunit_re = qr/(?<count>$count_re) ?(?<unit>$unit_re)/;
my $distance_re = qr/(?<dist>$named_dists|$distunit_re)/;

my $resultunit_re = qr/(?:\s+(?<result>$unit_re))?/;

#
# FormatTime
#
# Given a time in seconds, returns formatted string.
# Uses HH:MM:SS format. Fragile.
#
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
	
	return ($hours > 0 ? sprintf('%d:%02d:%02d', $hours, $minutes, $seconds) : sprintf('%d:%02d', $minutes, $seconds));
}

#
# MetersPerUnit
#
# Returns meter equivalent of given unit.
#
sub MetersPerUnit {
	my $unit = shift;
	for my $re (keys %unit_distances) {
		return $unit_distances{$re} if $unit =~ /^$re$/;
	}
}

#
# SimplifyTime
#
# Returns time in seconds. Fragile.
# 
sub SimplifyTime {
	my $time = shift;
	$time =~ m/$time_re/;
	my $seconds = 0;
	$seconds += $+{seconds} if exists $+{seconds};
	$seconds += $+{minutes} * 60 if exists $+{minutes};
	$seconds += $+{hours} * 3600 if exists $+{hours};
	return $seconds;
}

#
# SimplifyDistance
#
# Returns distance in meters.
#
sub SimplifyDistance {
	my $dist = shift;
	return $named_distances{$dist} if exists $named_distances{$dist};
	return $+{count} * MetersPerUnit($+{unit}) if $dist =~ m/$distunit_re/;
}

#
# SimplifyPace
#
# Returns pace in seconds per meter.
#
sub SimplifyPace {
	my $pace = shift;
	return SimplifyTime($+{pacetime}) / MetersPerUnit($+{paceunit}) if $pace =~ m/$pace_re/;
}

#
# SolveForPace
#
# Given a distance and total time, return average pace.
#
sub SolveForPace {
	my ($time, $dist, $resultunit) = @_;
	my $permeter = SimplifyTime($time) / SimplifyDistance($dist);
	my $perunit = $permeter * MetersPerUnit($resultunit);
	return "Pace: " . FormatTime($perunit) . "/$resultunit";
}

#
# SolveForDistance
#
# Given a pace and a total time, return total distance.
#
sub SolveForDistance {
	my ($time, $pace, $resultunit) = @_;
	my $meters = SimplifyTime($time) / SimplifyPace($pace);
	my $distance = $meters / MetersPerUnit($resultunit);
	return sprintf("Distance: %.2f %s", $distance, $resultunit);
}

#
# SolveForTime
#
# Given a distance and a pace, return predicted total time.
#
sub SolveForTime {
	my ($dist, $pace) = @_;
	my $seconds = SimplifyDistance($dist) * SimplifyPace($pace);
	return "Time: " . FormatTime($seconds);
}

handle remainder => sub {
	if (m/^$time_re $distance_re$resultunit_re$/
			or m/^$distance_re $time_re$resultunit_re$/) {
		my $resultunit = exists $+{result} ? $+{result} : exists $+{unit} ? $+{unit} : 'mile';
		return SolveForPace($+{time}, $+{dist}, $resultunit);
	} elsif (m/^$time_re $pace_re$resultunit_re$/
			or m/^$pace_re $time_re$resultunit_re$/) {
		my $resultunit = exists $+{result} ? $+{result} : exists $+{paceunit} ? $+{paceunit} : 'mile';
		return SolveForDistance($+{time}, $+{pace}, $resultunit);
	} elsif (m/^$distance_re $pace_re$/
			or m/^$pace_re $distance_re$/) {
		return SolveForTime($+{dist}, $+{pace});
	} else {
		return;
	}
};

1;