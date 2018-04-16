/*
 * ER/Studio 7.6 SQL Code Generation
 * Company :      SEI
 * Project :      Install.DM1
 * Author :       Rick Reis
 *
 * Date Created : Tuesday, January 15, 2013 12:55:22
 * Target DBMS : Microsoft SQL Server 2005
 */

/* 
 * TABLE: ADDRESS 
 */

CREATE TABLE ADDRESS(
    Server_Address_ID       int              NOT NULL,
    Address_Type_ID         int              NOT NULL,
    Server_ID               int              NOT NULL,
    Server_IP_Address_Tx    varchar(20)      NULL,
    Server_Address_Nm       varchar(100)     NULL,
    Create_User_ID          nvarchar(128)    NOT NULL,
    Create_Dt               datetime         NOT NULL,
    Update_User_ID          nvarchar(128)    NOT NULL,
    Update_Dt               datetime         NOT NULL,
    Address_Ver_Num         int              NOT NULL
)
go



IF OBJECT_ID('ADDRESS') IS NOT NULL
    PRINT '<<< CREATED TABLE ADDRESS >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE ADDRESS >>>'
go

/* 
 * TABLE: ADDRESS_TYPE 
 */

CREATE TABLE ADDRESS_TYPE(
    Address_Type_ID    int            NOT NULL,
    Address_Type_Nm    varchar(40)    NULL
)
go



