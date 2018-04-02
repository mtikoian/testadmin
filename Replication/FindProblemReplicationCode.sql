USE [distribution]
GO
DECLARE @seqNO AS VARBINARY(16)
DECLARE @seqNOChar AS NCHAR(22)
SET @seqNOChar = '0x00000056000000A80008' --get this from error mesage in Repl monitor
SET @seqNO = CAST(@seqNOChar AS varbinary(16))
DECLARE @ArtID AS INT, @ComID AS INT, @PubID AS INT


--SELECT *
--FROM   Msrepl_commands (nolock)
--WHERE  command_id = 1
--       AND xact_seqno = @seqNO

SELECT
	 @ArtID = [article_id]
	, @ComID = [command_id]
	, @PubID = [publisher_database_id]
FROM   Msrepl_commands (nolock)
WHERE  command_id = 1
       AND xact_seqno = @seqNO


EXEC Sp_browsereplcmds @article_id = @ArtID
, @command_id = @ComID
, @xact_seqno_start = @seqNOChar
, @xact_seqno_end = @seqNOChar
, @publisher_database_id = @PubID 

