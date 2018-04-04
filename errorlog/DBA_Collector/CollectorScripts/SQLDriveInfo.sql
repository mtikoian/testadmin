SET NOCOUNT ON 

DECLARE @ReturnCode			int
		,@FSOObjectToken	int
		,@Drive				char(1)
		,@OutputDrive		int
		,@TotalSize			varchar(20)
		,@Source			varchar(255)
		,@Description		varchar(255)
		,@Notes				varchar(500)
		,@MB				bigint

SET @MB = 1048576

CREATE TABLE #DriveInfo
( 
	DI_Drive		char(1),
	DI_TotalSpace 	int,
	DI_FreeSpace	int,
	DI_Notes		varchar(500),
)

INSERT INTO #DriveInfo
(
	DI_Drive,
	DI_FreeSpace
)
EXECUTE master.dbo.xp_fixeddrives

IF LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), 1) = '8' OR
		EXISTS(SELECT * FROM sysconfigures WHERE comment = 'Enable or disable Ole Automation Procedures' AND value = 1)
	BEGIN
		EXECUTE @ReturnCode = sp_OACreate  'Scripting.FileSystemObject', @FSOObjectToken OUT

		IF @ReturnCode <> 0
			EXECUTE sp_OAGetErrorInfo @FSOObjectToken
		ELSE
			BEGIN
				DECLARE CURSOR_DRIVES CURSOR FAST_FORWARD
				FOR
					SELECT		DI_Drive
					FROM		#DriveInfo
					ORDER BY	1
			
				OPEN CURSOR_DRIVES
				
				FETCH NEXT FROM CURSOR_DRIVES
				INTO @Drive

				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @Notes = ''

					EXECUTE @ReturnCode = sp_OAMethod @FSOObjectToken, 'GetDrive', @OutputDrive OUT, @Drive

					IF @ReturnCode <> 0
						BEGIN
							EXECUTE sp_OAGetErrorInfo @FSOObjectToken, @Source OUT, @Description OUT
			
							SET @Notes = @Notes + 'Error on GetDrive (' + @Drive + ').  Source:  ' + ISNULL(@Source, '') + ' - Description:  ' + ISNULL(@Description, '')
						END
					ELSE
						BEGIN
							EXECUTE @ReturnCode = sp_OAGetProperty @OutputDrive, 'TotalSize', @TotalSize OUT

							IF @ReturnCode <> 0
								BEGIN
									EXECUTE sp_OAGetErrorInfo @FSOObjectToken, @Source OUT, @Description OUT
					
									SET @Notes = @Notes + 'Error on TotalSize (' + @Drive + ').  Source:  ' + ISNULL(@Source, '') + ' - Description:  ' + ISNULL(@Description, '')
								END

						END

					UPDATE	#DriveInfo
					   SET	DI_TotalSpace = @TotalSize/@MB
							,DI_Notes = @Notes			
					WHERE	DI_Drive = @Drive

					FETCH NEXT FROM CURSOR_DRIVES
					INTO @Drive
				END

				CLOSE CURSOR_DRIVES
				DEALLOCATE CURSOR_DRIVES

			END

		EXECUTE @ReturnCode = sp_OADestroy @FSOObjectToken
	END
ELSE
	UPDATE		#DriveInfo
	   SET		DI_Notes = 'ole automation procedures is not enabled'
	
SELECT		DI_Drive + '<1>' + 
				ISNULL(CAST(DI_TotalSpace AS varchar(15)), '') + '<2>' +
				CAST(DI_FreeSpace AS varchar(15)) + '<3>' + 
				ISNULL(DI_Notes, '')
FROM		#DriveInfo

DROP TABLE #DriveInfo
