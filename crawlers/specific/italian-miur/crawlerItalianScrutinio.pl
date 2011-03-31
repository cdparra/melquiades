#!/usr/bin/perl
# csv_from_table.pl
use strict;
use LWP::Simple;

my $params_file = shift;
open (F_PARAMS, "<", $params_file)  or  die "Failed to read file $params_file : $!";


my $dapp_url = "http://open.dapper.net/transform.php?dappName=ReclutamentoItalyResults&"
               . "transformer=CSV&extraArg_fields[]=sector&extraArg_fields[]=university&"
               . "extraArg_fields[]=nro&extraArg_fields[]=name&extraArg_fields[]=votes&"
               . "extraArg_fields[]=lastname&extraArg_fields[]=TitolareAffine&"
               . "extraArg_fields[]=faculty&applyToUrl=";

# URL parts encoded
my $url_base = "http%3A%2F%2Freclutamento.murst.it%2Fsessioni_2008%2Fscrutini_precedenti.php"
               ."%3Fcerca%3Dcerca%26parte%3D1%26ruolo%3DR";

my $param_sessione = "%26prec%3D"; 
my $param_settore = "%26codice%3D"; 

print "Calling dapp: $dapp_url\n";
print "Applyin on Base URL: $url_base\n";

print "Reading parameters for URL in $params_file\n";
LINE: while (<F_PARAMS>) {
# read html file line by line

    my $start = time();
    my $end = time();
    my($line) = $_; 
    chomp($line);
    my @code = split(/,/, $line);

    my $settore = $code[0];
    my $sessione = $code[1];

    my $csv_file = "../dataset/csv/$sessione-$settore.csv";

    if ( -s $csv_file ) {
       print "$csv_file SKIPPED. Already processed\n";
       $end = time();
       printf("Elapsed Time --> %.2f\n", $end - $start);
       next LINE;
    }

    my $final_url = "$dapp_url$url_base$param_settore$settore$param_sessione$sessione";
    print "Getting --> Session: $sessione | Sector: $settore\n";
     
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
close (F_PARAM);
