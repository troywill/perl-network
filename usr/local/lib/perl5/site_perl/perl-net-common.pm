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
        system("$SUDO ip link set wlan0 up");
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

sub get_sudo {
    my $sudo_binary = shift;
    my $sudo = '';
    unless ( $ENV{USER} eq 'root' ) {
	$sudo = $sudo_binary if ( -e $sudo_binary );
    }
    return $sudo;
}

1;