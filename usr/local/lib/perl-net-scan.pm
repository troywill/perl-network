#===== SUBROUTINE ===========================================================
# Name      : wireless_cell_hash()
# Purpose   : run Jean_Tourrilhes' iwlist program and turn results into Perl hash
# Parameters: $scan_command - typically '/usr/sbin/iwlist wlan0 scan'
# Returns   : \%HoC - reference to a hash of wireless cell hashes
# Comments  : The keys of %HOC are the wireless cell MAC addresses
#============================================================================
sub wireless_cell_hash {
    my $scan_command = shift;
    print "DEBUG1: $scan_command\n";
    my $HoC_ref = scan_to_hash( $scan_command );
    my %HoC = %{$HoC_ref};
    foreach my $mac ( keys %HoC ) {
        if ( $HoC{$mac}{encryption_state} eq 'on' ) {
            if (   ( $HoC{$mac}{security_type} eq 'WPAWPA2' )
                || ( $HoC{$mac}{security_type} eq 'WPA2WPA' ) )
            {
                $HoC{$mac}{security_type} = 'WPA+WPA2';
            }
            $HoC{$mac}{security_type} = 'WEP'
              if ( $HoC{$mac}{security_type} eq '' );
        }
        else {
            $HoC{$mac}{security_type} = 'OPEN';
        }
    }
    return \%HoC;
}


#===== SUBROUTINE ===========================================================
# Name      : process_options()
# Purpose   : parse command line options and update the %Option hash
# Parameters: none
# Returns   : n/a
# Throws    : a fatal error if a bad command line option is given
# Comments  : checks @ARGV for valid package names
#============================================================================
sub scan_to_hash {
    my ( $scan_command ) = @_;
    my ( %cell, %HoC, $mac, $security_type );
    print "DEBUG2: $scan_command\n";
    open( my $WIRELESS_SCAN, "$scan_command |" )
      or die "Tried, but unable to open $scan_command: $!";
    while (<$WIRELESS_SCAN>) {
        if (
m/^\s+Cell\s+\d+\s+-*\s*Address:\s*(([0-9a-fA-F]{2}[:-]{1}){5}([0-9a-fA-F]{2}))/
          )
        {
            $mac           = $1;
            %cell          = ( mac => $mac );
            $security_type = '';
        }
        elsif (m/^\s*Channel:(\d+)$/) {
            $HoC{$mac}{channel} = $1;
        }
        elsif (m/^\s*ESSID:*\"(.*?)\"/) {
            $HoC{$mac}{essid} = $1;
        }
        elsif (m/^\s*Quality=(\d+)\/(\d+)\s*/) {
            $HoC{$mac}{quality} = $1;
        }
        elsif (m/^\s*Encryption key:(.*?)$/) {
            $HoC{$mac}{encryption_state} = $1;

            # security type
        }
        elsif (m/IEEE 802.11i\/WPA2 Version 1/) {
            $security_type .= "WPA2";
            $HoC{$mac}{security_type} = $security_type;
        }
        elsif (m/WPA Version 1/) {
            $security_type .= "WPA";
            $HoC{$mac}{security_type} = $security_type;
        }
    }
    return \%HoC;
}

1;
