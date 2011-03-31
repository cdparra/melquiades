#!/usr/bin/perl
# csv_from_table.pl
use strict;
use LWP::Simple;

my $phases_file = shift;
open (F_PHASE, "<", $phases_file)  or  die "Failed to read file $phases_file : $!";

my $dapp_url = "http://open.dapper.net/transform.php?dappName=FrenchResearchersCompetitionsRankingsADMISSION"
               . "&transformer=CSV&extraArg_fields[]=rank&extraArg_fields[]=fullname&applyToUrl=";


my $url_base = "http%3A%2F%2Fintersection.dsi.cnrs.fr%2Fintersection%2Fresultats-cc-en.do%3Fcampagne%3D34";

# URL parts encoded
my $param_competition = "%26conc%3D";
my $param_phase = "%26phase%3D";
print "Calling dapp: $dapp_url\n";
print "Applying on Base URL: $url_base\n";


print "Reading parameters for URL in $phases_file\n";
my $skip = 1;
PHASE: while (<F_PHASE>) {

    my($line) = $_; 
    chomp($line);
    
    my @code = split(/\//, $line);

    my $section = $code[0];
    my $aux = $code[1];
    my $competition = "$section%2F$aux";

    print "LINE: $section | $aux | $competition\n";
    print "LINE: $line\n";

    my @phases = ("ADMISSION","ADMCONC","ADMISSIBILITE");

    LINE: foreach (@phases) {
        my $start = time();
        my $end = time();

        my $phase = $_;
 
        my $csv_file = "../dataset/rankings/$phase-$section-$aux.csv";

        if ( -s $csv_file ) {
            print "$csv_file SKIPPED. Already processed\n";
            $end = time();
            printf("Elapsed Time --> %.2f\n", $end - $start);
            next LINE;
        }

        my $final_url = "$dapp_url$url_base$param_competition$competition$param_phase$phase";
        print "Getting --> Competition: $section/$aux | Phase: $phase\n";
        print "Getting --> $final_url\n";
     
        my $content = get($final_url);

        my $ua = new LWP::UserAgent; $ua->agent("0/0.1 " . $ua->agent);
        $ua->agent("Mozilla/8.0");
        # pretend we are very capable browser
        my $req = new HTTP::Request 'GET' => "$final_url";
        $req->header('Accept' => 'text/plain');
        # send request 
        my $res = $ua->request($req);
        # check the outcome 
        if ($res->is_success) {
             open (F_CSV, ">", $csv_file) or die "Failed to write to file $csv_file : $!";
             print F_CSV $res->content;
             print "$csv_file DONE\n";
             close (F_CSV);
         }
         else {
             open (F_CSV, ">", $csv_file) or die "Failed to write to file $csv_file : $!";
             print "Error: " . $res->status_line . "\n";
             print F_CSV "Error: " . $res->status_line . "\n";
             print "$csv_file DONE";
             close (F_CSV);
         } 
         print "Sleeping for 2 seconds to respect Dapper SLA... \n";
         sleep(2);
         $end = time();
         printf("Elapsed Time --> %.2f\n", $end - $start);
     }
}
close (F_PHASE);
