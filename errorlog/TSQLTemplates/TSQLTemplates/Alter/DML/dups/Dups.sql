  SELECT t.ctn_no
    FROM YOUR_TABLE t
GROUP BY t.ctn_no
  HAVING COUNT(t.ctn_no) > 1
--...will show you the ctn_no value(s) that have duplicates in your table. Adding criteria to the WHERE will allow you to further tune what duplicates there are:

  SELECT t.ctn_no
    FROM YOUR_TABLE t
   WHERE t.s_ind = 'Y'
GROUP BY t.ctn_no
  HAVING COUNT(t.ctn_no) > 1
If you want to see the other column values associated with the duplicate, you'll want to use a self join:

SELECT x.*
  FROM YOUR_TABLE x
  JOIN (SELECT t.ctn_no
          FROM YOUR_TABLE t
      GROUP BY t.ctn_no
        HAVING COUNT(t.ctn_no) > 1) y ON y.ctn_no = x.ctn_no