DECLARE @inq_num INT
DECLARE @var1 VARCHAR(50)
DECLARE @var2 VARCHAR(50)
DECLARE @var3 VARCHAR(50)

SET @inq_num = 17777
SET @var1 = (
		SELECT prnt_fn_id
		FROM dw_function_item
		WHERE inq_num = @inq_num
		)
SET @var2 = (
		SELECT prnt_fn_id
		FROM dw_function_item
		WHERE fn_id = @var1
		)
SET @var3 = (
		SELECT prnt_fn_id
		FROM dw_function_item
		WHERE fn_id = @var2
		)

SELECT @VAR1
	,@VAR2
	,@VAR3

SELECT fn_nme
	,*
FROM dw_function_item
WHERE inq_num = @inq_num
	or fn_id = @VAR1
	or fn_id = @VAR2
	OR fn_id = @VAR3
	--OR prnt_fn_id IS NULL
	ORDER BY FN_LVL_NUM

	select fn_nme from dw_function_item

	where prnt_fn_id = @VAR1
	or prnt_fn_id= @VAR2
	 or prnt_fn_id= @VAR3