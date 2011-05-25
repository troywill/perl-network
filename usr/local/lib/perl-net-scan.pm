sub scan_hash {
    my ( $interface, $scan_command ) = @_;
    my ( %cell, %HoC, $mac, $security_type );
    open (my $WIRELESS_SCAN, "$scan_command |") or die "Unable to open $scan_command: $!";
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
	    $security_type .= "[WPA2]";
	    $HoC{$mac}{security} = $security_type;
	} elsif ( m/WPA Version 1/ ) {
	    $security_type .= "[WPA]";
	    $HoC{$mac}{security} = $security_type;
	}
    }
    return \%HoC;
}

1;
