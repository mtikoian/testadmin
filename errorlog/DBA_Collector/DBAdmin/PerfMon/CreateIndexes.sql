ALTER TABLE PerfMon.dimCounter ADD CONSTRAINT PK_CI_dimCounter PRIMARY KEY CLUSTERED (CounterKey);
CREATE CLUSTERED INDEX CI_factCounterData_CounterDate_CounterKey ON PerfMon.factCounterData (CounterDate, CounterKey);
CREATE NONCLUSTERED INDEX NCI_factCounterData_CounterKey ON PerfMon.factCounterData (CounterKey) INCLUDE (CounterDate,CounterHour, CounterValue);


