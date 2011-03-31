SELECT i.call_id,i.fullname,i.winner FROM idonei_tmp i
where i.call_id in (
  select call_id from idonei_tmp
  group by call_id having count(fullname)>1 and sum(winner)>0
)
order by i.call_id,i.winner desc 