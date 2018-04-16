Use AdventureWorksDW2008R2
go

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- To view the dependent tables in tree structure 
------------------------------------------------------------------------------------------------------------------------------------------------------------

exec GetForeignKeyRelations @schemaname='Sales'
						   ,@tablename ='Customer'
						  

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- To view the dependent tables in tree structure and generate the Delete scripts for the where clause specified
------------------------------------------------------------------------------------------------------------------------------------------------------------

exec GetForeignKeyRelations @schemaname='Sales'
						   ,@tablename ='Customer'
						   ,@whereclause = 'sales.Customer.CustomerID = 29825'
						   ,@GenerateSelectScripts = 1


------------------------------------------------------------------------------------------------------------------------------------------------------------
-- To view the dependent tables in tree structure and generate the Select scripts for the where clause specified
------------------------------------------------------------------------------------------------------------------------------------------------------------

exec GetForeignKeyRelations  @tablename ='BusinessEntity'
							,@schemaname='Person'
                            ,@whereclause='Person.BusinessEntity.BusinessEntityID=10' 
						    ,@GenerateDeleteScripts = 1



------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Sample for multiple condition in WHERE clause
------------------------------------------------------------------------------------------------------------------------------------------------------------

exec GetForeignKeyRelations  @tablename ='BusinessEntity'
							,@schemaname='Person'
                            ,@whereclause='Person.BusinessEntity.BusinessEntityID=10 AND Person.BusinessEntity.ModifiedDate > ''01-Jan-2011''' 
						    ,@GenerateDeleteScripts = 1