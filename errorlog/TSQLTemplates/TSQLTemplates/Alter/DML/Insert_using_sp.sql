USE NETIKIP
GO

declare
      @SQLErrorCode     int         ,
      @Errorcode        int         ,
      @ErrorMessage     varchar(400) 
      

exec p_Load_Table_Dimension_Date
      @Start_Date ='1900/01/01',                
      @End_Date   ='2050/12/31',                
      @Start_Date_For_Id_Calculation      = '1969-12-31',
      @Do_No_Delete_From_Table_Indicator  = 0,
      @Truncate_Table_Indicator= 1,
      @SQLErrorCode                 = @SQLErrorCode  output,
      @Errorcode                    = @Errorcode  output,
      @ErrorMessage                 = @ErrorMessage  output
      
select
      @SQLErrorCode                 ,
      @Errorcode                    ,
      @ErrorMessage           
