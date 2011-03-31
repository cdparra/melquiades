LOAD DATA LOCAL INFILE '/Users/cristhian/Documents/Research/Voting/dataset/italian-escrutinio/csv/bandos_all_idonei.csv'
    INTO TABLE bandos_tmp
    CHARACTER SET utf8
    FIELDS
        TERMINATED BY ','
        enclosed by '"'
    IGNORE 1 LINES
    (call_id,university,role,faculty,sector_code,sector_desc);
   







