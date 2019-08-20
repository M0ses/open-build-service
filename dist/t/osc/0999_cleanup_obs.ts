#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use FindBin;
use File::Path qw(make_path remove_tree);

my $TMP_DIR="$FindBin::Bin/tmp/";

if ( -f "$TMP_DIR/.SKIP" ) {
  plan skip_all => "Previous tests failed - keeping results";
} else {
  plan tests => 2;


  system("osc rdelete -rf -m 'Cleanup home:Admin' home:Admin");

  ok(!$?,"Deleting project home:Admin");

  system("osc rdelete -rf -m 'Cleanup Interconnect' openSUSE.org");
  ok(!$?,"Deleting Interconnect");

  # cleanup TMP_DIR
  chdir($FindBin::Bin);
  remove_tree($TMP_DIR);
}

exit 0;
