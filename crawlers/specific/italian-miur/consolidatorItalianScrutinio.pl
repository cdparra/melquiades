#!/usr/bin/perl
# csv_from_table.pl
use strict;
use File::Basename;
use LWP::Simple;

my $datadir = "/Users/cristhian/Documents/Research/Voting/dataset/italian-escrutinio/csv";
my $output = "/Users/cristhian/Documents/Research/Voting/dataset/italian-escrutinio/csv/all.csvx";
my $f;

open (F_OUT, "+>", $output)  or  die "Failed to read file $output : $!";


# corresponds to a file with the votes in new lines
# parse this type of line: 
#    5,SIMONETTI,Maria Stella,Univ. PERUGIA
#    1 --> this is the vote
my $truncated = 0;

# Iterates through the directory picking out all the .MP4 files
foreach $f (<$datadir/*.csv>) {
    my ($name,$path,$suffix) = fileparse($f);

    my ($justname,$ext) = split(/\./,$name);
    my ($session, $sector) = split("-",$justname);

    open (F_INPUT, "<", $f)  or  die "Failed to read file $f : #!";
 
    my $final_line = "";
    my $last_votes;
    while (<F_INPUT>) {
        # read file line by line

        my($line) = $_; 
        chomp($line);
        
        my ($check_result,$rest) = split(":",$line);       

        if ($check_result eq "No Results") {
            #print F_OUT "$session,$sector,,,,,\n"; 
            print "$session,$sector,$check_result,,,,,,\n"; 
        } elsif ($check_result eq "The servers are overloaded") {
            #print F_OUT "$session,$sector,,,,,\n"; 
            print "$session,$sector,$check_result,,,,,,\n"; 
        } else {
            my $skip = 0; 
            if ($truncated) { # this line is the vote, add it ot the last line
                my @newline = split(/,/, $line); 
                if (@newline > 1) {
                    #print F_OUT "$final_line\n"; 
                    print "$final_line,$last_votes\n"; 
                } else { 
                    $final_line .= ",$line";
                    #print F_OUT "$final_line\n"; 
                    print "$final_line\n"; 
                    $skip = 1;
                }
                $truncated = 0; 
            } 

            if (not $skip) { 
                 my @test = split(/,/, $line); 
                 my $size = @test;
                 
                 my $num = $test[0]; 
                 my $last = $test[1]; 
                 my $first = $test[2];
                 my $faculty = $test[3];
                 my $sector_desc = $test[4];
                 my $sector_code = $test[5];
                 my $position = $test[6];
                 my $votes = $test[7];
         
                 if ($size < 8 ) { $votes = $test[$size - 1]; }
                   
                 $last_votes= $votes;

                 if ($size == 8) {
                     $truncated = 0; 
                 } else {
                     if ( ($sector_desc eq "affine") or ($sector_desc eq "titolare") ) {
                         $position = $sector_desc;
                         $sector_desc = ""; 
                     }
                     
                     if ($sector_code eq $votes) { $sector_code = ""; }
                     $truncated = 1; 
                 }

                 $final_line = "$session,$sector,$last,$first,$faculty,$sector_desc,$sector_code,$position"; 
 
                 if (not $truncated) { # delay writing in output until next iteration 
                     #print F_OUT "$final_line\n"; 
                     print "$final_line,$votes\n"; 
                 } 
            } else {
                $skip = 0;
            }
        }
    }

    # se repite para la ultima linea
    if ($truncated) { # this line is the vote, add it ot the last line
        #print F_OUT "$final_line\n"; 
        print "$final_line,$last_votes\n"; 
        $truncated = 0; 
    }
    close(F_INPUT);
}
close (F_OUT);

