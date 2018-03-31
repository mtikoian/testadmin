Function Get-Elapsed() {

<#
.SYNOPSIS
Compute the elapsed time in WHOLE units between BeginDate and EndDate

.DESCRIPTION

According to this calculation a time unit (like a month) has elapsed after you can add a unit to the begin datetime and still
be less than or equal to the end datetime.  In other words one whole month has passed on the same day-of-month, one month 
later as computed by the addMonth method.  As an example of the computation:

BeginDate  EndDate    Months
2000-01-15 2000-02-14      0
2000-01-15 2000-02-15      1
2000-01-15 2000-03-02      1

.PARAMETER EndDate
This is the date when the period ends.  The default is the current datetime returned by Get-Date

.PARAMETER BeginDate
This is the date when the period begins.  The default is 2007-11-19 (my start date at Involta)

.EXAMPLE
Get-Elapsed

Compute how long I've been at Involta as of $(Get-Date()).

.EXAMPLE
Get-Elapsed -BeginDate '1879-03-14'

Compute elapsed time since the birth of Albert Einstein.

.EXAMPLE
Get-Elapsed -BeginDate '1962-09-12' -EndDate '1969-07-20'

Compute elapsed time from JFK's "Man on the Moon" speech until man landed on the moon.
#>
   Param (
      [Parameter(Position=0,  ValueFromPipeline=$true, HelpMessage="End of the time span")]
      [datetime] $EndDate = (Get-Date),
      [Parameter(Position=1,  ValueFromPipeline=$true, HelpMessage="Beginning of the time span")]
      [datetime] $BeginDate = '2007-11-19'
      )
   PROCESS {
      $delta = [int] 12 * ($EndDate.year - $BeginDate.year) + $EndDate.month - $BeginDate.month;
      If ($BeginDate.AddMonths($delta) -gt $EndDate) { $delta-- }

      return [Ordered] @{
         days = ($EndDate - $BeginDate).days;
         weeks = [math]::Truncate(($EndDate - $BeginDate).days / 7);
         months = $delta; 
         quarters = [math]::Truncate($delta / 3); 
         years = [math]::Truncate($delta / 12); 
         beginDate = $BeginDate; 
         endDate = $EndDate
         }
      }
}