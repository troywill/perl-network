#!/usr/bin/env perl
use warnings;
use strict;
use FindBin qw( $Bin );
use lib "$Bin/../lib/perl5/site_perl";
require "perl-net-common.pm";
require "perl-net-scan.pm";

my $VERBOSE          = 1;
my $NUMBER_OF_SCANS  = 2;
my $CARRIER_SYS_FILE   = '/sys/class/net/wlan0/carrier';
my $OPERSTATE_SYS_FILE = '/sys/class/net/wlan0/operstate';
my $WIRELESS_INTERFACE = 'wlan0';
my $SCAN_COMMAND       = "iwlist ${WIRELESS_INTERFACE} scanning";
my $VIDEO_COMMAND = 'mplayer -zoom -x 640 -y 480 /usr/local/share/mcdonalds.flv';
use constant WIRELESS_FILE => '/usr/local/etc/wireless/00';

my $carrier = get_carrier( $CARRIER_SYS_FILE );
my %known_macs         = read_known_networks(WIRELESS_FILE);
bring_up_wireless_interface($WIRELESS_INTERFACE, $OPERSTATE_SYS_FILE);
wait_for_interface();
my $available_macs_ref = wireless_cell_hash($SCAN_COMMAND);
my %available_macs = %{$available_macs_ref};

print_message_marv();
connect_to_secure_network();
search_for_open_networks();
exit;
exit if ( $carrier == 1 );

sub connect_to_network_by_mac {

# %HoH is hash of available wireless cell hashes from external program ( iwlist scanning )
    my ( $mac, $known_macs_ref, $HoH_ref ) = @_;
    my %known_macs_ref = %{$known_macs_ref};
    my %HoH            = %{$HoH_ref};

    if ( $HoH{$mac}{security_type} eq 'WEP' ) {
        my $key = $known_macs{$mac}{key};
        connect_to_wep( $key, $HoH{$mac}{essid} );
    }
}

sub connect_to_secure_network {
    foreach my $mac ( keys %known_macs ) {
	if ( $available_macs{$mac} ) {
	    print
		"==> Network '$available_macs{$mac}{essid}' found, connecting ...\n";
	    connect_to_network_by_mac( $mac, \%known_macs, \%available_macs );
	    open( my $essid_file, '>', '/tmp/essid' )
		|| die "Unable to open /tmp/essid for output";
	    print $essid_file "$mac\n";
	    close $essid_file;
	}
    }
}

sub search_for_open_networks {
    my %open_networks =
	( 'Wayport_Access' => 'McDonalds' );
    foreach my $mac ( keys %available_macs ) {
	if ( $available_macs{$mac}{encryption_state} eq 'off' ) {
	    foreach my $essid ( keys %open_networks ) {
		if ( $essid eq $available_macs{$mac}{essid} ) {
		    connect_to_open_network($essid);
		}
	    }
	}
    }
}

system("perl-wireless-daemon");

sub run_video {
    my $command = shift;
    system $command;
}

sub connect_to_open_network {
    my $essid = shift;
    wait_for_interface();
    print "==> Connecting to open network [$essid]\n";
    system("/usr/sbin/iwconfig wlan0 essid $essid");
    sleep 1;
    system("/usr/sbin/iwconfig wlan0 essid $essid");
    print "DEBUG: check ESSID after doing iwconfig wlan0 essid $essid ...\n"; 
    system("iwconfig wlan0 | grep ESSID");
    run_dhcpcd( $WIRELESS_INTERFACE );
    run_video($VIDEO_COMMAND);
    exit;
}

sub run_dhcpcd {
    my $interface = shift;
    my $command = "dhcpcd --rebind ${interface} 2>&1";
    print "==> $command\n";
    open (my $dhcpcd,"$command |") or die "Not able to open dhcpcd";
    my $line1 = <$dhcpcd>;
    print "DEBUG L73: $line1\n";
    $line1 =~ /dhcpcd\[(\d+)\]/;
    my $dhcpcd_pid = $1;
    print "dhcpcd_pid = [$dhcpcd_pid], may want to kill it\n";
    while (my $line = <$dhcpcd>) {
	chomp($line);
	print "line: $line\n";
	if ( $line =~ /carrier lost/ ) {
	    print "BAILING OUT!\n";
	    close $dhcpcd;
	}
    }
    close $dhcpcd if defined($dhcpcd);
}

sub connect_to_wep {
    my ( $key, $essid ) = @_;
    print "==> [$key][$essid]\n";
    system("/usr/sbin/iwconfig wlan0 key $key essid $essid");
    sleep 1;
    run_dhcpcd( $WIRELESS_INTERFACE );
}

sub wait_for_interface {
    my ( $operstate, $carrier ) = get_interface_state();
    while (($carrier != 1) && ($carrier!=0)) {
	print "--------------------- carrier != 1 or 0 ------------------\n";
	system("ip link set wlan0 up 2>/dev/null");
	( $operstate, $carrier ) = get_interface_state();
    }
    while (( $operstate ne 'up') && ( $operstate ne 'down')) {
	print "---- operstate ne 'up' ------------------\n";
	system("ip link set wlan0 up 2>/dev/null");
	( $operstate, $carrier ) = get_interface_state();
	print "-----------------------------------------\n";
	print "\t==> [ $operstate, $carrier ]\n";
	sleep 1;
    }
}

sub get_interface_state {
    my $operstate = get_operstate( $OPERSTATE_SYS_FILE );
    my $carrier = get_carrier( $CARRIER_SYS_FILE );
    print "operstate = $operstate, carrier = $carrier\n" if $VERBOSE;
    return ( $operstate, $carrier );
}

sub print_message_marv {
    print "==> Detecting if you are at 456 W San Jose or 475 Stanford ...\n";
}

# Read mac, essid from file
sub read_known_networks {
    my $file = shift;
    my %HoN;
    open my $fh, "<", $file;
    while (<$fh>) {
        chomp;
        my ( $mac, $essid, $key, $security_type ) = split /,/;
        $HoN{$mac}{essid} = $essid;
        $HoN{$mac}{key}   = $key;
    }
    close $fh;
    return (%HoN);
}
