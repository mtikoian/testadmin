
Create Function dbo.fn_VerifySQLInjection (@TSQL varchar(max))
Returns bit
AS
BEGIN
    DECLARE @IsSQLInjectionSuspected bit;
    DECLARE @pos int;
    set @pos = 0;
    select @pos += charIndex (lower(word) , lower(@TSQL))
    from ReservedWords
    set @IsSQLInjectionSuspected = if ((@pos > 0) ,1 ,0)
    RETURN @IsSQLInjectionSuspected
END
GO
