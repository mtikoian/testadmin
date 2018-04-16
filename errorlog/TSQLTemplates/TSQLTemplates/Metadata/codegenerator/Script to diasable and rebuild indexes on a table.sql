
declare	@Disable table (
	Disable_IRID	int identity(1,1) primary key clustered,
	DisableCmd		varchar(250)
)

declare	@ReEnable table (
	ReEnable_IRID	int identity(1,1) primary key clustered,
	ReEnableCmd		varchar(250)
)

declare	@Min	int
declare	@Max	int
declare	@Cnt	int
declare	@Query	nvarchar(500)
declare	@Params	nvarchar(500)

begin try
	insert into @Disable (DisableCmd)
	select DisableCmd 
	from dbo.f_MetaData_Build_Disable_Index ('Date_Range_Procedure')


	insert into @ReEnable (ReEnableCmd)
	select EnableCmd 
	from dbo.f_MetaData_Build_Enable_Index ('Date_Range_Procedure')

	set @Min = (select min(Disable_IRID) from @Disable)
	set @Max = (select max(Disable_IRID) from @Disable)

	set @Cnt = @Min

	while @Cnt <= @Max begin
		set @Query = (
				select DisableCmd 
				from @Disable
				where Disable_IRID = @Cnt
					 )
					 
		exec sp_ExecuteSql @Query, @Params
		
		set @Cnt += 1
	end
	
	set @Query = ''
	set @Min = (select min(ReEnable_IRID) from @ReEnable)
	set @Max = (select max(ReEnable_IRID) from @ReEnable)

	set @Cnt = @Min

	while @Cnt <= @Max begin
		set @Query = (
				select ReEnableCmd 
				from @ReEnable
				where ReEnable_IRID = @Cnt
					 )
					 
		exec sp_ExecuteSql @Query, @Params
		
		set @Cnt += 1
	end

	
end try
begin catch
	select	error_number() as ErrorNumber,
			error_message() as ErrorMEssage,
			error_line() as ErrorLine,
			error_state() as ErrorState,
			error_severity() as ErrorSeverity,
			error_procedure() as ErrorProcedure;
end catch;