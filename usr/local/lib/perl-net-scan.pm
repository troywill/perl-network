sub scan_to_hash {
    my ( $interface, $scan_command ) = @_;
    print "[$interface, $scan_command]\n";
    my ( %cell, %HoC, $mac, $security_type );
    open (my $WIRELESS_SCAN, "$scan_command |") or die "Tried, but unable to open $scan_command: $!";
    while ( <$WIRELESS_SCAN> ) {
	if ( m/^\s+Cell\s+\d+\s+-*\s*Address:\s*(([0-9a-fA-F]{2}[:-]{1}){5}([0-9a-fA-F]{2}))/ ) {
	    $mac = $1;
	    %cell = ( mac  => $mac );
	    $security_type = '';
	} elsif (m/^\s*ESSID:*\"(.*?)\"/ ) {
	    $HoC{$mac}{ESSID} = $1;
	} elsif ( m/^\s*Quality=(\d+)\/(\d+)\s*/ ) {
	    $HoC{$mac}{Quality} = $1;
	} elsif ( m/^\s*Encryption key:(.*?)$/ ) {
	    $HoC{$mac}{Encryption} = $1;
	    # security type
	} elsif ( m/IEEE 802.11i\/WPA2 Version 1/ ) {
	    $security_type .= "WPA2";
	    $HoC{$mac}{security} = $security_type;
	} elsif ( m/WPA Version 1/ ) {
	    $security_type .= "WPA";
	    $HoC{$mac}{security} = $security_type;
	}
    }
    return \%HoC;
}

sub cell_hash {
    my ( $interface, $scan_command ) = @_;
    my $HoC_ref = &scan_to_hash( $interface, $scan_command );
    my %HoC = %{$HoC_ref};
    foreach my $mac ( keys %HoC ) {
	if ( $HoC{$mac}{Encryption} eq 'on' ) {
	    print "DEBUG $HoC{$mac}{ESSID} =>$HoC{$mac}{security}<=\n";
	    if ( ($HoC{$mac}{security} eq 'WPAWPA2') || ($HoC{$mac}{security} eq 'WPA2WPA')) {
		$HoC{$mac}{security} = 'WPA+WPA2';
	    }
	    $HoC{$mac}{security} = 'WEP' if ( $HoC{$mac}{security} eq '' );
	} else {
	    print "NO security";
	}
    }
    return \%HoC;
}

1;
