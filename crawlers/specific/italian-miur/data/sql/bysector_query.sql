SELECT count(*) as total_pairs,
       sum(h_success)/count(*) as h_success,
       sum(cit_success)/count(*) as cit_sucess,
       sum(citedpub_success)/count(*) as citedpub_success,
       sum(h_neutral)/count(*) as h_neutral,
       sum(cit_neutral)/count(*) as cit_neutral,
       sum(citedpub_neutral)/count(*) as citedpub_neutral,
       sum(h_failure)/count(*) as h_failure,
       sum(cit_failure)/count(*) as cit_failure,
       sum(citedpub_failure)/count(*) as citedpub_failure
%       ,sector_desc
FROM call_pairs_metrics c
where candidate1_result <> candidate2_result
and candidate1_hindex>0 and candidate2_hindex>0 
% group by sector_desc
order by count(*) desc
