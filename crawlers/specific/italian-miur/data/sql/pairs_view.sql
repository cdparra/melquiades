DROP VIEW IF EXISTS `call_pairs_metrics`;
CREATE OR REPLACE VIEW `call_pairs_metrics` AS 
SELECT  b1.call_id,b1.role,b1.university,b1.faculty,b1.sector_code,b1.sector_desc
        b1.fullname as candidate1,b2.fullname as candidate2,
        b1.h_index as candidate1_hindex,b2.h_index as candidate2_hindex,
        b1.citations_count as candidate1_citations,b2.citations_count as candidate2_citations,
        b1.cited_pub as candidate1_citedpub,b2.cited_pub as candidate2_citedpub,
        , abs(b1.h_index - b2.h_index) as h_index_diff
        , abs(b1.citations_count - b2.citations_count) as citations_count_diff
        , abs(b1.cited_pub - b2.cited_pub) as cited_pub_diff
        , sqrt(abs(power(b1.h_index,2) - power(b2.h_index,2))) as h_index_geom
        , sqrt(abs(power(b1.citations_count,2) - power(b2.citations_count,2))) as citations_count_geom
        , sqrt(abs(power(b1.cited_pub,2) - power(b2.cited_pub,2))) as cited_pub_geom

FROM bando_idonei_metric b1, bando_idonei_metric b2
WHERE b1.call_id = b2.call_id and b1.fullname<>b2.fullname
      and b1.winner = 1 ;