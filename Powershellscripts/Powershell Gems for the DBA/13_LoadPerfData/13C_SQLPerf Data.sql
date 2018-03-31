use SQLPerf
go
select * from [dbo].[DisplayToID]      -- log import details
select * from [dbo].[CounterDetails]   -- counter objects collected
select top 100 * from [dbo].[CounterData]      -- on counter data values

select * from [dbo].[PerfSummary]  -- summary table for easy reporting