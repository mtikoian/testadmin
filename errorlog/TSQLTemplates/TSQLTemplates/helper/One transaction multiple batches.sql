use utility
go

create table #Errors (
    RowId   int identity(1,1) primary key clustered,
    ErrNum  int,
    ErrMsg  varchar(400),
    LineNum int
)       
            
begin transaction            
    
begin try
    create nonclustered index IX_Testy1_C21
        on dbo.Testy1(C2);
    
    create nonclustered index IX_Testy1_C32
        on dbo.Testy1(C3);
	
end try
begin catch
    insert into #Errors (
            ErrNum,
            ErrMsg,
            LineNum
    )
    select  error_number(),
            error_message(),
            error_line()
            
    select @@trancount as TransactionCount
	
	select	error_number() as ErrorNumber,
			error_message() as ErrorMEssage,
			error_line() as ErrorLine,
			error_state() as ErrorState,
			error_severity() as ErrorSeverity,
			error_procedure() as ErrorProcedure;
end catch;
go

select error_number() as CurrentErr
go

begin try
    select 1/0	
end try
begin catch
    insert into #Errors (
            ErrNum,
            ErrMsg,
            LineNum
    )
    select  error_number(),
            error_message(),
            error_line()
            
    select @@trancount as TransactionCount
	
	select	error_number() as ErrorNumber,
			error_message() as ErrorMEssage,
			error_line() as ErrorLine,
			error_state() as ErrorState,
			error_severity() as ErrorSeverity,
			error_procedure() as ErrorProcedure;
end catch;
go

if exists (select 1 from #Errors) begin
    select * from #Errors
    rollback transaction
    print 'Transaction rolled back'
end else begin 
    select * from #Errors
    commit transaction
    print 'Transaction committed'
end
