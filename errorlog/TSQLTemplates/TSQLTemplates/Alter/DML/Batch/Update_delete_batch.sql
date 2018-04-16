declare @starttime datetime, @endtime datetime, @duration int,
		@status bit, @chunksize int,
		@bearableDuration int, @unbearableDuration int,
		@rowcount int

set @status = 0
set @chunksize = 100
set @bearableDuration = 100	--(ms) This value helps increase the batch/chunk size based on performance
set @unbearableDuration = 1000	--(ms) This value helps quit the transaction when there is too much delay.
				-- In this example, the program will exit when a chunk takes more than 100 ms to execute

	-- ============= Provide query to fetch the rowcount for the data to be manipulated (Modify here as needed) =
			select @rowcount = count(id)
			from detail where address  <> 'pppppppppppppppppppppppppppppppp'
								-- Rowcount for the entire batch operation
	-- ############# Rowcount query ends here ###########################################

while(@status = 0)
begin
	set @starttime=getdate()
	begin transaction
	-- ============= THE UPDATE/DELETE STATEMENT (Modify here as needed) ===============
	
		update top(@chunksize) dbo.detail
		set address = 'pppppppppppppppppppppppppppppppp'
		where address  <> 'pppppppppppppppppppppppppppppppp'

	-- ############# THE UPDATE/DELETE STATEMENT ENDS HERE ##############################
	commit transaction
	set @endtime=getdate()
	set @rowcount = @rowcount - @chunksize

	set @duration = datediff(ms, @starttime, @endtime)

	if(@duration < @bearableDuration)
	begin
		set @chunksize = @chunksize + 100
		print 'Duration: '+convert(varchar, @duration)+'. Increasing chunksize to ' + convert(varchar, @chunksize)
	end
	
	if (@duration > @unbearableDuration)
	begin
		set @status = 1
		print 'Exiting due to unbearable duration ' + convert(varchar,@duration) + ' at chunk size ' + convert(varchar, @chunksize)
	end
	
	if(@rowcount<=0)
	begin
		set @status = 1
		print 'Bulk operation has completed succesfully'
	end
end