USE tempdb;
GO

CREATE TABLE MyTab (Id1 int, Id2 varchar(1));
GO

INSERT MyTab
SELECT 1, 'A' UNION ALL
SELECT 1, 'B' UNION ALL
SELECT 1, 'B' UNION ALL
SELECT 1, 'C' UNION ALL
SELECT 1, 'D' UNION ALL
SELECT 2, 'A' UNION ALL
SELECT 2, 'A' UNION ALL
SELECT 2, 'A' UNION ALL
SELECT 2, 'B' UNION ALL
SELECT 2, 'C'
GO

SELECT * FROM MyTab;
GO

ALTER TABLE MyTab
ADD rowguid uniqueidentifier NOT NULL
CONSTRAINT DF__MyTab__rowguid DEFAULT (NEWID());
GO

SELECT * FROM MyTab;
GO

SELECT t.* 
FROM cc_rel t -- your table name
JOIN (

select cc_originatorCompany_uid
, cc_targetCompany_uid, cc_dealernumber ,max(cast(cc_uid as nvarchar(100))) as maxval ,count(1)  as cnt from cc_rel 
where cc_createdby = 'InitialLoadwnow'
group by cc_originatorCompany_uid, cc_targetCompany_uid,cc_dealernumber
having count(1)>1
) t1
 ON t.cc_originatorCompany_uid=t1.cc_originatorCompany_uid -- add all must-be-unique columns 
 AND t.cc_targetCompany_uid=t1.cc_targetCompany_uid
 and t.cc_dealernumber = t1.cc_dealernumber
WHERE t.cc_uid <> t1.maxval
and t.cc_createdby = 'InitialLoadWnow'
GO


