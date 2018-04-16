--Check if an XML Schema Already Exists
SELECT * 
 FROM  sys.xml_schema_collections 
 WHERE name='NameOfSchema'

--Create an XML Schema

-- DROP IF EXISTS
IF    EXISTS (SELECT 1 
              FROM  sys.xml_schema_collections 
              WHERE name='SampleSchema')
   DROP XML SCHEMA COLLECTION SampleSchema
 
CREATE XML SCHEMA COLLECTION SampleSchema AS 
'<?xml version="1.0" encoding="utf-8"?>
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <xsd:element name="Sample">
    <xsd:complexType>
      <xsd:attribute name="SampleID" type="xsd:integer" />
      <xsd:attribute name="Name" type="xsd:string" />
      <xsd:attribute name="Description" type="xsd:string" />
    </xsd:complexType>
  </xsd:element>
</xsd:schema>'


SELECT xml_schema_namespace(N'dbo',N'SampleSchema') 
--List Schema Elements and Attributes
SELECT
    sys.xml_schema_collections.xml_collection_id    AS CollectionID,
    sys.xml_schema_collections.name                 AS SchemaName,
    sys.xml_schema_elements.name                    AS ElementName,
    sys.xml_schema_attributes.name                  AS AttributeName
FROM
    sys.xml_schema_collections
    INNER JOIN sys.xml_schema_attributes
    ON sys.xml_schema_collections.xml_collection_id =  sys.xml_schema_attributes.xml_collection_id
    INNER JOIN sys.xml_schema_elements
    ON sys.xml_schema_collections.xml_collection_id = sys.xml_schema_elements.xml_collection_id
WHERE
    sys.xml_schema_collections.name NOT LIKE 'sys'

--List Columns That Have the XML Data 

 -- this lists the table catalog, table name, 
 -- column name, and data type
 SELECT 
     TABLE_CATALOG,
     TABLE_NAME,
     COLUMN_NAME, 
     DATA_TYPE 
 FROM 
     INFORMATION_SCHEMA.COLUMNS
 WHERE 
     DATA_TYPE = 'xml'
  


 -- this lists the corresponding schemas
 SELECT 
     DISTINCT
     OBJECT_NAME(sys.columns.object_id)        AS 'TableName',
     sys.columns.name                    AS 'ColName',
     sys.xml_schema_collections.name            AS 'Schema' 
 FROM 
     sys.columns
     LEFT JOIN     sys.xml_schema_collections 
     ON sys.columns.xml_collection_id = sys.xml_schema_collections.xml_collection_id
 ORDER BY 
     OBJECT_NAME(sys.columns.object_id), sys.columns.name    

--Alter Existing Column Schema (XSD)

-- drop the XML schema from existing column definitions
ALTER TABLE AD
   ALTER COLUMN Title xml
 
-- DROP IF EXISTS
IF    EXISTS (SELECT name 
              FROM  sys.xml_schema_collections 
              WHERE name='TitleSchema')
   DROP  XML SCHEMA COLLECTION TitleSchema
GO
 
-- new definition
-- there can only be one Title element
CREATE XML SCHEMA COLLECTION TitleSchema AS 
'<?xml version="1.0" encoding="utf-8"?>
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <xsd:element name="Title">
    <xsd:complexType>
         <xsd:attribute name="Type" type="xsd:string" />
         <xsd:attribute name="Value" type="xsd:string" use="optional" />
    </xsd:complexType>
  </xsd:element>
</xsd:schema>'
GO
 
-- IMPORTANT: before you add back the schema to the column 
-- definition, make sure all values in your existing column 
-- comply with the new schema definition
ALTER TABLE AD
   ALTER COLUMN Title xml(TitleSchema)

