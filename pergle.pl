#!usr/bin/perl

use warnings;
use threads;
use JSON;
use LWP::Simple;
use HTTP::Request::Common qw(POST);
use LWP::UserAgent;

my $ua = LWP::UserAgent->new;
my $id = get 'http://promenade.omegle.com/start';
my $sid = substr($id, 1, -1);
print 'Got ID:', $sid, "\n";

sub Listen {
    my $done;
        while (! $done) {
        my $rec = POST('http://promenade.omegle.com/events', [ id => $sid ]);
        my $res = $ua->request($rec);
#        print "test: ".$res->content."\n";
        my $json = new JSON;
        my $events = $json->decode($res->content);
        foreach my $evt (@$events) {
            my $evt_name = $evt->[0]
                or next;
            if ($evt_name eq 'connected') {
                print "Connection established.\n";
            } elsif ($evt_name eq 'gotMessage') {
                print "Stranger: ".$evt->[1]."\n";
            } elsif ($evt_name eq 'strangerDisconnected') {
                print "Stranger disconnected.\n";
                die;
            } elsif ($evt_name eq 'typing') {
                print "Stranger is typing.\n";
            } elsif ($evt_name eq 'stoppedTyping') {
                print "Stranger has stopped typing.\n";
            } elsif ($evt_name eq 'waiting') {

            } elsif ($evt_name eq 'count') {
                print $evt->[1]. " strangers online.\n";
            } 
        }
    }
}

sub Talk {
    my $done;
    while ( ! $done ) {
      print ">";
      $msg = <STDIN>;
      my $msn = POST('http://promenade.omegle.com/send', [ id => $sid, msg => $msg ]);
      my $smsn = $ua->request($msn);
      print "Sent: ".$msg;
    }
}

my $listenThread = threads->create(\&Listen);
my $talkThread = threads->create(\&Talk);
$_->join() foreach ( $listenThread, $talkThread );
