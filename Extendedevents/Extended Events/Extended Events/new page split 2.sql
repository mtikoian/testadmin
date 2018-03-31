UPDATE dbo.Financials
SET CreateDate = STUFF(STUFF(CreateDate,7,0,'/'),5,0,'/')
,OrderDate = STUFF(STUFF(OrderDate,7,0,'/'),5,0,'/')
,ReviewDate = STUFF(STUFF(ReviewDate,7,0,'/'),5,0,'/')
,ReferenceDate = STUFF(STUFF(ReferenceDate,7,0,'/'),5,0,'/')
,DennysBirthday = STUFF(STUFF(DennysBirthday,7,0,'/'),5,0,'/')
,RockstarBirthday = STUFF(STUFF(RockstarBirthday,7,0,'/'),5,0,'/')
,DataChickBirthday = STUFF(STUFF(DataChickBirthday,7,0,'/'),5,0,'/')
