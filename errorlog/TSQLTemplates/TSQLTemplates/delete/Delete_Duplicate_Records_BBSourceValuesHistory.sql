USE BloomBerg_STG;
GO
/*To delete duplicate records from BBSourceValuesHistory*/



;WITH cte
AS (
	SELECT UniqueKey
		,Source_ID
		,ROW_NUMBER() OVER (
			PARTITION BY UniqueKey ORDER BY Source_Id DESC
			) AS row_num
	FROM BloomBerg.BBSourceValuesHistory
	)
DELETE
FROM cte
where row_num >1 