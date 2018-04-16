ALTER TABLE #IVWTEMP ADD PRIMARY KEY CLUSTERED (IVWTEMP_ID, GRP_FUND_ID, FUND_ID);  


ALTER TABLE aga.Account_Group ADD CONSTRAINT Account_Group_PK PRIMARY KEY CLUSTERED (
	Account_Group_Num
	,CONSTRAINT [ActGrpActs_PK] PRIMARY KEY NONCLUSTERED ([Account_Group_Num] ASC,[Account_ID] ASC)
	,CONSTRAINT Account_Recipient_PK PRIMARY KEY CLUSTERED (Account_ID,Interested_Party_ID) ,
		CONSTRAINT Table_Reference_PK PRIMARY KEY CLUSTERED (db_nm,object_nm)
	,CONSTRAINT Table_Reference_AK UNIQUE (synonym_nm)
	--select * from sys.indexes where object_id = object_id('aga.Account_Group') and name = 'Account_Group_IX01'
	CREATE INDEX Account_Group_IX01 ON aga.Account_Group (Account_Group_Name)
	--select * from sys.indexes where object_id = object_id('aga.Audit_Trail') and name = 'Audit_Trail_IX01'
	CREATE UNIQUE INDEX Audit_Trail_IX01 ON aga.Audit_Trail (
	Audit_Timestamp
	,Audit_Trail_ID
	) ALTER TABLE aga.Account_Group ADD CONSTRAINT FK_Account_Group_ref_Group_Type 
	FOREIGN KEY (Group_Type_Cd) REFERENCES aga.Group_Type (Group_Type_Cd);
	CONSTRAINT FK__SEI_EXECUTION__Execution_Status_ID__SEI_EXECUTION_STATUS 
	FOREIGN KEY (Execution_Status_ID) REFERENCES dbo.SEI_EXECUTION_STATUS(Execution_Status_ID)
	,CONSTRAINT UQ__SEI_EXECUTION_STATUS__Execution_Status_Nm 
	UNIQUE NONCLUSTERED (Execution_Status_Nm);
	CONSTRAINT DF__SEI_PARAMETER__Active_Fl DEFAULT 1 FOR Active_Fl;
	
	--A table much have both pk and clustered index
	
	CREATE CLUSTERED INDEX IDX_Tax_Lot__Batch_Id_As_Of_Dt_Acct_Id ON dbo.Tax_Lot (
	 Batch_Id
	,As_Of_Dt
	,Acct_Id
	) 
--- Clusterd index will allow dups until unless unqiue is specified while creating index
--Include columns to improve performance
CREATE INDEX IDX_INVESTOR_ALLOCATION_DETAIL_ACCT_ID_PROCESSDATE ON dbo.INVESTOR_ALLOCATION_DETAIL
(
	ACCT_ID ASC,
	PROCESS_DATE ASC
)
INCLUDE ( REF_ACCT_ID,
GL_CODE,
BALANCE,
ACCOUNT_CODE_NAME) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF,  ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


--Table Variables

---- check indexes in temp db
SELECT t.name, i.name, i.index_id
FROM tempdb.sys.tables t
INNER JOIN tempdb.sys.indexes i ON t.object_id = i.object_id
SELECT * FROM TEMPDB.SYS.indexes A INNER JOIN TEMPDB.SYS.tables B
            ON A.object_id=B.object_id ORDER BY create_date DESC


DECLARE @Test TABLE (
ID INT NOT NULL PRIMARY KEY,
IndexableColumn1 INT,
IndexableColumn2 DATETIME,
IndexableColumn3 VARCHAR(10),
UNIQUE (IndexableColumn1,ID),
UNIQUE (IndexableColumn2,ID),
UNIQUE (IndexableColumn3, IndexableColumn2, ID)
)
DECLARE @PCOMP_TEMP TABLE  
 ( 
	PCOMP_TEMP_ID		INT IDENTITY (1,1) PRIMARY KEY NONCLUSTERED,     
	part_acct_id		VARCHAR(15),
	ACCT_ID				VARCHAR(15)
	UNIQUE CLUSTERED (PCOMP_TEMP_ID,part_acct_id,ACCT_ID)
 )

--Computed column
ALTER TABLE dbo.Investor_Performance_test
ADD test as (DATEADD(DAY, DATEDIFF(DAY, 0, Asofdate), '23:59:59'))

--Temp tables


ALTER TABLE [dbo].[authors]  WITH CHECK ADD CHECK  (([au_id] like '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'))
GO

ALTER TABLE [dbo].[authors]  WITH CHECK ADD CHECK  (([zip] like '[0-9][0-9][0-9][0-9][0-9]'))
GO

ALTER TABLE [dbo].[authors] ADD  DEFAULT ('UNKNOWN') FOR [phone]
GO
