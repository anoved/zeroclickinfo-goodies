package DDG::Goodie::PaceCalculator;
# ABSTRACT: Calculate running pace.

use DDG::Goodie;

# with 'DDG::GoodieRole::NumberStyler';
# my $number_re = number_style_regex();

triggers end => "pace";

my $time_re = qr/\d+:\d\d(?:\.\d+)?/;
my $unit_re = qr/miles?|meters?|km?|kilometers?|kilometres?/;
my $count_re = qr/\d+(?:\.\d+)?/;
my $dist_re = qr/marathon|half marathon|$count_re ?$unit_re/;
my $pace_re = qr/$time_re\/$unit_re/;

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
	if ($unit =~ m/miles?/) {
		return 1609.344;
	} elsif($unit =~ m/meters?/) {
		return 1;
	} elsif($unit =~ m/km?|kilometers?|kilometres?/) {
		return 1000;
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
	if ($dist =~ m/marathon/) {
		return 42195;
	} elsif ($dist =~ m/half marathon/) {
		return 21098;
	} elsif ($dist =~ m/($count_re) ?($unit_re)/) {
		return $1 * MetersPerUnit($2);
	}
}

# Returns pace in seconds per meter.
sub SimplifyPace {
	my $pace = shift;
	$pace =~ m/($time_re)\/($unit_re)/;
	my $ptime = $1;
	my $punit = $2;
	return SimplifyTime($ptime) / MetersPerUnit($punit);
}

sub SolveForPace {
	my ($time, $dist) = @_;
	my $permeter = SimplifyTime($time) / SimplifyDistance($dist);
	# infer appropriate unit from distance unit, default, or explicit request
	my $perunit = $permeter * MetersPerUnit("mile");
	my $pace = FormatTime($perunit);
	return "Pace: $pace/mile";
}

sub SolveForDistance {
	my ($time, $pace) = @_;
	my $meters = SimplifyTime($time) / SimplifyPace($pace);
	# infer appropriate unit from distance unit, default, or explicit request
	my $units = $meters / MetersPerUnit("miles");
	return "Distance: $units miles";
}

sub SolveForTime {
	my ($dist, $pace) = @_;
	my $seconds = SimplifyDistance($dist) * SimplifyPace($pace);
	my $time = FormatTime($seconds);
	return "Time: $time"; 
}

handle remainder => sub {
	if (m/^($time_re) ($dist_re)$/) {
		return SolveForPace($1, $2);
	} elsif (m/^($dist_re) ($time_re)$/) {
		return SolveForPace($2, $1);
	} elsif (m/^($time_re) ($pace_re)$/) {
		return SolveForDistance($1, $2);
	} elsif (m/^($pace_re) ($time_re)$/) {
		return SolveForDistance($2, $1);
	} elsif (m/^($dist_re) ($pace_re)$/) {
		return SolveForTime($1, $2);
	} elsif (m/^($pace_re) ($dist_re)$/) {
		return SolveForTime($2, $1);
	} else {
		return;
	}
};

1;
