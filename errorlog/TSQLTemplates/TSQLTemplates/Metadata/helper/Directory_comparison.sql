set nocount on


create table #Dir1 (
    FileNm      varchar(255)
);

create table #Dir2 (
    FileNm      varchar(255)
);

insert into #Dir1
execute xp_CmdShell 'dir C:\A\Workspace\CodeReview\2013\2013_06\3589770\Review_1\Procedures_Main /b'

insert into #Dir2
execute xp_CmdShell 'dir C:\A\Workspace\CodeReview\2013\2013_06\3589770\Review_1\Rollback /b'


select  d1.FileNm as SQLScripts,
        d2.FileNm as RollbackScripts
from #Dir1 d1
    full outer join #Dir2 d2 on d2.FileNm = d1.FileNm
where d1.FileNm is not null
  or d2.FileNm is not null
order by 
    case 
        when d1.FileNm is not null then d1.FileNm
        else d2.FileNm
    end


drop table #Dir1 
drop table #Dir2       