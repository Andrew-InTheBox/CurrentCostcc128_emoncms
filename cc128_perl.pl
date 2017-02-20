#!/usr/bin/perl -w
# Reads data from a Current Cost device via serial port.

use strict;
use warnings;
use Device::SerialPort qw( :PARAM :STAT 0.07 );
use LWP::UserAgent;

    my $key = "EmoncmsApiKey";
    my $PORT = "/dev/ttyAMA0";
    my $meas = 0;
    my $sumW = 0;
    my $sumT = 0;
    my $watts;
    my $temp;
    my $localtime; 

    my $ob = Device::SerialPort->new($PORT)  || die "Can't open $PORT: $!\n";
    $ob->baudrate(57600);
    $ob->write_settings;

    open(SERIAL, "+>$PORT");
    while (my $line = <SERIAL>) {
        #print "line is - $line";
        if ($line =~ m!<tmprF>\s*(-*[\d.]+)</tmprF>.*<ch1><watts>0*(\d+)</watts></ch1>.*<ch2><watts>0*(\d+)</watts></ch2>*!) {
            my $watts1 = $2;
	    my $watts2 = $3;
            my $temp = $1;
            #print "$meas: ... $watts1, $watts2, $temp\n";
            $meas++;
            $sumW += $watts1+$watts2;
            $sumT += $temp;
        }
        if ($meas == 2) { #time to send
           $watts = $sumW/2;
           $temp = $sumT/2;
           
           #print "AVERAGE: ... $watts, $temp\n";
           my $emon_ua = LWP::UserAgent->new;
           my $emon_url = "http://emoncms.org/input/post.json?json={power:$watts,temp:$temp}&apikey=$key";
           my $emon_response = $emon_ua->get($emon_url);
        $meas = $sumW = $sumT = 0;
        }
}

#below is example line from cc128 serial output
# <msg><src>CC128-v0.15</src><dsb>01039</dsb><time>22:04:56</time><tmprF>65.6</tmprF><sensor>0</sensor><id>00077</id><type>1</type><ch1><watts>00595</watts></ch1><ch2><watts>00860</watts></ch2></msg>
