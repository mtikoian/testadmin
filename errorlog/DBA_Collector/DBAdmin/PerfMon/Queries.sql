SELECT	fcd.CounterHour,
		dc.CounterName,
		dc.InstanceName,
		dc.ObjectName,
		AVG(fcd.CounterValue) AvgCounterValue,
		MAX(fcd.CounterValue) MaxCounterValue,
		MIN(fcd.CounterValue) MinCounterValue
FROM	PerfMon.factCounterData fcd
			JOIN PerfMon.dimCounter dc
				ON fcd.CounterKey = dc.CounterKey
				--AND dc.ObjectName = 'PhysicalDisk'
				--AND dc.CounterName LIKE 'Avg%'
				AND dc.MachineName = 'IMUBI'
				AND DATEPART(dw,fcd.CounterDate) NOT IN (1,7)
				AND fcd.CounterHour BETWEEN 7 AND 18
GROUP BY	fcd.CounterHour,
			dc.CounterName,
			dc.InstanceName,
			dc.ObjectName	
ORDER BY	fcd.CounterHour,
			dc.ObjectName,
			dc.InstanceName,
			dc.CounterName