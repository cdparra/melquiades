#!/usr/bin/perl
# csv_from_table.pl
use strict;
use LWP::Simple;


my $help = 
  qq(dapper-crawler.pl <dapp name> <dapp transformer {CSV,XML...}> <fields file {one per line}> <urls file {one per line}> <output dir> );


if ($#ARGV < 4) {
  print "Missing parameters\n.$help\n\n"; 
  exit;
}

my $dapp_name = shift;
my $dapp_transformer = shift;
my $fields_file = shift;
my $urls_file = shift;
my $output_dir = shift;

open (F_URLS, "<", $urls_file)  or  die "Failed to read file $urls_file : $!";
open (F_FIELDS, "<", $fields_file)  or  die "Failed to read file $fields_file : $!";


my $dapp_url = 
  qq(http://open.dapper.net/transform.php?dappName=$dapp_name&transformer=$dapp_transformer);

# read fields to ask from the dapper 
FIELDS: while (<F_FIELDS>) {
    my($field) = $_; 
    chomp($field);
    print ":: Adding field to URL --> $field \n";
    $dapp_url .= "&extraArg_fields[]=$field";
}

close (F_FIELDS);


print ":: Using dapp --> $dapp_url\n";
print ":: Reading URL to apply Dapp from --> $urls_file\n";
LINE: while (<F_URLS>) {
# read html file line by line

    my $start = time();
    my $end = time();
    my($url) = $_; 
    chomp($url);

    my $output_file = "$output_dir/$url.csv";

    if ( -s $output_file ) {
       print "$output_file SKIPPED. Already processed\n";
       $end = time();
       printf("Elapsed Time --> %.2f\n", $end - $start);
       next LINE;
    }

    my $final_url = "$dapp_url&applyToUrl=$url";
     
    print ":: Getting --> $final_url\n";
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
       open (F_CSV, ">", $output_file) or die "Failed to write to file $output_file : $!";
       print F_CSV $res->content;
       print "$output_file DONE\n";
       close (F_CSV);
     }
     else {
       open (F_CSV, ">", $output_file) or die "Failed to write to file $output_file : $!";
       print "Error: " . $res->status_line . "\n";
       print F_CSV "Error: " . $res->status_line . "\n";
       print "$output_file DONE";
       close (F_CSV);
     } 
     print ":: Sleeping for 3 seconds to respect Dapper SLA... \n";
     sleep(3);
     $end = time();
     printf("Elapsed Time --> %.2f\n", $end - $start);
}
close (F_PARAM);
