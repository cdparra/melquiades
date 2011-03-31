LOAD DATA LOCAL INFILE '~/Documents/Research/Voting/experiment/french-contests/dataset/rankings/ALL-ADMISSIBILITE.csv'
    INTO TABLE rankings
    CHARACTER SET utf8
    FIELDS
        TERMINATED BY ','
    IGNORE 1 LINES
    (phase,section,competition,grade,ranking_code,fullname,list,rank);
   





