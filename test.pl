

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)
my ( $loaded, $aubbc ) = ( 0, '' );

BEGIN { $| = 1;  print "1..3\n"; }
END {
        if (!$loaded) {
                print "not ok 3\n";
                }
                 else {
                        print "ok 3\n";
                        }
}

use AUBBC;
$aubbc = new AUBBC;
$loaded = 1 if $aubbc;
print "ok 1\n" if $aubbc;
{

        my $Current_version = $aubbc->version() || 0;

 if ($Current_version) {
      print "ok 2\n";
 }
 else {
      print "not ok 2\n";
 }

}