--List Columns That Have the XML Data Type
 -- this lists the table catalog, table name, 
 -- column name, and data type
 SELECT 
     TABLE_CATALOG,
     TABLE_NAME,
     COLUMN_NAME, 
     DATA_TYPE 
 FROM 
     INFORMATION_SCHEMA.COLUMNS
 WHERE 
     DATA_TYPE = 'xml'
  


 -- this lists the corresponding schemas
 SELECT 
     DISTINCT
     OBJECT_NAME(sys.columns.object_id)        AS 'TableName',
     sys.columns.name                    AS 'ColName',
     sys.xml_schema_collections.name            AS 'Schema' 
 FROM 
     sys.columns
     LEFT JOIN     sys.xml_schema_collections 
     ON sys.columns.xml_collection_id = sys.xml_schema_collections.xml_collection_id
 ORDER BY 
     OBJECT_NAME(sys.columns.object_id), sys.columns.name    
 --Bulk Load XML From a File Using OPENXML
 
 -- ==========================================================================
-- Object       : OPENXML1.sql
-- Object Type  : Script
-- Description  : Various examples
-- Developer    : Donabel Santos
-- Origin       : 2008/08/17
-- Last Modified: 2008/10/04
-- Notes        : 
-- ==========================================================================
 
-- bulk load
-- For this example, XML file must be saved in C:\
-- XML file also should specify UTF-8 encoding, ie:
-- <?xml version="1.0" encoding="UTF-8"?>
 
DECLARE @XMLTable TABLE
(
   xmlcol XML
)
 
INSERT INTO @XMLTable(xmlcol)
SELECT
    InvoicesXML
FROM
(
    SELECT * 
    FROM OPENROWSET(BULK 'c:\invoice.xml',SINGLE_BLOB) AS Invoices
) AS Invoices(InvoicesXML)
 
SELECT *
FROM @XMLTable
 
  --SQL Server XML Function exist()
  DECLARE @xmlSnippet XML
DECLARE @id SMALLINT
DECLARE @value VARCHAR(20)
 
SET @xmlSnippet = 
'
<ninjaElement id="1">SQL Server Ninja</ninjaElement>
<ninjaElement id="2">SharePoint Ninja</ninjaElement>
<ninjaElement id="3">ASP.NET Ninja</ninjaElement>
'
 
-- this is what we will look for
SET @id    = 2
SET @value ='SQL Server Ninja'
 
-- note exist() will return only either :
-- 1 (true) or 0 (false)
 
-- check if a node called ninjaElement exists
-- at any level in the XML snippet
SELECT @xml.exist('//ninjaElement')
 
-- check if a node called bar exists
SELECT @xml.exist('//bar')
 
-- check if attribute id exists anywhere
SELECT @xml.exist('//@id')
 
-- check if attribute id exists within a ninjaElement tag
SELECT @xml.exist('//ninjaElement[@id]')
 
-- check if the id attribute equals to what we saved 
-- in the @id variable
SELECT @xml.exist('/ninjaElement[@id=sql:variable("@id")]')
 
-- check if the node text equals to what 
-- we saved in the @value variable
SELECT @xml.exist('/ninjaElement[text()=sql:variable("@value")]')

--Work With XML Elements (or Nodes) in SQL Server

DECLARE @authorsXML XML
 
SET @authorsXML = '
<Author>
  <ID>172-32-1176</ID>
  <LastName>White</LastName>
  <FirstName>Johnson</FirstName>
  <Address>
    <Street>10932 Bigge Rd.</Street>
    <City>Menlo Park</City>
    <State>CA</State>
  </Address>
</Author>'

--To add an element as the last node
SET @authorsXML.modify('
    insert element Country {"Canada"} as last into
    (/Author/Address)[1]
')

--To add an element in a specific position
SET @authorsXML.modify('
    insert element MiddleInitial {"A"} after
    (/Author/LastName)[1]
')
--To update an element’s value based on a variable value
DECLARE @NewFirstName VARCHAR(20)
SET @NewFirstName = 'Johnny'
SET @authorsXML.modify(
'
    replace value of (/Author/FirstName/text())[1] 
    with sql:variable("@NewFirstName")
')
--To delete an element

SET @authorsXML.modify(
'
    delete (/Author/MiddleInitial)
')
--To delete an element based on the element value
SET @authorsXML.modify(
'
    delete (//*[text()="Canada"])
')
 
 --To delete an element based on the element name

 SET @authorsXML.modify(
'
    delete (//*[local-name()="State"])
')