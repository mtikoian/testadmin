#  Question - Is this an advanced function?
function Out-UdfPipeline
{

  begin
  {
   "`nWe are going to start and there is no pipeline yet."
   #  Let do something initialization like...
   [integer]$mycount = 0
  }

  process 
  {
   $_
   $mycount++
  }

  end
  {
   "`nThere are $mycount items."
  }

}

Get-ChildItem | Out-UdfPipeline
