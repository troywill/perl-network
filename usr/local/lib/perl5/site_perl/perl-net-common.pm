sub get_operstate {
    my $sys_file = shift;
    open( my $fh, '<', $sys_file ) or die "Unable to open $sys_file for reading: $!";
    chomp(my $operstate = <$fh>);
    close $fh;
    return $operstate;
}

sub bring_up_wireless_interface {
    my ( $interface, $operstate_sys_file ) = @_;
    my $operstate = get_operstate( $operstate_sys_file );
    if ( $operstate eq 'down' ) {
        system("ip link set $interface up");
    }
}

sub get_carrier {
    my $sys_file = shift;
    open( my $fh, '<', $sys_file ) or die "Unable to open $sys_file for reading: $!";
    my $carrier = <$fh>;
    close $fh;
    $carrier = -1 if !defined($carrier);
    chomp( $carrier );
    return $carrier;
}

sub find_wireless_device {
    my $wireless_device = "";
    my @devices = </sys/class/net/*>;
    foreach my $device ( @devices ) {
        if ( $device =~ /\/sys\/class\/net\/(w.*?)$/ ) {
            $wireless_device = $1;
            print $1, "\n";
        }
    }
    return $wireless_device;
}


1;
