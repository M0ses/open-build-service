#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

my $tests    = 14;
my $max_wait = 300;

my @daemons = qw/obsdispatcher.service  obspublisher.service    obsrepserver.service
                 obsscheduler.service   obssrcserver.service/;

my $out=`systemctl list-units`;
my $mariadb;
foreach my $unit (split(/\n/, $out)) {
  $mariadb = $1 if $unit =~ /^\s*((mysql|mariadb)\.service)\s+/
}

die "could not find mariadb or mysql" if ! $mariadb;

push @daemons, $mariadb;

my $os = get_distribution();
if ($os eq "suse") {
  push @daemons, "apache2.service";
} elsif ($os eq 'rh') {
  push @daemons, "httpd.service";
} else {
  die "Could not determine distribution!\n";
}

my $version = `rpm -q --queryformat %{Version} obs-server`;

if ($version !~ /^2\.[89]\./) {
  unshift @daemons, "obs-api-support.target";
  $tests = 16;
}

plan tests => $tests;

foreach my $srv (@daemons) {
	my @state=`systemctl is-enabled $srv 2>/dev/null`;
	my $result='';
	if (@state) {
	  $result=$state[-1];
	  chomp($result);
	}
	is($result, "enabled", "Checking if recommended systemd unit $srv is enabled") || print "result: $result\n";
}

my %srv_state=();

while ($max_wait > 0) {
	my $failed=0;
	foreach my $srv (@daemons) {
		my @state=`systemctl is-active $srv 2>/dev/null`;
		chomp($state[0]);
		print "$srv $state[0]\n";
		if ( $state[0] eq 'active') {
			$srv_state{$srv} = $state[0];
		} elsif ( $state[0] eq 'failed') {
			$failed=1;
			$srv_state{$srv} = $state[0];
		}
	}
	last if (keys(%srv_state) == scalar(@daemons));
	last if ($failed);
	$max_wait--;
	sleep 1;
}

foreach my $srv ( @daemons ) {
	is($srv_state{$srv} || 'timeout','active',"Checking recommended systemd unit '$srv' status");
}


exit 0;

sub get_distribution {
  my $fh;
  my $os = "";
  open $fh, '<', '/etc/os-release' || die "Could not open /etc/os-release: $!";
  my $line;
  while ($line = <$fh>) {
    $os = 'suse' if ($line =~ /^ID_LIKE=.*suse.*/);
    $os = 'rh' if ($line =~ /^ID(_LIKE)?=.*fedora.*/);
  }
  close $fh;
  return $os
}
