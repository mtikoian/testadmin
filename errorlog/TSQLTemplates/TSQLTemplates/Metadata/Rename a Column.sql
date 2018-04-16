

begin try

    EXEC sp_rename 'CodeRev.Code_Review_Detail_Note.Defect_Category', 'Defect_Category_Cd', 'COLUMN'
	
end try
begin catch
	select error_number(),
	        error_message()
end catch               