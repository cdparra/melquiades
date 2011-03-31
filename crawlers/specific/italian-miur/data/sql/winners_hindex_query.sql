SELECT * FROM bando_idonei_metric b1, bando_idonei_metric b2
WHERE b1.call_id = b2.call_id and b1.fullname<>b2.fullname 
      and b1.winner = 1 and b2.winner=0
      and b1.h_index < b2.h_index
      
      
      
SELECT 
 count(*),
 sum(hsuccess)/count(hsuccess) as Hsuccess,
 sum(hneutral)/count(hneutral) as Hneutral,
 sum(hfailure)/count(hfailure) as Hfailure,


 sum(citsuccess)/count(citsuccess) as Citsuccess,
 sum(citneutral)/count(citneutral) as Citneutral,
 sum(citfailure)/count(citfailure) as Citfailure,

 sum(pubsuccess)/count(pubsuccess) as Pubsuccess,
 sum(pubneutral)/count(pubneutral) as Pubneutral,
 sum(pubfailure)/count(pubfailure) as Pubfailure
 
FROM call_pairs_metrics c

where candidate1_hindex>0 and candidate2_hindex>0