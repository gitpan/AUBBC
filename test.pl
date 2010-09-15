# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

my ($message, $setting, $aubbc, $Current_version, %msg) =
        ('[br][utf://#x23]', '', '', '', (1 => "Test ok ", 2 => "Test error ", ) );

BEGIN {
        $| = 1;
        print "Test's 1 to 4\n";
}

END {
        # did we get a setting?
        #$setting = 5; # reinforce failure
        $setting eq ' /'
                ? print $msg{1} . "3\n"
                : print $msg{2} . "3\n";
                
        # did we get the version?
        #$Current_version = 5; # reinforce failure
        $Current_version eq '3.00'
                ? print $msg{1} . "4\n"
                : print $msg{2} . "4\n";
}

use AUBBC;
$aubbc = new AUBBC;
{
        # did it load?
        #$aubbc = ''; # main reinforce failure
        $aubbc
                ? print $msg{1} . "1\n"
                : print $msg{2} . "1\n";

        $aubbc->settings(html_type => 'xhtml') if $aubbc;
        $message = $aubbc->do_all_ubbc($message) if $aubbc;
        $setting = $aubbc->get_setting('html_type') if $aubbc;
        $Current_version = $aubbc->version() if $aubbc;

        # did it convert?
        #$message .= ']'; # reinforce failure
        $message !~ m/[\[\]\:]+/
                ? print $msg{1} . "2\n"
                : print $msg{2} . "2\n";
}
