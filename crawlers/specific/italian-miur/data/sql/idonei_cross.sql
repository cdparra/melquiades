SELECT it.call_id,it.fullname
  FROM idonei_tmp_tmp it
  WHERE  
    ( select count(i.fullname) from idonei_tmp i
      where i.fullname = it.fullname) = 0