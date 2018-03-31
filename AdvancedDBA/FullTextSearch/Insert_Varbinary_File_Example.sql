--Insert file into varbinary column:
DECLARE @sql nvarchar(1000), @file VARBINARY(MAX), @filename varchar(255), @extension varchar(5), @fullyqualifiedname nvarchar(1000);

SELECT @filename = 'The_8051_Microcontroller_and_Embedded_Systems_Using_Assembly_and_C-2nd-ed', @extension = '.pdf';

SELECT @fullyqualifiedname = N'C:\Dev\' + @filename + @extension;

SELECT @sql =
'INSERT INTO [dbo].[Books] ([Name],[Author],[ContentType], Contents )
SELECT ''' + @filename + ''' AS Name, ''Kris Hokanson'' AS Author, ''' + @extension + ''' AS ContentType, *
FROM OPENROWSET(BULK ''' + @fullyqualifiedname + ''', SINGLE_BLOB) AS Document;'

EXEC(@SQL);

SELECT Book_ID, Name, Author, ContentType FROM [dbo].[Books]