IF OBJECT_ID('ADDRESS_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE ADDRESS_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE ADDRESS_TYPE >>>'
go

/* 
 * TABLE: ALLOWABLE_PARAMETER 
 */

CREATE TABLE ALLOWABLE_PARAMETER(
    Parameter_ID                   int              IDENTITY(1,1),
    Parameter_Nm                   varchar(100)     NOT NULL,
    Parameter_Dsc                  varchar(400)     NULL,
    Parameter_Tag_Tx               varchar(100)     NULL,
    Parameter_Keyword_Tx           varchar(80)      NULL,
    Data_Type_Cd                   int              NOT NULL,
    Default_Value_Tx               varchar(400)     NULL,
    Default_Value_Num              int              NULL,
    Default_Value_Fl               bit              NULL,
    Reserved_Word_Fl               bit              NULL,
    Parm_Domain_ID                 int              NOT NULL,
    Generate_Name_Fl               bit              NULL,
    Create_User_ID                 nvarchar(128)    NOT NULL,
    Create_Dt                      datetime         NOT NULL,
    Update_User_ID                 nvarchar(128)    NOT NULL,
    Update_Dt                      datetime         NOT NULL,
    Allowable_Parameter_Ver_Num    int              NOT NULL
)
go



IF OBJECT_ID('ALLOWABLE_PARAMETER') IS NOT NULL
    PRINT '<<< CREATED TABLE ALLOWABLE_PARAMETER >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE ALLOWABLE_PARAMETER >>>'
go

/* 
 * TABLE: AUDIT_TRAIL 
 */

CREATE TABLE AUDIT_TRAIL(
    Audit_Trail_ID           numeric(15, 0)    IDENTITY(1,1),
    Structure_Version_Tag    varchar(20)       NULL,
    Table_Name               varchar(32)       NOT NULL,
    Column_Name              varchar(32)       NOT NULL,
    Audit_Type               varchar(10)       NOT NULL,
    User_ID                  nvarchar(128)     NOT NULL,
    Audit_Timestamp          datetime          DEFAULT current_timestamp NOT NULL,
    Old_Value                varchar(1000)     NULL,
    New_Value                varchar(1000)     NULL,
    Primary_Key_Value        varchar(200)      NOT NULL,
    Sequence_Num             numeric(15, 0)    NOT NULL,
    Split_Num                int               DEFAULT 1 NOT NULL
)
go



IF OBJECT_ID('AUDIT_TRAIL') IS NOT NULL
    PRINT '<<< CREATED TABLE AUDIT_TRAIL >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE AUDIT_TRAIL >>>'
go

/* 
 * TABLE: COMPONENT_PARAMETER 
 */

CREATE TABLE COMPONENT_PARAMETER(
    Component_Parameter_ID         int              NOT NULL,
    Product_Component_ID           int              NOT NULL,
    Parameter_ID                   int              NOT NULL,
    Required_Fl                    bit              NULL,
    Create_User_ID                 nvarchar(128)    NOT NULL,
    Create_Dt                      datetime         NOT NULL,
    Update_User_ID                 nvarchar(128)    NOT NULL,
    Update_Dt                      datetime         NOT NULL,
    Component_Parameter_Ver_Num    int              NOT NULL
)
go



IF OBJECT_ID('COMPONENT_PARAMETER') IS NOT NULL
    PRINT '<<< CREATED TABLE COMPONENT_PARAMETER >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE COMPONENT_PARAMETER >>>'
go

/* 
 * TABLE: COMPONENT_TYPE 
 */

CREATE TABLE COMPONENT_TYPE(
    Component_Type_Cd    int            NOT NULL,
    Component_Type_Nm    varchar(40)    NULL
)
go



IF OBJECT_ID('COMPONENT_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE COMPONENT_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE COMPONENT_TYPE >>>'
go

/* 
 * TABLE: CONTACT 
 */

CREATE TABLE CONTACT(
    Contact_ID                 int              NOT NULL,
    Contact_Type_ID            int              NOT NULL,
    Product_ID                 int              NULL,
    Organization_ID            int              NULL,
    People_ID                  int              NOT NULL,
    Product_Installation_ID    int              NULL,
    Schedule_ID                bigint           NULL,
    Task_Instance_ID           bigint           NULL,
    Contact_Method_Cd          int              NULL,
    Create_User_ID             nvarchar(128)    NOT NULL,
    Create_Dt                  datetime         NOT NULL,
    Update_User_ID             nvarchar(128)    NOT NULL,
    Update_Dt                  datetime         NOT NULL,
    Contact_Ver_Num            int              NOT NULL
)
go



IF OBJECT_ID('CONTACT') IS NOT NULL
    PRINT '<<< CREATED TABLE CONTACT >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE CONTACT >>>'
go

/* 
 * TABLE: CONTACT_METHOD 
 */

CREATE TABLE CONTACT_METHOD(
    Contact_Method_Cd    int         NOT NULL,
    Contact_Method_Nm    char(10)    NULL
)
go



IF OBJECT_ID('CONTACT_METHOD') IS NOT NULL
    PRINT '<<< CREATED TABLE CONTACT_METHOD >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE CONTACT_METHOD >>>'
go

/* 
 * TABLE: CONTACT_TYPE 
 */

CREATE TABLE CONTACT_TYPE(
    Contact_Type_ID    int            NOT NULL,
    Contact_Type_Nm    varchar(40)    NULL
)
go



IF OBJECT_ID('CONTACT_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE CONTACT_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE CONTACT_TYPE >>>'
go

/* 
 * TABLE: CREDENTIAL 
 */

CREATE TABLE CREDENTIAL(
    Credential_ID                      int              NOT NULL,
    Login_Nm                           varchar(80)      NOT NULL,
    Secret_Password_Tx                 varchar(20)      NOT NULL,
    Product_Installation_ID            int              NOT NULL,
    Related_Product_Installation_ID    int              NULL,
    Credential_Type_Cd                 int              NOT NULL,
    Credential_Abrv_Tx                 varchar(10)      NULL,
    Create_User_ID                     nvarchar(128)    NOT NULL,
    Create_Dt                          datetime         NOT NULL,
    Update_User_ID                     nvarchar(128)    NOT NULL,
    Update_Dt                          datetime         NOT NULL,
    Credential_Ver_Num                 int              NOT NULL
)
go



IF OBJECT_ID('CREDENTIAL') IS NOT NULL
    PRINT '<<< CREATED TABLE CREDENTIAL >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE CREDENTIAL >>>'
go

/* 
 * TABLE: CREDENTIAL_TYPE 
 */

CREATE TABLE CREDENTIAL_TYPE(
    Credential_Type_Cd    int            NOT NULL,
    Credential_Type_Nm    varchar(40)    NOT NULL
)
go



IF OBJECT_ID('CREDENTIAL_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE CREDENTIAL_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE CREDENTIAL_TYPE >>>'
go

/* 
 * TABLE: DATA_TYPE 
 */

CREATE TABLE DATA_TYPE(
    Data_Type_Cd    int            NOT NULL,
    Data_Type_Nm    varchar(20)    NULL
)
go



IF OBJECT_ID('DATA_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE DATA_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE DATA_TYPE >>>'
go

/* 
 * TABLE: DB_CONTROL 
 */

CREATE TABLE DB_CONTROL(
    Structure_Version_Tag     varchar(20)     NULL,
    Code_Version_Tag          varchar(20)     NULL,
    Test_Env_Flg              bit             DEFAULT 0 NOT NULL,
    Delta_Comment_Tx          varchar(100)    NULL,
    Last_Change_Process_Dt    datetime        NULL,
    DB_Control_Ver_Num        smallint        DEFAULT 1 NOT NULL
)
go



IF OBJECT_ID('DB_CONTROL') IS NOT NULL
    PRINT '<<< CREATED TABLE DB_CONTROL >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE DB_CONTROL >>>'
go

/* 
 * TABLE: DB_CONTROL_HISTORY 
 */

CREATE TABLE DB_CONTROL_HISTORY(
    DB_Control_History_Dt     datetime        DEFAULT current_timestamp NOT NULL,
    Structure_Version_Tag     varchar(20)     NULL,
    Code_Version_Tag          varchar(20)     NULL,
    Test_Env_Flg              bit             NOT NULL,
    Delta_Comment_Tx          varchar(100)    NULL,
    Last_Change_Process_Dt    datetime        NULL,
    DB_Control_Ver_Num        smallint        NOT NULL
)
go



IF OBJECT_ID('DB_CONTROL_HISTORY') IS NOT NULL
    PRINT '<<< CREATED TABLE DB_CONTROL_HISTORY >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE DB_CONTROL_HISTORY >>>'
go

/* 
 * TABLE: ENVIRONMENT_TYPE 
 */

CREATE TABLE ENVIRONMENT_TYPE(
    Environment_Type_Cd    int            NOT NULL,
    Environment_Type_Nm    varchar(40)    NOT NULL
)
go



IF OBJECT_ID('ENVIRONMENT_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE ENVIRONMENT_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE ENVIRONMENT_TYPE >>>'
go

/* 
 * TABLE: GENERATE_NAME 
 */

CREATE TABLE GENERATE_NAME(
    Parameter_ID                 int              NOT NULL,
    Component_Order_Num          int              NOT NULL,
    Organization_ID              int              NULL,
    Product_ID                   int              NULL,
    Server_ID                    int              NULL,
    Credential_ID                int              NULL,
    Use_Constant_Fl              bit              NULL,
    Constant_Value_Tx            varchar(10)      NULL,
    User_Specified_Fl            bit              NULL,
    User_Specified_Length_Num    int              NULL,
    Parm_Domain_ID               int              NULL,
    Create_User_ID               nvarchar(128)    NOT NULL,
    Create_Dt                    datetime         NOT NULL,
    Update_User_ID               nvarchar(128)    NOT NULL,
    Update_Dt                    datetime         NOT NULL,
    Generate_Name_Ver_Num        int              NOT NULL
)
go



IF OBJECT_ID('GENERATE_NAME') IS NOT NULL
    PRINT '<<< CREATED TABLE GENERATE_NAME >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE GENERATE_NAME >>>'
go

/* 
 * TABLE: INSTALL_STATE 
 */

CREATE TABLE INSTALL_STATE(
    Install_State_Cd    int            NOT NULL,
    Install_State_Nm    varchar(40)    NOT NULL
)
go



IF OBJECT_ID('INSTALL_STATE') IS NOT NULL
    PRINT '<<< CREATED TABLE INSTALL_STATE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE INSTALL_STATE >>>'
go

/* 
 * TABLE: INSTALL_USER 
 */

CREATE TABLE INSTALL_USER(
    Install_User_ID         int              NOT NULL,
    People_ID               int              NOT NULL,
    Environment_Type_Cd     int              NOT NULL,
    Product_ID              int              NULL,
    Create_User_ID          nvarchar(128)    NOT NULL,
    Create_Dt               datetime         NOT NULL,
    Update_User_ID          nvarchar(128)    NOT NULL,
    Update_Dt               datetime         NOT NULL,
    Install_User_Ver_Num    int              NOT NULL
)
go



IF OBJECT_ID('INSTALL_USER') IS NOT NULL
    PRINT '<<< CREATED TABLE INSTALL_USER >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE INSTALL_USER >>>'
go

/* 
 * TABLE: JOB 
 */

CREATE TABLE JOB(
    Job_ID                        int              IDENTITY(1,1),
    Job_Nm                        varchar(100)     NOT NULL,
    Job_Dsc                       varchar(400)     NULL,
    Product_Component_ID          int              NULL,
    Prior_Product_Component_ID    int              NULL,
    Job_Type_Cd                   int              NOT NULL,
    Create_User_ID                nvarchar(128)    NOT NULL,
    Create_Dt                     datetime         NOT NULL,
    Update_User_ID                nvarchar(128)    NOT NULL,
    Update_Dt                     datetime         NOT NULL,
    Job_Ver_Num                   int              NOT NULL
)
go



IF OBJECT_ID('JOB') IS NOT NULL
    PRINT '<<< CREATED TABLE JOB >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE JOB >>>'
go

/* 
 * TABLE: JOB_TYPE 
 */

CREATE TABLE JOB_TYPE(
    Job_Type_Cd    int            NOT NULL,
    Job_Type_Nm    varchar(40)    NOT NULL
)
go



IF OBJECT_ID('JOB_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE JOB_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE JOB_TYPE >>>'
go

/* 
 * TABLE: LICENSE_TYPE 
 */

CREATE TABLE LICENSE_TYPE(
    License_Type_Cd    int            NOT NULL,
    License_Type_Nm    varchar(30)    NOT NULL
)
go



IF OBJECT_ID('LICENSE_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE LICENSE_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE LICENSE_TYPE >>>'
go

/* 
 * TABLE: ORGANIZATION 
 */

CREATE TABLE ORGANIZATION(
    Organization_ID             int              IDENTITY(1,1),
    Organization_Nm             varchar(40)      NOT NULL,
    Organization_Dsc            varchar(400)     NULL,
    Client_T3K_Master_ID        int              NULL,
    Client_T3K_Supervisor_ID    int              NULL,
    T3K_Shared_Master_Fl        bit              NULL,
    Mainframe_System_Nm         varchar(1)       NULL,
    ADABAS_DB_Num               smallint         NULL,
    SEI_Client_ID               varchar(20)      NULL,
    Organization_Active_Fl      bit              NULL,
    Organization_Abrv_Tx        varchar(10)      NULL,
    Job_Naming_Abrv_Tx          varchar(3)       NULL,
    Create_User_ID              nvarchar(128)    NOT NULL,
    Create_Dt                   datetime         NOT NULL,
    Update_User_ID              nvarchar(128)    NOT NULL,
    Update_Dt                   datetime         NOT NULL,
    Organization_Ver_Num        int              NOT NULL
)
go



IF OBJECT_ID('ORGANIZATION') IS NOT NULL
    PRINT '<<< CREATED TABLE ORGANIZATION >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE ORGANIZATION >>>'
go

/* 
 * TABLE: PARAMETER_USAGE 
 */

CREATE TABLE PARAMETER_USAGE(
    Parameter_Usage_ID         int              IDENTITY(1,1),
    Parameter_ID               int              NOT NULL,
    Server_ID                  int              NULL,
    Organization_ID            int              NULL,
    Parameter_Value_Tx         varchar(400)     NULL,
    Parameter_Value_Num        int              NULL,
    Parameter_Value_Fl         bit              NULL,
    Create_User_ID             nvarchar(128)    NOT NULL,
    Create_Dt                  datetime         NOT NULL,
    Update_User_ID             nvarchar(128)    NOT NULL,
    Update_Dt                  datetime         NOT NULL,
    Parameter_Usage_Ver_Num    int              NOT NULL
)
go



IF OBJECT_ID('PARAMETER_USAGE') IS NOT NULL
    PRINT '<<< CREATED TABLE PARAMETER_USAGE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PARAMETER_USAGE >>>'
go

/* 
 * TABLE: PARM_DOMAIN 
 */

CREATE TABLE PARM_DOMAIN(
    Parm_Domain_ID         int              NOT NULL,
    Parm_Domain_Nm         varchar(40)      NOT NULL,
    Create_User_ID         nvarchar(128)    NOT NULL,
    Create_Dt              datetime         NOT NULL,
    Update_User_ID         nvarchar(128)    NOT NULL,
    Update_Dt              datetime         NOT NULL,
    Parm_Domain_Ver_Num    int              NOT NULL
)
go



IF OBJECT_ID('PARM_DOMAIN') IS NOT NULL
    PRINT '<<< CREATED TABLE PARM_DOMAIN >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PARM_DOMAIN >>>'
go

/* 
 * TABLE: PEOPLE 
 */

CREATE TABLE PEOPLE(
    People_ID                    int              NOT NULL,
    Phone_Number_Tx              varchar(20)      NULL,
    Alternate_Phone_Number_Tx    varchar(20)      NULL,
    People_Nm                    varchar(40)      NULL,
    Email_Address_Tx             varchar(80)      NULL,
    Virtual_User_Fl              bit              NULL,
    Group_Fl                     bit              NULL,
    SEI_Internal_Fl              bit              NULL,
    Organization_ID              int              NOT NULL,
    Create_User_ID               nvarchar(128)    NOT NULL,
    Create_Dt                    datetime         NOT NULL,
    Update_User_ID               nvarchar(128)    NOT NULL,
    Update_Dt                    datetime         NOT NULL,
    People_Ver_Num               int              NOT NULL
)
go



IF OBJECT_ID('PEOPLE') IS NOT NULL
    PRINT '<<< CREATED TABLE PEOPLE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PEOPLE >>>'
go

/* 
 * TABLE: PRODUCT 
 */

CREATE TABLE PRODUCT(
    Product_ID         int              IDENTITY(1,1),
    Product_Nm         varchar(40)      NULL,
    Product_Type_Cd    int              NULL,
    Organization_ID    int              NULL,
    Product_Dsc        varchar(200)     NULL,
    Product_Abrv_Tx    varchar(10)      NULL,
    Create_User_ID     nvarchar(128)    NOT NULL,
    Create_Dt          datetime         NOT NULL,
    Update_User_ID     nvarchar(128)    NOT NULL,
    Update_Dt          datetime         NOT NULL,
    Product_Ver_Num    int              NOT NULL
)
go



IF OBJECT_ID('PRODUCT') IS NOT NULL
    PRINT '<<< CREATED TABLE PRODUCT >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PRODUCT >>>'
go

/* 
 * TABLE: PRODUCT_COMPATIBLE 
 */

CREATE TABLE PRODUCT_COMPATIBLE(
    Product_Component_ID            int              NOT NULL,
    Related_Product_Component_ID    int              NOT NULL,
    Product_Dependent_Fl            bit              NULL,
    Preferred_Component_Fl          bit              NULL,
    Create_User_ID                  nvarchar(128)    NOT NULL,
    Create_Dt                       datetime         NOT NULL,
    Update_User_ID                  nvarchar(128)    NOT NULL,
    Update_Dt                       datetime         NOT NULL,
    Product_Compatible_Ver_Num      int              NOT NULL
)
go



IF OBJECT_ID('PRODUCT_COMPATIBLE') IS NOT NULL
    PRINT '<<< CREATED TABLE PRODUCT_COMPATIBLE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PRODUCT_COMPATIBLE >>>'
go

/* 
 * TABLE: PRODUCT_COMPONENT 
 */

CREATE TABLE PRODUCT_COMPONENT(
    Product_Component_ID         int              IDENTITY(1,1),
    Product_Version_ID           int              NOT NULL,
    Product_Component_Nm         varchar(100)     NOT NULL,
    Component_Type_Cd            int              NOT NULL,
    Availability_Dt              datetime         NULL,
    In_Production_Fl             bit              NULL,
    Product_Component_Dsc        varchar(200)     NULL,
    Template_URL_Tx              varchar(200)     NULL,
    Order_Num                    int              NULL,
    Create_User_ID               nvarchar(128)    NOT NULL,
    Create_Dt                    datetime         NOT NULL,
    Update_User_ID               nvarchar(128)    NOT NULL,
    Update_Dt                    datetime         NOT NULL,
    Product_Component_Ver_Num    int              NOT NULL
)
go



IF OBJECT_ID('PRODUCT_COMPONENT') IS NOT NULL
    PRINT '<<< CREATED TABLE PRODUCT_COMPONENT >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PRODUCT_COMPONENT >>>'
go

/* 
 * TABLE: PRODUCT_ELIGIBILITY 
 */

CREATE TABLE PRODUCT_ELIGIBILITY(
    Organization_ID                int              NOT NULL,
    Product_Component_ID           int              NOT NULL,
    Eligible_Dt                    datetime         NULL,
    Termination_Dt                 datetime         NULL,
    Create_User_ID                 nvarchar(128)    NOT NULL,
    Create_Dt                      datetime         NOT NULL,
    Update_User_ID                 nvarchar(128)    NOT NULL,
    Update_Dt                      datetime         NOT NULL,
    Product_Eligibility_Ver_Num    int              NOT NULL
)
go



IF OBJECT_ID('PRODUCT_ELIGIBILITY') IS NOT NULL
    PRINT '<<< CREATED TABLE PRODUCT_ELIGIBILITY >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PRODUCT_ELIGIBILITY >>>'
go

/* 
 * TABLE: PRODUCT_INSTALLATION 
 */

CREATE TABLE PRODUCT_INSTALLATION(
    Product_Installation_ID         int              NOT NULL,
    Product_Installation_Nm         varchar(40)      NULL,
    Server_ID                       int              NULL,
    Environment_Type_Cd             int              NULL,
    Organization_ID                 int              NULL,
    Product_Component_ID            int              NULL,
    Install_Dt                      datetime         NULL,
    Install_State_Cd                int              NOT NULL,
    Purchase_Order_ID               varchar(20)      NULL,
    License_ID                      varchar(50)      NULL,
    URL_Tx                          varchar(200)     NULL,
    Port_Num                        int              NULL,
    Install_User_ID                 int              NULL,
    License_Type_Cd                 int              NULL,
    Create_User_ID                  nvarchar(128)    NOT NULL,
    Create_Dt                       datetime         NOT NULL,
    Update_User_ID                  nvarchar(128)    NOT NULL,
    Update_Dt                       datetime         NOT NULL,
    Product_Installation_Ver_Num    int              NOT NULL
)
go



IF OBJECT_ID('PRODUCT_INSTALLATION') IS NOT NULL
    PRINT '<<< CREATED TABLE PRODUCT_INSTALLATION >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PRODUCT_INSTALLATION >>>'
go

/* 
 * TABLE: PRODUCT_TYPE 
 */

CREATE TABLE PRODUCT_TYPE(
    Product_Type_Cd    int            NOT NULL,
    Product_Type_Nm    varchar(40)    NOT NULL
)
go



IF OBJECT_ID('PRODUCT_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE PRODUCT_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PRODUCT_TYPE >>>'
go

/* 
 * TABLE: PRODUCT_VERSION 
 */

CREATE TABLE PRODUCT_VERSION(
    Product_Version_ID         int              IDENTITY(1,1),
    Product_ID                 int              NOT NULL,
    Version_Tag_Tx             varchar(20)      NOT NULL,
    Patch_Level_Tx             varchar(40)      NULL,
    Product_Version_Nm         varchar(40)      NULL,
    Product_Version_Dt         datetime         NULL,
    Product_Version_Dsc        varchar(200)     NULL,
    Create_User_ID             nvarchar(128)    NOT NULL,
    Create_Dt                  datetime         NOT NULL,
    Update_User_ID             nvarchar(128)    NOT NULL,
    Update_Dt                  datetime         NOT NULL,
    Product_Version_Ver_Num    int              NOT NULL
)
go



IF OBJECT_ID('PRODUCT_VERSION') IS NOT NULL
    PRINT '<<< CREATED TABLE PRODUCT_VERSION >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PRODUCT_VERSION >>>'
go

/* 
 * TABLE: RELATED_SERVER 
 */

CREATE TABLE RELATED_SERVER(
    Server_ID                 int              NOT NULL,
    Related_Server_ID         int              NOT NULL,
    Server_Relationship_Cd    int              NOT NULL,
    Create_User_ID            nvarchar(128)    NOT NULL,
    Create_Dt                 datetime         NOT NULL,
    Update_User_ID            nvarchar(128)    NOT NULL,
    Update_Dt                 datetime         NOT NULL,
    Related_Server_Ver_Num    int              NOT NULL
)
go



IF OBJECT_ID('RELATED_SERVER') IS NOT NULL
    PRINT '<<< CREATED TABLE RELATED_SERVER >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE RELATED_SERVER >>>'
go

/* 
 * TABLE: SCHEDULE 
 */

CREATE TABLE SCHEDULE(
    Schedule_ID           bigint           IDENTITY(1,1),
    Schedule_Nm           varchar(100)     NULL,
    Organization_ID       int              NOT NULL,
    Schedule_Dt           datetime         NULL,
    Completion_Dt         datetime         NULL,
    Request_Ticket_Num    int              NULL,
    Create_User_ID        nvarchar(128)    NOT NULL,
    Create_Dt             datetime         NOT NULL,
    Update_User_ID        nvarchar(128)    NOT NULL,
    Update_Dt             datetime         NOT NULL,
    Schedule_Ver_Num      int              NOT NULL
)
go



IF OBJECT_ID('SCHEDULE') IS NOT NULL
    PRINT '<<< CREATED TABLE SCHEDULE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE SCHEDULE >>>'
go

/* 
 * TABLE: SCHEDULE_DETAIL 
 */

CREATE TABLE SCHEDULE_DETAIL(
    Schedule_Detail_ID         int              NOT NULL,
    Schedule_ID                bigint           NOT NULL,
    Job_ID                     int              NOT NULL,
    Order_Num                  int              NULL,
    Create_User_ID             nvarchar(128)    NOT NULL,
    Create_Dt                  datetime         NOT NULL,
    Update_User_ID             nvarchar(128)    NOT NULL,
    Update_Dt                  datetime         NOT NULL,
    Schedule_Detail_Ver_Num    int              NOT NULL
)
go



IF OBJECT_ID('SCHEDULE_DETAIL') IS NOT NULL
    PRINT '<<< CREATED TABLE SCHEDULE_DETAIL >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE SCHEDULE_DETAIL >>>'
go

/* 
 * TABLE: SERVER 
 */

CREATE TABLE SERVER(
    Server_ID              int              IDENTITY(1,1),
    Environment_Type_Cd    int              NULL,
    Server_Nm              varchar(40)      NULL,
    Server_Dsc             varchar(200)     NULL,
    Virtual_Fl             bit              NULL,
    Server_Active_Fl       bit              NULL,
    Server_Abrx_Tx         varchar(10)      NULL,
    Create_User_ID         nvarchar(128)    NOT NULL,
    Create_Dt              datetime         NOT NULL,
    Update_User_ID         nvarchar(128)    NOT NULL,
    Update_Dt              datetime         NOT NULL,
    Server_Ver_Num         int              NOT NULL
)
go



IF OBJECT_ID('SERVER') IS NOT NULL
    PRINT '<<< CREATED TABLE SERVER >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE SERVER >>>'
go

/* 
 * TABLE: SERVER_RELATIONSHIP 
 */

CREATE TABLE SERVER_RELATIONSHIP(
    Server_Relationship_Cd    int            NOT NULL,
    Server_Relationship_Nm    varchar(40)    NOT NULL
)
go



IF OBJECT_ID('SERVER_RELATIONSHIP') IS NOT NULL
    PRINT '<<< CREATED TABLE SERVER_RELATIONSHIP >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE SERVER_RELATIONSHIP >>>'
go

/* 
 * TABLE: TASK 
 */

CREATE TABLE TASK(
    Task_ID                         int              NOT NULL,
    Task_Nm                         varchar(100)     NULL,
    Task_Dsc                        varchar(400)     NULL,
    Rollback_Task_ID                int              NULL,
    Job_ID                          int              NULL,
    Task_Type_Cd                    int              NULL,
    Order_Num                       int              NULL,
    Version_Specific_Fl             bit              NULL,
    Optional_Fl                     bit              NULL,
    Continue_On_Error_Fl            bit              NULL,
    Request_Ticket_Required_Fl      bit              NULL,
    Send_Status_Email_Fl            bit              NULL,
    Do_Parameter_Substitution_Fl    bit              NULL,
    Manual_Fl                       bit              NULL,
    Task_Template_File_Nm           varchar(200)     NULL,
    Task_Control_File_Nm            varchar(200)     NULL,
    Task_Process_Nm                 varchar(200)     NULL,
    Task_External_Ref_Tx            varchar(20)      NULL,
    Success_Return_Num              int              NULL,
    Success_Return_Tx               varchar(80)      NULL,
    Default_Contact_ID              int              NULL,
    Create_User_ID                  nvarchar(128)    NOT NULL,
    Create_Dt                       datetime         NOT NULL,
    Update_User_ID                  nvarchar(128)    NOT NULL,
    Update_Dt                       datetime         NOT NULL,
    Task_Ver_Num                    int              NOT NULL
)
go



IF OBJECT_ID('TASK') IS NOT NULL
    PRINT '<<< CREATED TABLE TASK >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE TASK >>>'
go

/* 
 * TABLE: TASK_INSTANCE 
 */

CREATE TABLE TASK_INSTANCE(
    Task_Instance_ID             bigint           NOT NULL,
    Server_ID                    int              NULL,
    Organization_ID              int              NOT NULL,
    Task_Status_Cd               int              NOT NULL,
    Instance_File_Nm             varchar(200)     NULL,
    Task_ID                      int              NOT NULL,
    Request_Ticket_Num           int              NULL,
    Completion_Wait_Tm           datetime         NULL,
    Scheduled_Completion_Dt      datetime         NULL,
    Scheduled_Completion_Dt_1    datetime         NULL,
    Actual_Completion_Dt         datetime         NULL,
    Create_User_ID               nvarchar(128)    NOT NULL,
    Create_Dt                    datetime         NOT NULL,
    Update_User_ID               nvarchar(128)    NOT NULL,
    Update_Dt                    datetime         NOT NULL,
    Task_Instance_Ver_Num        int              NOT NULL
)
go



IF OBJECT_ID('TASK_INSTANCE') IS NOT NULL
    PRINT '<<< CREATED TABLE TASK_INSTANCE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE TASK_INSTANCE >>>'
go

/* 
 * TABLE: TASK_LOG 
 */

CREATE TABLE TASK_LOG(
    Task_Log_ID         bigint          NOT NULL,
    Task_Instance_ID    bigint          NOT NULL,
    Task_Status_Cd      int             NOT NULL,
    Return_Num          int             NULL,
    Task_Log_Dt         datetime        NOT NULL,
    Task_Log_Tx         varchar(256)    NULL
)
go



IF OBJECT_ID('TASK_LOG') IS NOT NULL
    PRINT '<<< CREATED TABLE TASK_LOG >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE TASK_LOG >>>'
go

/* 
 * TABLE: TASK_STATUS 
 */

CREATE TABLE TASK_STATUS(
    Task_Status_Cd    int         NOT NULL,
    Task_Status_Nm    char(40)    NOT NULL
)
go



IF OBJECT_ID('TASK_STATUS') IS NOT NULL
    PRINT '<<< CREATED TABLE TASK_STATUS >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE TASK_STATUS >>>'
go

/* 
 * TABLE: TASK_TYPE 
 */

CREATE TABLE TASK_TYPE(
    Task_Type_Cd    int            NOT NULL,
    Task_Type_Nm    varchar(40)    NOT NULL
)
go



IF OBJECT_ID('TASK_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE TASK_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE TASK_TYPE >>>'
go

/* 
 * INDEX: PARM_DOMAIN_AK 
 */

CREATE UNIQUE INDEX PARM_DOMAIN_AK ON PARM_DOMAIN(Parm_Domain_Nm)
go
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('PARM_DOMAIN') AND name='PARM_DOMAIN_AK')
    PRINT '<<< CREATED INDEX PARM_DOMAIN.PARM_DOMAIN_AK >>>'
ELSE
    PRINT '<<< FAILED CREATING INDEX PARM_DOMAIN.PARM_DOMAIN_AK >>>'
go

/* 
 * TABLE: ADDRESS 
 */

ALTER TABLE ADDRESS ADD 
    PRIMARY KEY CLUSTERED (Server_Address_ID)
go

IF OBJECT_ID('ADDRESS') IS NOT NULL
    PRINT '<<< CREATED TABLE ADDRESS >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE ADDRESS >>>'
go

/* 
 * TABLE: ADDRESS_TYPE 
 */

ALTER TABLE ADDRESS_TYPE ADD 
    PRIMARY KEY CLUSTERED (Address_Type_ID)
go

IF OBJECT_ID('ADDRESS_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE ADDRESS_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE ADDRESS_TYPE >>>'
go

/* 
 * TABLE: ALLOWABLE_PARAMETER 
 */

ALTER TABLE ALLOWABLE_PARAMETER ADD 
    PRIMARY KEY CLUSTERED (Parameter_ID)
go

IF OBJECT_ID('ALLOWABLE_PARAMETER') IS NOT NULL
    PRINT '<<< CREATED TABLE ALLOWABLE_PARAMETER >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE ALLOWABLE_PARAMETER >>>'
go

/* 
 * TABLE: AUDIT_TRAIL 
 */

ALTER TABLE AUDIT_TRAIL ADD 
    PRIMARY KEY NONCLUSTERED (Audit_Trail_ID)
go

IF OBJECT_ID('AUDIT_TRAIL') IS NOT NULL
    PRINT '<<< CREATED TABLE AUDIT_TRAIL >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE AUDIT_TRAIL >>>'
go

/* 
 * TABLE: COMPONENT_PARAMETER 
 */

ALTER TABLE COMPONENT_PARAMETER ADD 
    PRIMARY KEY CLUSTERED (Component_Parameter_ID)
go

IF OBJECT_ID('COMPONENT_PARAMETER') IS NOT NULL
    PRINT '<<< CREATED TABLE COMPONENT_PARAMETER >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE COMPONENT_PARAMETER >>>'
go

/* 
 * TABLE: COMPONENT_TYPE 
 */

ALTER TABLE COMPONENT_TYPE ADD 
    PRIMARY KEY CLUSTERED (Component_Type_Cd)
go

IF OBJECT_ID('COMPONENT_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE COMPONENT_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE COMPONENT_TYPE >>>'
go

/* 
 * TABLE: CONTACT 
 */

ALTER TABLE CONTACT ADD 
    PRIMARY KEY CLUSTERED (Contact_ID)
go

IF OBJECT_ID('CONTACT') IS NOT NULL
    PRINT '<<< CREATED TABLE CONTACT >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE CONTACT >>>'
go

/* 
 * TABLE: CONTACT_METHOD 
 */

ALTER TABLE CONTACT_METHOD ADD 
    PRIMARY KEY CLUSTERED (Contact_Method_Cd)
go

IF OBJECT_ID('CONTACT_METHOD') IS NOT NULL
    PRINT '<<< CREATED TABLE CONTACT_METHOD >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE CONTACT_METHOD >>>'
go

/* 
 * TABLE: CONTACT_TYPE 
 */

ALTER TABLE CONTACT_TYPE ADD 
    PRIMARY KEY CLUSTERED (Contact_Type_ID)
go

IF OBJECT_ID('CONTACT_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE CONTACT_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE CONTACT_TYPE >>>'
go

/* 
 * TABLE: CREDENTIAL 
 */

ALTER TABLE CREDENTIAL ADD 
    PRIMARY KEY CLUSTERED (Credential_ID)
go

IF OBJECT_ID('CREDENTIAL') IS NOT NULL
    PRINT '<<< CREATED TABLE CREDENTIAL >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE CREDENTIAL >>>'
go

/* 
 * TABLE: CREDENTIAL_TYPE 
 */

ALTER TABLE CREDENTIAL_TYPE ADD 
    PRIMARY KEY CLUSTERED (Credential_Type_Cd)
go

IF OBJECT_ID('CREDENTIAL_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE CREDENTIAL_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE CREDENTIAL_TYPE >>>'
go

/* 
 * TABLE: DATA_TYPE 
 */

ALTER TABLE DATA_TYPE ADD 
    PRIMARY KEY CLUSTERED (Data_Type_Cd)
go

IF OBJECT_ID('DATA_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE DATA_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE DATA_TYPE >>>'
go

/* 
 * TABLE: ENVIRONMENT_TYPE 
 */

ALTER TABLE ENVIRONMENT_TYPE ADD 
    PRIMARY KEY CLUSTERED (Environment_Type_Cd)
go

IF OBJECT_ID('ENVIRONMENT_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE ENVIRONMENT_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE ENVIRONMENT_TYPE >>>'
go

/* 
 * TABLE: GENERATE_NAME 
 */

ALTER TABLE GENERATE_NAME ADD 
    PRIMARY KEY CLUSTERED (Component_Order_Num, Parameter_ID)
go

IF OBJECT_ID('GENERATE_NAME') IS NOT NULL
    PRINT '<<< CREATED TABLE GENERATE_NAME >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE GENERATE_NAME >>>'
go

/* 
 * TABLE: INSTALL_STATE 
 */

ALTER TABLE INSTALL_STATE ADD 
    PRIMARY KEY CLUSTERED (Install_State_Cd)
go

IF OBJECT_ID('INSTALL_STATE') IS NOT NULL
    PRINT '<<< CREATED TABLE INSTALL_STATE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE INSTALL_STATE >>>'
go

/* 
 * TABLE: INSTALL_USER 
 */

ALTER TABLE INSTALL_USER ADD 
    PRIMARY KEY CLUSTERED (Install_User_ID)
go

IF OBJECT_ID('INSTALL_USER') IS NOT NULL
    PRINT '<<< CREATED TABLE INSTALL_USER >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE INSTALL_USER >>>'
go

/* 
 * TABLE: JOB 
 */

ALTER TABLE JOB ADD 
    PRIMARY KEY CLUSTERED (Job_ID)
go

IF OBJECT_ID('JOB') IS NOT NULL
    PRINT '<<< CREATED TABLE JOB >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE JOB >>>'
go

/* 
 * TABLE: JOB_TYPE 
 */

ALTER TABLE JOB_TYPE ADD 
    PRIMARY KEY CLUSTERED (Job_Type_Cd)
go

IF OBJECT_ID('JOB_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE JOB_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE JOB_TYPE >>>'
go

/* 
 * TABLE: LICENSE_TYPE 
 */

ALTER TABLE LICENSE_TYPE ADD 
    PRIMARY KEY CLUSTERED (License_Type_Cd)
go

IF OBJECT_ID('LICENSE_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE LICENSE_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE LICENSE_TYPE >>>'
go

/* 
 * TABLE: ORGANIZATION 
 */

ALTER TABLE ORGANIZATION ADD 
    PRIMARY KEY CLUSTERED (Organization_ID)
go

IF OBJECT_ID('ORGANIZATION') IS NOT NULL
    PRINT '<<< CREATED TABLE ORGANIZATION >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE ORGANIZATION >>>'
go

/* 
 * TABLE: PARAMETER_USAGE 
 */

ALTER TABLE PARAMETER_USAGE ADD 
    PRIMARY KEY CLUSTERED (Parameter_Usage_ID)
go

IF OBJECT_ID('PARAMETER_USAGE') IS NOT NULL
    PRINT '<<< CREATED TABLE PARAMETER_USAGE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PARAMETER_USAGE >>>'
go

/* 
 * TABLE: PARM_DOMAIN 
 */

ALTER TABLE PARM_DOMAIN ADD 
    PRIMARY KEY CLUSTERED (Parm_Domain_ID)
go

IF OBJECT_ID('PARM_DOMAIN') IS NOT NULL
    PRINT '<<< CREATED TABLE PARM_DOMAIN >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PARM_DOMAIN >>>'
go

/* 
 * TABLE: PEOPLE 
 */

ALTER TABLE PEOPLE ADD 
    PRIMARY KEY CLUSTERED (People_ID)
go

IF OBJECT_ID('PEOPLE') IS NOT NULL
    PRINT '<<< CREATED TABLE PEOPLE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PEOPLE >>>'
go

/* 
 * TABLE: PRODUCT 
 */

ALTER TABLE PRODUCT ADD 
    PRIMARY KEY CLUSTERED (Product_ID)
go

IF OBJECT_ID('PRODUCT') IS NOT NULL
    PRINT '<<< CREATED TABLE PRODUCT >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PRODUCT >>>'
go

/* 
 * TABLE: PRODUCT_COMPATIBLE 
 */

ALTER TABLE PRODUCT_COMPATIBLE ADD 
    PRIMARY KEY NONCLUSTERED (Product_Component_ID, Related_Product_Component_ID)
go

IF OBJECT_ID('PRODUCT_COMPATIBLE') IS NOT NULL
    PRINT '<<< CREATED TABLE PRODUCT_COMPATIBLE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PRODUCT_COMPATIBLE >>>'
go

/* 
 * TABLE: PRODUCT_COMPONENT 
 */

ALTER TABLE PRODUCT_COMPONENT ADD 
    PRIMARY KEY CLUSTERED (Product_Component_ID)
go

IF OBJECT_ID('PRODUCT_COMPONENT') IS NOT NULL
    PRINT '<<< CREATED TABLE PRODUCT_COMPONENT >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PRODUCT_COMPONENT >>>'
go

/* 
 * TABLE: PRODUCT_ELIGIBILITY 
 */

ALTER TABLE PRODUCT_ELIGIBILITY ADD 
    PRIMARY KEY NONCLUSTERED (Product_Component_ID, Organization_ID)
go

IF OBJECT_ID('PRODUCT_ELIGIBILITY') IS NOT NULL
    PRINT '<<< CREATED TABLE PRODUCT_ELIGIBILITY >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PRODUCT_ELIGIBILITY >>>'
go

/* 
 * TABLE: PRODUCT_INSTALLATION 
 */

ALTER TABLE PRODUCT_INSTALLATION ADD 
    PRIMARY KEY CLUSTERED (Product_Installation_ID)
go

IF OBJECT_ID('PRODUCT_INSTALLATION') IS NOT NULL
    PRINT '<<< CREATED TABLE PRODUCT_INSTALLATION >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PRODUCT_INSTALLATION >>>'
go

/* 
 * TABLE: PRODUCT_TYPE 
 */

ALTER TABLE PRODUCT_TYPE ADD 
    PRIMARY KEY CLUSTERED (Product_Type_Cd)
go

IF OBJECT_ID('PRODUCT_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE PRODUCT_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PRODUCT_TYPE >>>'
go

/* 
 * TABLE: PRODUCT_VERSION 
 */

ALTER TABLE PRODUCT_VERSION ADD 
    PRIMARY KEY CLUSTERED (Product_Version_ID)
go

IF OBJECT_ID('PRODUCT_VERSION') IS NOT NULL
    PRINT '<<< CREATED TABLE PRODUCT_VERSION >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE PRODUCT_VERSION >>>'
go

/* 
 * TABLE: RELATED_SERVER 
 */

ALTER TABLE RELATED_SERVER ADD 
    PRIMARY KEY NONCLUSTERED (Server_ID, Related_Server_ID, Server_Relationship_Cd)
go

IF OBJECT_ID('RELATED_SERVER') IS NOT NULL
    PRINT '<<< CREATED TABLE RELATED_SERVER >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE RELATED_SERVER >>>'
go

/* 
 * TABLE: SCHEDULE 
 */

ALTER TABLE SCHEDULE ADD 
    PRIMARY KEY CLUSTERED (Schedule_ID)
go

IF OBJECT_ID('SCHEDULE') IS NOT NULL
    PRINT '<<< CREATED TABLE SCHEDULE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE SCHEDULE >>>'
go

/* 
 * TABLE: SCHEDULE_DETAIL 
 */

ALTER TABLE SCHEDULE_DETAIL ADD 
    PRIMARY KEY CLUSTERED (Schedule_Detail_ID)
go

IF OBJECT_ID('SCHEDULE_DETAIL') IS NOT NULL
    PRINT '<<< CREATED TABLE SCHEDULE_DETAIL >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE SCHEDULE_DETAIL >>>'
go

/* 
 * TABLE: SERVER 
 */

ALTER TABLE SERVER ADD 
    PRIMARY KEY CLUSTERED (Server_ID)
go

IF OBJECT_ID('SERVER') IS NOT NULL
    PRINT '<<< CREATED TABLE SERVER >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE SERVER >>>'
go

/* 
 * TABLE: SERVER_RELATIONSHIP 
 */

ALTER TABLE SERVER_RELATIONSHIP ADD 
    PRIMARY KEY CLUSTERED (Server_Relationship_Cd)
go

IF OBJECT_ID('SERVER_RELATIONSHIP') IS NOT NULL
    PRINT '<<< CREATED TABLE SERVER_RELATIONSHIP >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE SERVER_RELATIONSHIP >>>'
go

/* 
 * TABLE: TASK 
 */

ALTER TABLE TASK ADD 
    PRIMARY KEY CLUSTERED (Task_ID)
go

IF OBJECT_ID('TASK') IS NOT NULL
    PRINT '<<< CREATED TABLE TASK >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE TASK >>>'
go

/* 
 * TABLE: TASK_INSTANCE 
 */

ALTER TABLE TASK_INSTANCE ADD 
    PRIMARY KEY CLUSTERED (Task_Instance_ID)
go

IF OBJECT_ID('TASK_INSTANCE') IS NOT NULL
    PRINT '<<< CREATED TABLE TASK_INSTANCE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE TASK_INSTANCE >>>'
go

/* 
 * TABLE: TASK_LOG 
 */

ALTER TABLE TASK_LOG ADD 
    PRIMARY KEY CLUSTERED (Task_Log_ID)
go

IF OBJECT_ID('TASK_LOG') IS NOT NULL
    PRINT '<<< CREATED TABLE TASK_LOG >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE TASK_LOG >>>'
go

/* 
 * TABLE: TASK_STATUS 
 */

ALTER TABLE TASK_STATUS ADD 
    PRIMARY KEY CLUSTERED (Task_Status_Cd)
go

IF OBJECT_ID('TASK_STATUS') IS NOT NULL
    PRINT '<<< CREATED TABLE TASK_STATUS >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE TASK_STATUS >>>'
go

/* 
 * TABLE: TASK_TYPE 
 */

ALTER TABLE TASK_TYPE ADD 
    PRIMARY KEY CLUSTERED (Task_Type_Cd)
go

IF OBJECT_ID('TASK_TYPE') IS NOT NULL
    PRINT '<<< CREATED TABLE TASK_TYPE >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE TASK_TYPE >>>'
go

/* 
 * TABLE: ADDRESS 
 */

ALTER TABLE ADDRESS ADD CONSTRAINT RefADDRESS_TYPE87 
    FOREIGN KEY (Address_Type_ID)
    REFERENCES ADDRESS_TYPE(Address_Type_ID)
go

ALTER TABLE ADDRESS ADD CONSTRAINT RefSERVER88 
    FOREIGN KEY (Server_ID)
    REFERENCES SERVER(Server_ID)
go


/* 
 * TABLE: ALLOWABLE_PARAMETER 
 */

ALTER TABLE ALLOWABLE_PARAMETER ADD CONSTRAINT RefDATA_TYPE117 
    FOREIGN KEY (Data_Type_Cd)
    REFERENCES DATA_TYPE(Data_Type_Cd)
go

ALTER TABLE ALLOWABLE_PARAMETER ADD CONSTRAINT RefPARM_DOMAIN82 
    FOREIGN KEY (Parm_Domain_ID)
    REFERENCES PARM_DOMAIN(Parm_Domain_ID)
go


/* 
 * TABLE: COMPONENT_PARAMETER 
 */

ALTER TABLE COMPONENT_PARAMETER ADD CONSTRAINT RefPRODUCT_COMPONENT103 
    FOREIGN KEY (Product_Component_ID)
    REFERENCES PRODUCT_COMPONENT(Product_Component_ID)
go

ALTER TABLE COMPONENT_PARAMETER ADD CONSTRAINT RefALLOWABLE_PARAMETER104 
    FOREIGN KEY (Parameter_ID)
    REFERENCES ALLOWABLE_PARAMETER(Parameter_ID)
go


/* 
 * TABLE: CONTACT 
 */

ALTER TABLE CONTACT ADD CONSTRAINT RefTASK_INSTANCE115 
    FOREIGN KEY (Task_Instance_ID)
    REFERENCES TASK_INSTANCE(Task_Instance_ID)
go

ALTER TABLE CONTACT ADD CONSTRAINT RefCONTACT_METHOD116 
    FOREIGN KEY (Contact_Method_Cd)
    REFERENCES CONTACT_METHOD(Contact_Method_Cd)
go

ALTER TABLE CONTACT ADD CONSTRAINT RefORGANIZATION44 
    FOREIGN KEY (Organization_ID)
    REFERENCES ORGANIZATION(Organization_ID)
go

ALTER TABLE CONTACT ADD CONSTRAINT RefPRODUCT50 
    FOREIGN KEY (Product_ID)
    REFERENCES PRODUCT(Product_ID)
go

ALTER TABLE CONTACT ADD CONSTRAINT RefPEOPLE73 
    FOREIGN KEY (People_ID)
    REFERENCES PEOPLE(People_ID)
go

ALTER TABLE CONTACT ADD CONSTRAINT RefPRODUCT_INSTALLATION84 
    FOREIGN KEY (Product_Installation_ID)
    REFERENCES PRODUCT_INSTALLATION(Product_Installation_ID)
go

ALTER TABLE CONTACT ADD CONSTRAINT RefCONTACT_TYPE85 
    FOREIGN KEY (Contact_Type_ID)
    REFERENCES CONTACT_TYPE(Contact_Type_ID)
go

ALTER TABLE CONTACT ADD CONSTRAINT RefSCHEDULE102 
    FOREIGN KEY (Schedule_ID)
    REFERENCES SCHEDULE(Schedule_ID)
go


/* 
 * TABLE: CREDENTIAL 
 */

ALTER TABLE CREDENTIAL ADD CONSTRAINT RefPRODUCT_INSTALLATION83 
    FOREIGN KEY (Product_Installation_ID)
    REFERENCES PRODUCT_INSTALLATION(Product_Installation_ID)
go

ALTER TABLE CREDENTIAL ADD CONSTRAINT RefCREDENTIAL_TYPE105 
    FOREIGN KEY (Credential_Type_Cd)
    REFERENCES CREDENTIAL_TYPE(Credential_Type_Cd)
go

ALTER TABLE CREDENTIAL ADD CONSTRAINT RefPRODUCT_INSTALLATION106 
    FOREIGN KEY (Related_Product_Installation_ID)
    REFERENCES PRODUCT_INSTALLATION(Product_Installation_ID)
go


/* 
 * TABLE: GENERATE_NAME 
 */

ALTER TABLE GENERATE_NAME ADD CONSTRAINT RefALLOWABLE_PARAMETER107 
    FOREIGN KEY (Parameter_ID)
    REFERENCES ALLOWABLE_PARAMETER(Parameter_ID)
go

ALTER TABLE GENERATE_NAME ADD CONSTRAINT RefORGANIZATION108 
    FOREIGN KEY (Organization_ID)
    REFERENCES ORGANIZATION(Organization_ID)
go

ALTER TABLE GENERATE_NAME ADD CONSTRAINT RefPRODUCT109 
    FOREIGN KEY (Product_ID)
    REFERENCES PRODUCT(Product_ID)
go

ALTER TABLE GENERATE_NAME ADD CONSTRAINT RefSERVER110 
    FOREIGN KEY (Server_ID)
    REFERENCES SERVER(Server_ID)
go

ALTER TABLE GENERATE_NAME ADD CONSTRAINT RefCREDENTIAL111 
    FOREIGN KEY (Credential_ID)
    REFERENCES CREDENTIAL(Credential_ID)
go

ALTER TABLE GENERATE_NAME ADD CONSTRAINT RefPARM_DOMAIN112 
    FOREIGN KEY (Parm_Domain_ID)
    REFERENCES PARM_DOMAIN(Parm_Domain_ID)
go


/* 
 * TABLE: INSTALL_USER 
 */

ALTER TABLE INSTALL_USER ADD CONSTRAINT RefPEOPLE72 
    FOREIGN KEY (People_ID)
    REFERENCES PEOPLE(People_ID)
go

ALTER TABLE INSTALL_USER ADD CONSTRAINT RefENVIRONMENT_TYPE93 
    FOREIGN KEY (Environment_Type_Cd)
    REFERENCES ENVIRONMENT_TYPE(Environment_Type_Cd)
go

ALTER TABLE INSTALL_USER ADD CONSTRAINT RefPRODUCT94 
    FOREIGN KEY (Product_ID)
    REFERENCES PRODUCT(Product_ID)
go


/* 
 * TABLE: JOB 
 */

ALTER TABLE JOB ADD CONSTRAINT RefPRODUCT_COMPONENT49 
    FOREIGN KEY (Product_Component_ID)
    REFERENCES PRODUCT_COMPONENT(Product_Component_ID)
go

ALTER TABLE JOB ADD CONSTRAINT RefPRODUCT_COMPONENT90 
    FOREIGN KEY (Prior_Product_Component_ID)
    REFERENCES PRODUCT_COMPONENT(Product_Component_ID)
go

ALTER TABLE JOB ADD CONSTRAINT RefJOB_TYPE23 
    FOREIGN KEY (Job_Type_Cd)
    REFERENCES JOB_TYPE(Job_Type_Cd)
go


/* 
 * TABLE: PARAMETER_USAGE 
 */

ALTER TABLE PARAMETER_USAGE ADD CONSTRAINT RefORGANIZATION51 
    FOREIGN KEY (Organization_ID)
    REFERENCES ORGANIZATION(Organization_ID)
go

ALTER TABLE PARAMETER_USAGE ADD CONSTRAINT RefSERVER64 
    FOREIGN KEY (Server_ID)
    REFERENCES SERVER(Server_ID)
go

ALTER TABLE PARAMETER_USAGE ADD CONSTRAINT RefALLOWABLE_PARAMETER16 
    FOREIGN KEY (Parameter_ID)
    REFERENCES ALLOWABLE_PARAMETER(Parameter_ID)
go


/* 
 * TABLE: PEOPLE 
 */

ALTER TABLE PEOPLE ADD CONSTRAINT RefORGANIZATION92 
    FOREIGN KEY (Organization_ID)
    REFERENCES ORGANIZATION(Organization_ID)
go


/* 
 * TABLE: PRODUCT 
 */

ALTER TABLE PRODUCT ADD CONSTRAINT RefPRODUCT_TYPE41 
    FOREIGN KEY (Product_Type_Cd)
    REFERENCES PRODUCT_TYPE(Product_Type_Cd)
go

ALTER TABLE PRODUCT ADD CONSTRAINT RefORGANIZATION86 
    FOREIGN KEY (Organization_ID)
    REFERENCES ORGANIZATION(Organization_ID)
go


/* 
 * TABLE: PRODUCT_COMPATIBLE 
 */

ALTER TABLE PRODUCT_COMPATIBLE ADD CONSTRAINT RefPRODUCT_COMPONENT69 
    FOREIGN KEY (Product_Component_ID)
    REFERENCES PRODUCT_COMPONENT(Product_Component_ID)
go

ALTER TABLE PRODUCT_COMPATIBLE ADD CONSTRAINT RefPRODUCT_COMPONENT70 
    FOREIGN KEY (Related_Product_Component_ID)
    REFERENCES PRODUCT_COMPONENT(Product_Component_ID)
go


/* 
 * TABLE: PRODUCT_COMPONENT 
 */

ALTER TABLE PRODUCT_COMPONENT ADD CONSTRAINT RefCOMPONENT_TYPE11 
    FOREIGN KEY (Component_Type_Cd)
    REFERENCES COMPONENT_TYPE(Component_Type_Cd)
go

ALTER TABLE PRODUCT_COMPONENT ADD CONSTRAINT RefPRODUCT_VERSION12 
    FOREIGN KEY (Product_Version_ID)
    REFERENCES PRODUCT_VERSION(Product_Version_ID)
go


/* 
 * TABLE: PRODUCT_ELIGIBILITY 
 */

ALTER TABLE PRODUCT_ELIGIBILITY ADD CONSTRAINT RefPRODUCT_COMPONENT53 
    FOREIGN KEY (Product_Component_ID)
    REFERENCES PRODUCT_COMPONENT(Product_Component_ID)
go

ALTER TABLE PRODUCT_ELIGIBILITY ADD CONSTRAINT RefORGANIZATION2 
    FOREIGN KEY (Organization_ID)
    REFERENCES ORGANIZATION(Organization_ID)
go


/* 
 * TABLE: PRODUCT_INSTALLATION 
 */

ALTER TABLE PRODUCT_INSTALLATION ADD CONSTRAINT RefINSTALL_USER118 
    FOREIGN KEY (Install_User_ID)
    REFERENCES INSTALL_USER(Install_User_ID)
go

ALTER TABLE PRODUCT_INSTALLATION ADD CONSTRAINT RefLICENSE_TYPE119 
    FOREIGN KEY (License_Type_Cd)
    REFERENCES LICENSE_TYPE(License_Type_Cd)
go

ALTER TABLE PRODUCT_INSTALLATION ADD CONSTRAINT RefSERVER42 
    FOREIGN KEY (Server_ID)
    REFERENCES SERVER(Server_ID)
go

ALTER TABLE PRODUCT_INSTALLATION ADD CONSTRAINT RefORGANIZATION47 
    FOREIGN KEY (Organization_ID)
    REFERENCES ORGANIZATION(Organization_ID)
go

ALTER TABLE PRODUCT_INSTALLATION ADD CONSTRAINT RefPRODUCT_COMPONENT52 
    FOREIGN KEY (Product_Component_ID)
    REFERENCES PRODUCT_COMPONENT(Product_Component_ID)
go

ALTER TABLE PRODUCT_INSTALLATION ADD CONSTRAINT RefENVIRONMENT_TYPE66 
    FOREIGN KEY (Environment_Type_Cd)
    REFERENCES ENVIRONMENT_TYPE(Environment_Type_Cd)
go

ALTER TABLE PRODUCT_INSTALLATION ADD CONSTRAINT RefINSTALL_STATE98 
    FOREIGN KEY (Install_State_Cd)
    REFERENCES INSTALL_STATE(Install_State_Cd)
go


/* 
 * TABLE: PRODUCT_VERSION 
 */

ALTER TABLE PRODUCT_VERSION ADD CONSTRAINT RefPRODUCT4 
    FOREIGN KEY (Product_ID)
    REFERENCES PRODUCT(Product_ID)
go


/* 
 * TABLE: RELATED_SERVER 
 */

ALTER TABLE RELATED_SERVER ADD CONSTRAINT RefSERVER95 
    FOREIGN KEY (Server_ID)
    REFERENCES SERVER(Server_ID)
go

ALTER TABLE RELATED_SERVER ADD CONSTRAINT RefSERVER96 
    FOREIGN KEY (Related_Server_ID)
    REFERENCES SERVER(Server_ID)
go

ALTER TABLE RELATED_SERVER ADD CONSTRAINT RefSERVER_RELATIONSHIP97 
    FOREIGN KEY (Server_Relationship_Cd)
    REFERENCES SERVER_RELATIONSHIP(Server_Relationship_Cd)
go


/* 
 * TABLE: SCHEDULE 
 */

ALTER TABLE SCHEDULE ADD CONSTRAINT RefORGANIZATION99 
    FOREIGN KEY (Organization_ID)
    REFERENCES ORGANIZATION(Organization_ID)
go


/* 
 * TABLE: SCHEDULE_DETAIL 
 */

ALTER TABLE SCHEDULE_DETAIL ADD CONSTRAINT RefSCHEDULE100 
    FOREIGN KEY (Schedule_ID)
    REFERENCES SCHEDULE(Schedule_ID)
go

ALTER TABLE SCHEDULE_DETAIL ADD CONSTRAINT RefJOB101 
    FOREIGN KEY (Job_ID)
    REFERENCES JOB(Job_ID)
go


/* 
 * TABLE: SERVER 
 */

ALTER TABLE SERVER ADD CONSTRAINT RefENVIRONMENT_TYPE89 
    FOREIGN KEY (Environment_Type_Cd)
    REFERENCES ENVIRONMENT_TYPE(Environment_Type_Cd)
go


/* 
 * TABLE: TASK 
 */

ALTER TABLE TASK ADD CONSTRAINT RefJOB39 
    FOREIGN KEY (Job_ID)
    REFERENCES JOB(Job_ID)
go

ALTER TABLE TASK ADD CONSTRAINT RefTASK_TYPE71 
    FOREIGN KEY (Task_Type_Cd)
    REFERENCES TASK_TYPE(Task_Type_Cd)
go

ALTER TABLE TASK ADD CONSTRAINT RefTASK91 
    FOREIGN KEY (Rollback_Task_ID)
    REFERENCES TASK(Task_ID)
go

ALTER TABLE TASK ADD CONSTRAINT RefCONTACT113 
    FOREIGN KEY (Default_Contact_ID)
    REFERENCES CONTACT(Contact_ID)
go


/* 
 * TABLE: TASK_INSTANCE 
 */

ALTER TABLE TASK_INSTANCE ADD CONSTRAINT RefORGANIZATION38 
    FOREIGN KEY (Organization_ID)
    REFERENCES ORGANIZATION(Organization_ID)
go

ALTER TABLE TASK_INSTANCE ADD CONSTRAINT RefSERVER67 
    FOREIGN KEY (Server_ID)
    REFERENCES SERVER(Server_ID)
go

ALTER TABLE TASK_INSTANCE ADD CONSTRAINT RefTASK_STATUS20 
    FOREIGN KEY (Task_Status_Cd)
    REFERENCES TASK_STATUS(Task_Status_Cd)
go

ALTER TABLE TASK_INSTANCE ADD CONSTRAINT RefTASK29 
    FOREIGN KEY (Task_ID)
    REFERENCES TASK(Task_ID)
go


/* 
 * TABLE: TASK_LOG 
 */

ALTER TABLE TASK_LOG ADD CONSTRAINT RefTASK_INSTANCE19 
    FOREIGN KEY (Task_Instance_ID)
    REFERENCES TASK_INSTANCE(Task_Instance_ID)
go

ALTER TABLE TASK_LOG ADD CONSTRAINT RefTASK_STATUS21 
    FOREIGN KEY (Task_Status_Cd)
    REFERENCES TASK_STATUS(Task_Status_Cd)
go


