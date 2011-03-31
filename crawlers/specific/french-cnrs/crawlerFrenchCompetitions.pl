#!/usr/bin/perl
# csv_from_table.pl
use strict;
use LWP::Simple;

my $grades_file = shift;
open (F_GRADE, "<", $grades_file)  or  die "Failed to read file $grades_file : $!";

my $dapp_url = "http://open.dapper.net/transform.php?dappName=FrenchResearchersCompetitionscodes&"
               . "transformer=CSV&extraArg_fields[]=competition&applyToUrl=";

# URL parts encoded
my $url_base = "http%3A%2F%2Fintersection.dsi.cnrs.fr%2Fintersection%2Fresultats-cc-en.do%3Fcampagne%3D34";

my $param_section = "%26section%3D"; 
my $param_grade = "%26grade%3D"; 

print "Calling dapp: $dapp_url\n";
print "Applying on Base URL: $url_base\n";


print "Reading parameters for URL in $grades_file\n";
my $skip = 1;
GRADE: while (<F_GRADE>) {

    my($line) = $_; 
    chomp($line);
    
    # skip first line
    if ($skip == 1) {
        $skip++;
        next GRADE;
    }

    my @code = split(/\|/, $line);

    my $grade = $code[0];
    my $grade_name = $code[1];
    my $grade_desc = $code[2];

    print "LINE: $grade | $grade_name | $grade_desc\n";
    print "LINE: $line\n";
    LINE: for (my $count = 1; $count <= 45; $count++) {
        my $start = time();
        my $end = time();
 
        my $section = "$count";
        if ($count < 10) {
            $section = "0" . "$count";
        }

        my $csv_file = "../dataset/competitions/$section-$grade.csv";

        if ( -s $csv_file ) {
            print "$csv_file SKIPPED. Already processed\n";
            $end = time();
            printf("Elapsed Time --> %.2f\n", $end - $start);
            next LINE;
        }

        my $final_url = "$dapp_url$url_base$param_grade$grade$param_section$section";
        print "Getting --> Section: $section | Grade: $grade\n";
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
close (F_GRADE);
