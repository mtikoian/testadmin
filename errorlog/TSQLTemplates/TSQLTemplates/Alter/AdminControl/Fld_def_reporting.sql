--Find duplicates in fld_in_qry
SELECT a.internl_nme
	,a.ENTITY_NUM
	,a.fld_num
	,a.INQ_NUM
	,a.QRY_NUM
	,a.SEQ_NUM
FROM (
	SELECT internl_nme
		,ENTITY_NUM
		,fld_num
		,INQ_NUM
		,QRY_NUM
		,SEQ_NUM
		,ROW_NUMBER() OVER (
			PARTITION BY internl_nme
			,INQ_NUM ORDER BY internl_nme
				,INQ_NUM
			) AS RowNumber
	FROM dbo.fld_in_qry
	) tbl
JOIN fld_in_qry a ON a.ENTITY_NUM = tbl.ENTITY_NUM
	AND a.fld_num = tbl.fld_num
	AND a.INQ_NUM = tbl.INQ_NUM
	AND a.QRY_NUM = tbl.QRY_NUM
	AND a.SEQ_NUM = tbl.SEQ_NUM
	AND tbl.RowNumber > 1

--Find duplicates in fld_def
SELECT a.internl_name
	,a.ENTITY_NUM
	,a.fld_num
FROM (
	SELECT internl_name
		,ENTITY_NUM
		,fld_num
		,ROW_NUMBER() OVER (
			PARTITION BY internl_name
			,ENTITY_NUM ORDER BY internl_name
				,ENTITY_NUM
			) AS RowNumber
	FROM fld_def
	) tbl
JOIN fld_def a ON a.ENTITY_NUM = tbl.ENTITY_NUM
	AND a.fld_num = tbl.fld_num
	AND tbl.RowNumber > 1
/**Report MetaData*/
DECLARE @inq_num INT
DECLARE @Entity_num INT

SET @inq_num = 15074
SET @Entity_num = (
		SELECT DISTINCT entity_num
		FROM fld_in_qry
		WHERE inq_num = @inq_num
		)

SELECT *
FROM qry_def
WHERE inq_num = @inq_num

SELECT *
FROM fld_in_qry
WHERE inq_num = @inq_num

SELECT *
FROM fld_def
WHERE @Entity_num = Entity_num
