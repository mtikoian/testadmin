param(
    [Parameter(Mandatory=$true)]
    [string]$taskScriptBlockAsString,
    <# Sample:
    $doFoo = {
        param($vsIde)

        Write-Host "foo"
        Write-Host "$($vsIde.ToString())"
    }.ToString()
    #>

    [int]$visualStudioVersion=2010
)

$taskScriptBlock = [ScriptBlock]::Create($taskScriptBlockAsString)

#References http://gallery.technet.microsoft.com/scriptcenter/9db8e065-bed4-4944-991f-058639b6de48
#http://msdn.microsoft.com/en-us/library/ms228772.aspx

function AddMessageFilter
{ 
$source = @" 
 
namespace EnvDteUtils{ 
 
using System; 
using System.Runtime.InteropServices; 
    public class MessageFilter : IOleMessageFilter 
    { 
        // 
        // Class containing the IOleMessageFilter 
        // thread error-handling functions. 
 
        // Start the filter. 
        public static void Register() 
        { 
            IOleMessageFilter newFilter = new MessageFilter();  
            IOleMessageFilter oldFilter = null;  
            CoRegisterMessageFilter(newFilter, out oldFilter); 
        } 
 
        // Done with the filter, close it. 
        public static void Revoke() 
        { 
            IOleMessageFilter oldFilter = null;  
            CoRegisterMessageFilter(null, out oldFilter); 
        } 
 
        // 
        // IOleMessageFilter functions. 
        // Handle incoming thread requests. 
        int IOleMessageFilter.HandleInComingCall(int dwCallType,  
          System.IntPtr hTaskCaller, int dwTickCount, System.IntPtr  
          lpInterfaceInfo)  
        { 
            //Return the flag SERVERCALL_ISHANDLED. 
            return 0; 
        } 
 
        // Thread call was rejected, so try again. 
        int IOleMessageFilter.RetryRejectedCall(System.IntPtr  
          hTaskCallee, int dwTickCount, int dwRejectType) 
        { 
            if (dwRejectType == 2) 
            // flag = SERVERCALL_RETRYLATER. 
            { 
                // Retry the thread call immediately if return >=0 &  
                // <100. 
                return 99; 
            } 
            // Too busy; cancel call. 
            return -1; 
        } 
 
        int IOleMessageFilter.MessagePending(System.IntPtr hTaskCallee,  
          int dwTickCount, int dwPendingType) 
        { 
            //Return the flag PENDINGMSG_WAITDEFPROCESS. 
            return 2;  
        } 
 
        // Implement the IOleMessageFilter interface. 
        [DllImport("Ole32.dll")] 
        private static extern int  
          CoRegisterMessageFilter(IOleMessageFilter newFilter, out  
          IOleMessageFilter oldFilter); 
    } 
 
    [ComImport(), Guid("00000016-0000-0000-C000-000000000046"),  
    InterfaceTypeAttribute(ComInterfaceType.InterfaceIsIUnknown)] 
    interface IOleMessageFilter  
    { 
        [PreserveSig] 
        int HandleInComingCall(  
            int dwCallType,  
            IntPtr hTaskCaller,  
            int dwTickCount,  
            IntPtr lpInterfaceInfo); 
 
        [PreserveSig] 
        int RetryRejectedCall(  
            IntPtr hTaskCallee,  
            int dwTickCount, 
            int dwRejectType); 
 
        [PreserveSig] 
        int MessagePending(  
            IntPtr hTaskCallee,  
            int dwTickCount, 
            int dwPendingType); 
    } 
} 
"@ 
 
Add-Type -TypeDefinition $source 
 
} 

AddMessageFilter

[string]$vsId = $null

if($visualStudioVersion -eq 2010){
    $vsId = "VisualStudio.DTE.10.0"
}
elseif($visualStudioVersion -eq 2012){
    $vsId = "VisualStudio.DTE.11.0"
}
else{
    throw "Unsupported Visual Studio version: $visualStudioVersion"
}

Write-Host "Utilizing Visual Studio $visualStudioVersion"
$vsIde = $null

try
{
    [EnvDTEUtils.MessageFilter]::Register() 

    try
    {        
        $vsIde = New-Object -ComObject $vsId
        &$taskScriptBlock $vsIde
    }
    finally
    {
        if($vsIde -ne $null)
        {
            Start-Sleep -Seconds 5

            try{
               $vsIde.Quit()
            }
            catch{
                Write-Host "Error quiting IDE: $($Error[0].Exception.Message)" -ForegroundColor Red

                try{
                    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($vsIde) | Out-Null
                }
                catch{
                    Write-Host "Error releasing IDE com object: $($Error[0].Exception.Message)" -ForegroundColor Red
                }
            }
        }
    }
}
finally
{
    [EnvDTEUtils.MessageFilter]::Revoke()        
}