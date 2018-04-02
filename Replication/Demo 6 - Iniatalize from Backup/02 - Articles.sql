use AdventureWorks2014;
go

sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'HumanResources.Department',
    @source_owner = 'HumanResources',
    @source_object = 'Department',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'Department',
    @destination_owner = 'HumanResources',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL HumanResources.zRepl_ins_Department',
    @del_cmd = 'CALL HumanResources.zRepl_del_Department',
    @upd_cmd = 'MCALL HumanResources.zRepl_upd_Department';
go    

sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'HumanResources.Employee',
    @source_owner = 'HumanResources',
    @source_object = 'Employee',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000D3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'Employee',
    @destination_owner = 'HumanResources',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL HumanResources.zRepl_ins_Employee',
    @del_cmd = 'CALL HumanResources.zRepl_del_Employee',
    @upd_cmd = 'MCALL HumanResources.zRepl_upd_Employee';
go


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'HumanResources.EmployeeDepartmentHistory',
    @source_owner = 'HumanResources',
    @source_object = 'EmployeeDepartmentHistory',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'EmployeeDepartmentHistory',
    @destination_owner = 'HumanResources',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL HumanResources.zRepl_ins_EmployeeDepartmentHistory',
    @del_cmd = 'CALL HumanResources.zRepl_del_EmployeeDepartmentHistory',
    @upd_cmd = 'MCALL HumanResources.zRepl_upd_EmployeeDepartmentHistory';
go
 

sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'HumanResources.EmployeePayHistory',
    @source_owner = 'HumanResources',
    @source_object = 'EmployeePayHistory',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'EmployeePayHistory',
    @destination_owner = 'HumanResources',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL HumanResources.zRepl_ins_EmployeePayHistory',
    @del_cmd = 'CALL HumanResources.zRepl_del_EmployeePayHistory',
    @upd_cmd = 'MCALL HumanResources.zRepl_upd_EmployeePayHistory';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'HumanResources.JobCandidate',
    @source_owner = 'HumanResources',
    @source_object = 'JobCandidate',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'JobCandidate',
    @destination_owner = 'HumanResources',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL HumanResources.zRepl_ins_JobCandidate',
    @del_cmd = 'CALL HumanResources.zRepl_del_JobCandidate',
    @upd_cmd = 'MCALL HumanResources.zRepl_upd_JobCandidate';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'HumanResources.Shift',
    @source_owner = 'HumanResources',
    @source_object = 'Shift',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'Shift',
    @destination_owner = 'HumanResources',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL HumanResources.zRepl_ins_Shift',
    @del_cmd = 'CALL HumanResources.zRepl_del_Shift',
    @upd_cmd = 'MCALL HumanResources.zRepl_upd_Shift';
go
 

sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Person.Address',
    @source_owner = 'Person',
    @source_object = 'Address',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x0000010008035093,         -- http://social.msdn.microsoft.com/Forums/en/sqlreplication/thread/69dde455-1bee-485d-9a0d-2cd6d0955597
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'Address',
    @destination_owner = 'Person',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Person.zRepl_ins_Address',
    @del_cmd = 'CALL Person.zRepl_del_Address',
    @upd_cmd = 'MCALL Person.zRepl_upd_Address';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Person.AddressType',
    @source_owner = 'Person',
    @source_object = 'AddressType',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'AddressType',
    @destination_owner = 'Person',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Person.zRepl_ins_AddressType',
    @del_cmd = 'CALL Person.zRepl_del_AddressType',
    @upd_cmd = 'MCALL Person.zRepl_upd_AddressType';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Person.BusinessEntity',
    @source_owner = 'Person',
    @source_object = 'BusinessEntity',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'BusinessEntity',
    @destination_owner = 'Person',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Person.zRepl_ins_BusinessEntity',
    @del_cmd = 'CALL Person.zRepl_del_BusinessEntity',
    @upd_cmd = 'MCALL Person.zRepl_upd_BusinessEntity';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Person.BusinessEntityAddress',
    @source_owner = 'Person',
    @source_object = 'BusinessEntityAddress',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'BusinessEntityAddress',
    @destination_owner = 'Person',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Person.zRepl_ins_BusinessEntityAddress',
    @del_cmd = 'CALL Person.zRepl_del_BusinessEntityAddress',
    @upd_cmd = 'MCALL Person.zRepl_upd_BusinessEntityAddress';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Person.BusinessEntityContact',
    @source_owner = 'Person',
    @source_object = 'BusinessEntityContact',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'BusinessEntityContact',
    @destination_owner = 'Person',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Person.zRepl_ins_BusinessEntityContact',
    @del_cmd = 'CALL Person.zRepl_del_BusinessEntityContact',
    @upd_cmd = 'MCALL Person.zRepl_upd_BusinessEntityContact';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Person.ContactType',
    @source_owner = 'Person',
    @source_object = 'ContactType',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'ContactType',
    @destination_owner = 'Person',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Person.zRepl_ins_ContactType',
    @del_cmd = 'CALL Person.zRepl_del_ContactType',
    @upd_cmd = 'MCALL Person.zRepl_upd_ContactType';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Person.CountryRegion',
    @source_owner = 'Person',
    @source_object = 'CountryRegion',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'CountryRegion',
    @destination_owner = 'Person',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Person.zRepl_ins_CountryRegion',
    @del_cmd = 'CALL Person.zRepl_del_CountryRegion',
    @upd_cmd = 'MCALL Person.zRepl_upd_CountryRegion';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Person.EmailAddress',
    @source_owner = 'Person',
    @source_object = 'EmailAddress',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'EmailAddress',
    @destination_owner = 'Person',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Person.zRepl_ins_EmailAddress',
    @del_cmd = 'CALL Person.zRepl_del_EmailAddress',
    @upd_cmd = 'MCALL Person.zRepl_upd_EmailAddress';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Person.Password',
    @source_owner = 'Person',
    @source_object = 'Password',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'Password',
    @destination_owner = 'Person',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Person.zRepl_ins_Password',
    @del_cmd = 'CALL Person.zRepl_del_Password',
    @upd_cmd = 'MCALL Person.zRepl_upd_Password';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Person.Person',
    @source_owner = 'Person',
    @source_object = 'Person',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'Person',
    @destination_owner = 'Person',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Person.zRepl_ins_Person',
    @del_cmd = 'CALL Person.zRepl_del_Person',
    @upd_cmd = 'MCALL Person.zRepl_upd_Person';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Person.PersonPhone',
    @source_owner = 'Person',
    @source_object = 'PersonPhone',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'PersonPhone',
    @destination_owner = 'Person',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Person.zRepl_ins_PersonPhone',
    @del_cmd = 'CALL Person.zRepl_del_PersonPhone',
    @upd_cmd = 'MCALL Person.zRepl_upd_PersonPhone';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Person.PhoneNumberType',
    @source_owner = 'Person',
    @source_object = 'PhoneNumberType',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'PhoneNumberType',
    @destination_owner = 'Person',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Person.zRepl_ins_PhoneNumberType',
    @del_cmd = 'CALL Person.zRepl_del_PhoneNumberType',
    @upd_cmd = 'MCALL Person.zRepl_upd_PhoneNumberType';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Person.StateProvince',
    @source_owner = 'Person',
    @source_object = 'StateProvince',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'StateProvince',
    @destination_owner = 'Person',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Person.zRepl_ins_StateProvince',
    @del_cmd = 'CALL Person.zRepl_del_StateProvince',
    @upd_cmd = 'MCALL Person.zRepl_upd_StateProvince';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.BillOfMaterials',
    @source_owner = 'Production',
    @source_object = 'BillOfMaterials',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'BillOfMaterials',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_BillOfMaterials',
    @del_cmd = 'CALL Production.zRepl_del_BillOfMaterials',
    @upd_cmd = 'MCALL Production.zRepl_upd_BillOfMaterials';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.Culture',
    @source_owner = 'Production',
    @source_object = 'Culture',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'Culture',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_Culture',
    @del_cmd = 'CALL Production.zRepl_del_Culture',
    @upd_cmd = 'MCALL Production.zRepl_upd_Culture';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.Document',
    @source_owner = 'Production',
    @source_object = 'Document',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000D3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'Document',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_Document',
    @del_cmd = 'CALL Production.zRepl_del_Document',
    @upd_cmd = 'MCALL Production.zRepl_upd_Document';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.Illustration',
    @source_owner = 'Production',
    @source_object = 'Illustration',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'Illustration',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_Illustration',
    @del_cmd = 'CALL Production.zRepl_del_Illustration',
    @upd_cmd = 'MCALL Production.zRepl_upd_Illustration';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.Location',
    @source_owner = 'Production',
    @source_object = 'Location',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'Location',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_Location',
    @del_cmd = 'CALL Production.zRepl_del_Location',
    @upd_cmd = 'MCALL Production.zRepl_upd_Location';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.Product',
    @source_owner = 'Production',
    @source_object = 'Product',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'Product',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_Product',
    @del_cmd = 'CALL Production.zRepl_del_Product',
    @upd_cmd = 'MCALL Production.zRepl_upd_Product';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.ProductCategory',
    @source_owner = 'Production',
    @source_object = 'ProductCategory',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'ProductCategory',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_ProductCategory',
    @del_cmd = 'CALL Production.zRepl_del_ProductCategory',
    @upd_cmd = 'MCALL Production.zRepl_upd_ProductCategory';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.ProductCostHistory',
    @source_owner = 'Production',
    @source_object = 'ProductCostHistory',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'ProductCostHistory',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_ProductCostHistory',
    @del_cmd = 'CALL Production.zRepl_del_ProductCostHistory',
    @upd_cmd = 'MCALL Production.zRepl_upd_ProductCostHistory';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.ProductDescription',
    @source_owner = 'Production',
    @source_object = 'ProductDescription',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'ProductDescription',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_ProductDescription',
    @del_cmd = 'CALL Production.zRepl_del_ProductDescription',
    @upd_cmd = 'MCALL Production.zRepl_upd_ProductDescription';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.ProductDocument',
    @source_owner = 'Production',
    @source_object = 'ProductDocument',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000D3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'ProductDocument',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_ProductDocument',
    @del_cmd = 'CALL Production.zRepl_del_ProductDocument',
    @upd_cmd = 'MCALL Production.zRepl_upd_ProductDocument';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.ProductInventory',
    @source_owner = 'Production',
    @source_object = 'ProductInventory',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'ProductInventory',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_ProductInventory',
    @del_cmd = 'CALL Production.zRepl_del_ProductInventory',
    @upd_cmd = 'MCALL Production.zRepl_upd_ProductInventory';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.ProductListPriceHistory',
    @source_owner = 'Production',
    @source_object = 'ProductListPriceHistory',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'ProductListPriceHistory',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_ProductListPriceHistory',
    @del_cmd = 'CALL Production.zRepl_del_ProductListPriceHistory',
    @upd_cmd = 'MCALL Production.zRepl_upd_ProductListPriceHistory';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.ProductModel',
    @source_owner = 'Production',
    @source_object = 'ProductModel',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'ProductModel',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_ProductModel',
    @del_cmd = 'CALL Production.zRepl_del_ProductModel',
    @upd_cmd = 'MCALL Production.zRepl_upd_ProductModel';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.ProductModelIllustration',
    @source_owner = 'Production',
    @source_object = 'ProductModelIllustration',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'ProductModelIllustration',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_ProductModelIllustration',
    @del_cmd = 'CALL Production.zRepl_del_ProductModelIllustration',
    @upd_cmd = 'MCALL Production.zRepl_upd_ProductModelIllustration';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.ProductModelProductDescriptionCulture',
    @source_owner = 'Production',
    @source_object = 'ProductModelProductDescriptionCulture',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'ProductModelProductDescriptionCulture',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_ProductModelProductDescriptionCulture',
    @del_cmd = 'CALL Production.zRepl_del_ProductModelProductDescriptionCulture',
    @upd_cmd = 'MCALL Production.zRepl_upd_ProductModelProductDescriptionCulture';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.ProductPhoto',
    @source_owner = 'Production',
    @source_object = 'ProductPhoto',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'ProductPhoto',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_ProductPhoto',
    @del_cmd = 'CALL Production.zRepl_del_ProductPhoto',
    @upd_cmd = 'MCALL Production.zRepl_upd_ProductPhoto';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.ProductProductPhoto',
    @source_owner = 'Production',
    @source_object = 'ProductProductPhoto',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'ProductProductPhoto',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_ProductProductPhoto',
    @del_cmd = 'CALL Production.zRepl_del_ProductProductPhoto',
    @upd_cmd = 'MCALL Production.zRepl_upd_ProductProductPhoto';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.ProductReview',
    @source_owner = 'Production',
    @source_object = 'ProductReview',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'ProductReview',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_ProductReview',
    @del_cmd = 'CALL Production.zRepl_del_ProductReview',
    @upd_cmd = 'MCALL Production.zRepl_upd_ProductReview';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.ProductSubcategory',
    @source_owner = 'Production',
    @source_object = 'ProductSubcategory',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'ProductSubcategory',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_ProductSubcategory',
    @del_cmd = 'CALL Production.zRepl_del_ProductSubcategory',
    @upd_cmd = 'MCALL Production.zRepl_upd_ProductSubcategory';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.ScrapReason',
    @source_owner = 'Production',
    @source_object = 'ScrapReason',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'ScrapReason',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_ScrapReason',
    @del_cmd = 'CALL Production.zRepl_del_ScrapReason',
    @upd_cmd = 'MCALL Production.zRepl_upd_ScrapReason';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.TransactionHistory',
    @source_owner = 'Production',
    @source_object = 'TransactionHistory',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'TransactionHistory',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_TransactionHistory',
    @del_cmd = 'CALL Production.zRepl_del_TransactionHistory',
    @upd_cmd = 'MCALL Production.zRepl_upd_TransactionHistory';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.TransactionHistoryArchive',
    @source_owner = 'Production',
    @source_object = 'TransactionHistoryArchive',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'TransactionHistoryArchive',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_TransactionHistoryArchive',
    @del_cmd = 'CALL Production.zRepl_del_TransactionHistoryArchive',
    @upd_cmd = 'MCALL Production.zRepl_upd_TransactionHistoryArchive';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.UnitMeasure',
    @source_owner = 'Production',
    @source_object = 'UnitMeasure',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'UnitMeasure',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_UnitMeasure',
    @del_cmd = 'CALL Production.zRepl_del_UnitMeasure',
    @upd_cmd = 'MCALL Production.zRepl_upd_UnitMeasure';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.WorkOrder',
    @source_owner = 'Production',
    @source_object = 'WorkOrder',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'WorkOrder',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_WorkOrder',
    @del_cmd = 'CALL Production.zRepl_del_WorkOrder',
    @upd_cmd = 'MCALL Production.zRepl_upd_WorkOrder';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Production.WorkOrderRouting',
    @source_owner = 'Production',
    @source_object = 'WorkOrderRouting',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'WorkOrderRouting',
    @destination_owner = 'Production',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Production.zRepl_ins_WorkOrderRouting',
    @del_cmd = 'CALL Production.zRepl_del_WorkOrderRouting',
    @upd_cmd = 'MCALL Production.zRepl_upd_WorkOrderRouting';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Purchasing.ProductVendor',
    @source_owner = 'Purchasing',
    @source_object = 'ProductVendor',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'ProductVendor',
    @destination_owner = 'Purchasing',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Purchasing.zRepl_ins_ProductVendor',
    @del_cmd = 'CALL Purchasing.zRepl_del_ProductVendor',
    @upd_cmd = 'MCALL Purchasing.zRepl_upd_ProductVendor';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Purchasing.PurchaseOrderDetail',
    @source_owner = 'Purchasing',
    @source_object = 'PurchaseOrderDetail',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'PurchaseOrderDetail',
    @destination_owner = 'Purchasing',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Purchasing.zRepl_ins_PurchaseOrderDetail',
    @del_cmd = 'CALL Purchasing.zRepl_del_PurchaseOrderDetail',
    @upd_cmd = 'MCALL Purchasing.zRepl_upd_PurchaseOrderDetail';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Purchasing.PurchaseOrderHeader',
    @source_owner = 'Purchasing',
    @source_object = 'PurchaseOrderHeader',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'PurchaseOrderHeader',
    @destination_owner = 'Purchasing',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Purchasing.zRepl_ins_PurchaseOrderHeader',
    @del_cmd = 'CALL Purchasing.zRepl_del_PurchaseOrderHeader',
    @upd_cmd = 'MCALL Purchasing.zRepl_upd_PurchaseOrderHeader';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Purchasing.ShipMethod',
    @source_owner = 'Purchasing',
    @source_object = 'ShipMethod',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'ShipMethod',
    @destination_owner = 'Purchasing',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Purchasing.zRepl_ins_ShipMethod',
    @del_cmd = 'CALL Purchasing.zRepl_del_ShipMethod',
    @upd_cmd = 'MCALL Purchasing.zRepl_upd_ShipMethod';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Purchasing.Vendor',
    @source_owner = 'Purchasing',
    @source_object = 'Vendor',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'Vendor',
    @destination_owner = 'Purchasing',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Purchasing.zRepl_ins_Vendor',
    @del_cmd = 'CALL Purchasing.zRepl_del_Vendor',
    @upd_cmd = 'MCALL Purchasing.zRepl_upd_Vendor';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.CountryRegionCurrency',
    @source_owner = 'Sales',
    @source_object = 'CountryRegionCurrency',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'CountryRegionCurrency',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_CountryRegionCurrency',
    @del_cmd = 'CALL Sales.zRepl_del_CountryRegionCurrency',
    @upd_cmd = 'MCALL Sales.zRepl_upd_CountryRegionCurrency';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.CreditCard',
    @source_owner = 'Sales',
    @source_object = 'CreditCard',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'CreditCard',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_CreditCard',
    @del_cmd = 'CALL Sales.zRepl_del_CreditCard',
    @upd_cmd = 'MCALL Sales.zRepl_upd_CreditCard';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.Currency',
    @source_owner = 'Sales',
    @source_object = 'Currency',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'Currency',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_Currency',
    @del_cmd = 'CALL Sales.zRepl_del_Currency',
    @upd_cmd = 'MCALL Sales.zRepl_upd_Currency';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.CurrencyRate',
    @source_owner = 'Sales',
    @source_object = 'CurrencyRate',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'CurrencyRate',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_CurrencyRate',
    @del_cmd = 'CALL Sales.zRepl_del_CurrencyRate',
    @upd_cmd = 'MCALL Sales.zRepl_upd_CurrencyRate';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.Customer',
    @source_owner = 'Sales',
    @source_object = 'Customer',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'Customer',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_Customer',
    @del_cmd = 'CALL Sales.zRepl_del_Customer',
    @upd_cmd = 'MCALL Sales.zRepl_upd_Customer';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.PersonCreditCard',
    @source_owner = 'Sales',
    @source_object = 'PersonCreditCard',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'PersonCreditCard',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_PersonCreditCard',
    @del_cmd = 'CALL Sales.zRepl_del_PersonCreditCard',
    @upd_cmd = 'MCALL Sales.zRepl_upd_PersonCreditCard';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.SalesOrderDetail',
    @source_owner = 'Sales',
    @source_object = 'SalesOrderDetail',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000001C00F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'SalesOrderDetail',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_SalesOrderDetail',
    @del_cmd = 'CALL Sales.zRepl_del_SalesOrderDetail',
    @upd_cmd = 'MCALL Sales.zRepl_upd_SalesOrderDetail';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.SalesOrderHeader',
    @source_owner = 'Sales',
    @source_object = 'SalesOrderHeader',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000001C00F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'SalesOrderHeader',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_SalesOrderHeader',
    @del_cmd = 'CALL Sales.zRepl_del_SalesOrderHeader',
    @upd_cmd = 'MCALL Sales.zRepl_upd_SalesOrderHeader';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.SalesOrderHeaderSalesReason',
    @source_owner = 'Sales',
    @source_object = 'SalesOrderHeaderSalesReason',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000001C00F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'SalesOrderHeaderSalesReason',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_SalesOrderHeaderSalesReason',
    @del_cmd = 'CALL Sales.zRepl_del_SalesOrderHeaderSalesReason',
    @upd_cmd = 'MCALL Sales.zRepl_upd_SalesOrderHeaderSalesReason';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.SalesPerson',
    @source_owner = 'Sales',
    @source_object = 'SalesPerson',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'SalesPerson',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_SalesPerson',
    @del_cmd = 'CALL Sales.zRepl_del_SalesPerson',
    @upd_cmd = 'MCALL Sales.zRepl_upd_SalesPerson';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.SalesPersonQuotaHistory',
    @source_owner = 'Sales',
    @source_object = 'SalesPersonQuotaHistory',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'SalesPersonQuotaHistory',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_SalesPersonQuotaHistory',
    @del_cmd = 'CALL Sales.zRepl_del_SalesPersonQuotaHistory',
    @upd_cmd = 'MCALL Sales.zRepl_upd_SalesPersonQuotaHistory';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.SalesReason',
    @source_owner = 'Sales',
    @source_object = 'SalesReason',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'SalesReason',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_SalesReason',
    @del_cmd = 'CALL Sales.zRepl_del_SalesReason',
    @upd_cmd = 'MCALL Sales.zRepl_upd_SalesReason';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.SalesTaxRate',
    @source_owner = 'Sales',
    @source_object = 'SalesTaxRate',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'SalesTaxRate',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_SalesTaxRate',
    @del_cmd = 'CALL Sales.zRepl_del_SalesTaxRate',
    @upd_cmd = 'MCALL Sales.zRepl_upd_SalesTaxRate';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.SalesTerritory',
    @source_owner = 'Sales',
    @source_object = 'SalesTerritory',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'SalesTerritory',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_SalesTerritory',
    @del_cmd = 'CALL Sales.zRepl_del_SalesTerritory',
    @upd_cmd = 'MCALL Sales.zRepl_upd_SalesTerritory';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.SalesTerritoryHistory',
    @source_owner = 'Sales',
    @source_object = 'SalesTerritoryHistory',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'SalesTerritoryHistory',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_SalesTerritoryHistory',
    @del_cmd = 'CALL Sales.zRepl_del_SalesTerritoryHistory',
    @upd_cmd = 'MCALL Sales.zRepl_upd_SalesTerritoryHistory';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.ShoppingCartItem',
    @source_owner = 'Sales',
    @source_object = 'ShoppingCartItem',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'ShoppingCartItem',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_ShoppingCartItem',
    @del_cmd = 'CALL Sales.zRepl_del_ShoppingCartItem',
    @upd_cmd = 'MCALL Sales.zRepl_upd_ShoppingCartItem';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.SpecialOffer',
    @source_owner = 'Sales',
    @source_object = 'SpecialOffer',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'SpecialOffer',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_SpecialOffer',
    @del_cmd = 'CALL Sales.zRepl_del_SpecialOffer',
    @upd_cmd = 'MCALL Sales.zRepl_upd_SpecialOffer';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.SpecialOfferProduct',
    @source_owner = 'Sales',
    @source_object = 'SpecialOfferProduct',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'SpecialOfferProduct',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_SpecialOfferProduct',
    @del_cmd = 'CALL Sales.zRepl_del_SpecialOfferProduct',
    @upd_cmd = 'MCALL Sales.zRepl_upd_SpecialOfferProduct';
go
 


sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.Store',
    @source_owner = 'Sales',
    @source_object = 'Store',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',  -- must be manual for InitializeFromBackup
    @destination_table = 'Store',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_Store',
    @del_cmd = 'CALL Sales.zRepl_del_Store',
    @upd_cmd = 'MCALL Sales.zRepl_upd_Store';
go    