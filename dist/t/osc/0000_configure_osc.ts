#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 2;
use File::Path;

use Net::Domain qw(hostfqdn);
my $fqhn = hostfqdn();

ok($fqhn,"Checking for fully qualified hostname");

eval {
  my $confdir = "$::ENV{HOME}/.config/osc/";
  unless (-d $confdir) { File::Path::make_path($confdir); }
  my $oscrc="$confdir/oscrc";
  unless (-f $oscrc ) {
    open(OSCRC,'>',$oscrc) || die "Could not open $oscrc: $!";
    print OSCRC "# see oscrc(5) man page for the full list of available options

[general]
# Default URL to the API server.
# Credentials and other `apiurl` specific settings must be configured in a `[\$apiurl]` config section.
apiurl=https://$fqhn

[https://$fqhn]
# aliases=
# user=
# pass=
# credentials_mgr_class=osc.credentials...
user=Admin
pass=opensuse
credentials_mgr_class=osc.credentials.PlaintextConfigFileCredentialsManager
";
    close OSCRC;
  }
  my $username = getpwuid($<);
  if ($username eq 'root' || $username eq 'gitea') {
     # su -s /bin/bash -c "gitea admin user generate-access-token --username obsadmin --token-name localosc" - gitea
     my $ct = ($username eq 'root' ) ? 'su -s /bin/bash -c "%s" - gitea' :'%s';
     my $cmd = sprintf($ct, 'gitea admin user generate-access-token --username obsadmin --token-name localosc');
     my $out = `$cmd`;
     if ($out =~ m#Access token was successfully created: (\S+)#) {
        my $token=$1;
	$out = `git-obs login add --url https://$fqhn/gitea/ --user obsadmin --token $token $fqhn`;
        die $out if $?;
     }
  }
};

ok(!$@,"Configuring oscrc");

exit 0
