--http://www.sqlservercentral.com/articles/Reporting+Services+(SSRS)/152814/

--my shop renames the ReportServer database for some reason, removed explicit three part references to Reportserver.dbo.Catalog to two part name
BEGIN TRY
    DROP TABLE #ReportList
END TRY
BEGIN CATCH
END CATCH

BEGIN TRY
    DROP TABLE #ReportParameters
END TRY
BEGIN CATCH
END CATCH

BEGIN TRY
    DROP TABLE #ReportFields
END TRY
BEGIN CATCH
END CATCH

SELECT 
    Name
    ,Path
INTO #ReportList
FROM dbo.Catalog 
WHERE Content IS NOT NULL
ORDER BY Name;

 SELECT DISTINCT Name as ReportName
    ,ParameterName = Paravalue.value('Name[1]', 'VARCHAR(250)') 
     ,ParameterType = Paravalue.value('Type[1]', 'VARCHAR(250)') 
     ,ISNullable = Paravalue.value('Nullable[1]', 'VARCHAR(250)') 
     ,ISAllowBlank = Paravalue.value('AllowBlank[1]', 'VARCHAR(250)') 
     ,ISMultiValue = Paravalue.value('MultiValue[1]', 'VARCHAR(250)') 
     ,ISUsedInQuery = Paravalue.value('UsedInQuery[1]', 'VARCHAR(250)') 
     ,ParameterPrompt = Paravalue.value('Prompt[1]', 'VARCHAR(250)') 
     ,DynamicPrompt = Paravalue.value('DynamicPrompt[1]', 'VARCHAR(250)') 
     ,PromptUser = Paravalue.value('PromptUser[1]', 'VARCHAR(250)') 
     ,State = Paravalue.value('State[1]', 'VARCHAR(250)') 
INTO #ReportParameters
 FROM (  
        SELECT top 1000 C.Name,CONVERT(XML,C.Parameter) AS ParameterXML
        FROM  dbo.Catalog C
        WHERE  C.Content is not null
        AND Name NOT LIKE '%SUB%'
        AND  C.Type  = 2
      ) a
--changed to outer apply to guarantee data results
OUTER APPLY ParameterXML.nodes('//Parameters/Parameter') p ( Paravalue )
ORDER BY ReportName,ParameterName;

WITH XMLNAMESPACES ( DEFAULT 'http://schemas.microsoft.com/sqlserver/reporting/2008/01/reportdefinition', 'http://schemas.microsoft.com/SQLServer/reporting/reportdesigner' AS rd )
SELECT DISTINCT ReportName        = name
  ,DataSetName        = x.value('(@Name)[1]', 'VARCHAR(250)') 
      ,DataSourceName    = x.value('(Query/DataSourceName)[1]','VARCHAR(250)')
      ,CommandText        = x.value('(Query/CommandText)[1]','VARCHAR(250)')
      ,Fields            = df.value('(@Name)[1]','VARCHAR(250)')
      ,DataField        = df.value('(DataField)[1]','VARCHAR(250)')
      ,DataType        = df.value('(rd:TypeName)[1]','VARCHAR(250)')
      ,ConnectionString = x.value('(ConnectionProperties/ConnectString)[1]','VARCHAR(250)')
INTO #ReportFields
 FROM ( SELECT C.Name,CONVERT(XML,CONVERT(VARBINARY(MAX),C.Content)) AS reportXML
  FROM dbo.Catalog C
   WHERE C.Content is not null
  AND C.Type = 2
      ) a
  --changed to outer apply to guarantee data results
 OUTER APPLY reportXML.nodes('/Report/DataSets/DataSet') r ( x )
 OUTER APPLY x.nodes('Fields/Field') f(df) 
ORDER BY name 

SELECT 
    a.Name AS ReportName
    ,a.Path
    ,SUBSTRING(a.Path,1,LEN(a.Path)-LEN(a.Name)) AS ReportFolder
    ,'http://ReportCenter/Reports/Pages/Report.aspx?ItemPath='+REPLACE(SUBSTRING(a.Path,1,LEN(a.Path)-LEN(a.Name)),'/','%2f')+REPLACE(a.Name,' ','+') AS ReportLink
  --References to specific data removed, defaulted to getdate by Lowell
    ,getdate() AS AcctRecMinTransDate 
    ,getdate() AS AcctRecMaxTransDate
    ,'User Input' AS FieldType
    ,b.ParameterPrompt AS DataSetOrPromptName
    ,b.ParameterName AS FieldOrParameterName
FROM #ReportList a
LEFT OUTER JOIN #ReportParameters b ON a.Name = b.ReportName
--Commented out  By Lowell, so that all repoorts, even without Parameters, appear in the report.
--WHERE b.ParameterName IS NOT NULL
UNION
SELECT 
    a.Name AS ReportName
    ,a.Path
    ,SUBSTRING(a.Path,1,LEN(a.Path)-LEN(a.Name)) AS ReportFolder
    ,'http://ReportCenter/Reports/Pages/Report.aspx?ItemPath='+REPLACE(SUBSTRING(a.Path,1,LEN(a.Path)-LEN(a.Name)),'/','%2f')+REPLACE(a.Name,' ','+') AS ReportLink
    ,getdate() AS AcctRecMinTransDate 
    ,getdate() AS AcctRecMaxTransDate
    ,'Data Point' AS FieldType
    ,b.DataSetName AS DataSetOrPromptName
    ,b.Fields AS FieldOrParameterName
FROM #ReportList a
LEFT OUTER JOIN #ReportFields b ON a.Name = b.ReportName
--Commented out  By Lowell, so that all repoorts, evne without Parameters, appear in the report.
--WHERE b.Fields IS NOT NULL
ORDER BY Name,Path,FieldType,ParameterPrompt,ParameterName
