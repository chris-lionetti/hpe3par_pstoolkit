####################################################################################
## 	© 2020,2021, 2023 Hewlett Packard Enterprise Development LP
##	Description: 	Task Management cmdlets 
##		

Function Get-Task
{
<#
.SYNOPSIS
  Displays information about tasks.
.DESCRIPTION
	Displays information about tasks.
.EXAMPLE
  PS:> Get-Task 
	
  Display all tasks.
.EXAMPLE
  PS:> Get-Task -All
	Display all tasks. Unless the -all option is specified, system tasks are not displayed.
.EXAMPLE		
	PS:> Get-Task -Done
	
  Display includes only tasks that are successfully completed
.EXAMPLE
	PS:> Get-Task -Failed

  Display includes only tasks that are unsuccessfully completed.
.EXAMPLE	
	PS:> Get-Task -Active
	Display includes only tasks that are currently in progress.
.EXAMPLE	
	PS:> Get-Task -Hours 10
	Show only tasks started within the past <hours>
.EXAMPLE	
	PS:> Get-Task -Task_type xyz
	Specifies that specified patterns are treated as glob-style patterns and that all tasks whose types match the specified pattern are displayed
.EXAMPLE	
	PS:> Get-Task -taskID 4
	Show detailed task status for specified task 4.
.PARAMETER All	
	Displays all tasks.
.PARAMETER Done	
	Displays only tasks that are successfully completed.
.PARAMETER Failed	
	Displays only tasks that are unsuccessfully completed.
.PARAMETER Active	
	Displays only tasks that are currently in progress
.PARAMETER Hours 
  Show only tasks started within the past <hours>, where <hours> is an integer from 1 through 99999.
.PARAMETER Task_type 
  Specifies that specified patterns are treated as glob-style patterns and that all tasks whose types match the specified pattern are displayed. To see the different task types use the showtask column help.
.PARAMETER TaskID 
  Show detailed task status for specified tasks. Tasks must be explicitly specified using their task IDs <task_ID>. Multiple task IDs can be specified. This option cannot be used in conjunction with other options.
#>
[CmdletBinding()]
param(	[String]  $TaskID,   
        [String]	$Task_type,
        [Switch]	$All,	
        [Switch]	$Done,
        [Switch]	$Failed,
        [Switch]	$Active,
        [String]	$Hours
	)		
Process	
{	$taskcmd = "showtask "
	if($TaskID)	    {	$taskcmd +=" -d $TaskID "	}
	if($Task_type)	{	$taskcmd +=" -type $Task_type "	}	
	if($All)		    {	$taskcmd +=" -all "	}
	if($Done)		    {	$taskcmd +=" -done "	}
	if($Failed)		  {	$taskcmd +=" -failed "	}
	if($Active)		  {	$taskcmd +=" -active "	}
	if($Hours)	  	{	$taskcmd +=" -t $Hours "	}	
	$result = Invoke-CLICommand -Connection $SANConnection -cmds  $taskcmd
	write-Verbose " Running get task status  with the command --> $taskcmd" 
	if($TaskID)	    {	return $result	}	
	if($Result -match "Id" )	
    {	$tempFile = [IO.Path]::GetTempFileName()
      $LastItem = $Result.Count  
      $incre = "true"
      foreach ($s in  $Result[0..$LastItem] )
        { $s= [regex]::Replace($s,"^ ","")			
          $s= [regex]::Replace($s," +",",")	
          $s= [regex]::Replace($s,"-","")			
          $s= $s.Trim() -replace 'StartTime,FinishTime','Date(ST),Time(ST),Zome(ST),Date(FT),Time(FT),Zome(FT)' 
          if($incre -eq "true") {	$s=$s.Substring(1)	}
          Add-Content -Path $tempFile -Value $s
          $incre="false"		
        }
      Import-Csv $tempFile 
      Remove-Item $tempFile
    }	
	if($Result -match "Id") {	return " Success : Executing Get-Task"  }
	else                    {	return  $Result	}	
}
}

Function Remove-Task {
<#
.SYNOPSIS
  Remove one or more tasks or task details.
.DESCRIPTION
  The Remove-Task command removes information about one or more completed tasks and their details.
.PARAMETER A
  Remove all tasks including details.
.PARAMETER D
  Remove task details only.
.PARAMETER F
  Specifies that the command is to be forced. You are not prompted for confirmation before the task is removed.
.PARAMETER T <hours>
  Removes tasks that have not been active within the past <hours>, where <hours> is an integer from 1 through 99999.
.PARAMETER TaskID
  Allows you to specify tasks to be removed using their task IDs.
.EXAMPLE
  Remove a task based on the task ID

  PS:> Remove-Task 2

  Remove the following tasks?
  2
  select q=quit y=yes n=no: y

.EXAMPLE
  Remove all tasks, including details

  PS:> Remove-Task -A

  Remove all tasks?
  select q=quit y=yes n=no: y
.NOTES
  With this command, the specified task ID and any information associated with it are removed from the system. However, task IDs 
  are not recycled, so the next task started on the system uses the next whole integer that has not already been used. Task IDs 
  roll over at 29999. The system stores information for the most recent 2000 tasks.
#>
[CmdletBinding()]
param(  [String]  $TaskID,
        [Switch]  $A,
        [Switch]  $D,
        [Switch]  $F,       
        [String]  $T
    )	
Begin
{ Test-CLIConnectionB
}   
Process
{ $cmd = "removetask "	
	if ($F) {  $cmd += " -f "  }
	else    {	Return "Force removal is only supported with the Remove-Task cmdlet."	}
  if ($TaskID) {  $cmd += "$TaskID"  }
  if ($A) {  $cmd += " -a"  }
  elseif ($D) {  $cmd += " -d"  }
  elseif ($T) {  $cmd += " -t $T"  }	
  $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
  return 	$Result	
}
} 

Function Stop-Task {
<#
.SYNOPSIS
  Cancel one or more tasks
.DESCRIPTION
  The Stop-Task command cancels one or more tasks.
.PARAMETER F
  Forces the command. The command completes the process without prompting for confirmation.
.PARAMETER ALL
  Cancels all active tasks. If not specified, a task ID(s) must be specified.
.PARAMETER TaskID
  Cancels only tasks identified by their task IDs. TaskID must be an unsigned integer within 1-29999 range.
.EXAMPLE
  Cancel a task using the task ID

  PS:> Stop-Task 1        
.NOTES
  The Stop-Task command can return before a cancellation is completed. Thus, resources reserved for a task might not be immediately available. This can
  prevent actions like restarting the canceled task. Use the waittask command to ensure orderly completion of the cancellation before taking other
  actions. See waittask for more details.

  A Service user is only allowed to cancel tasks started by that specific user.
#>
[CmdletBinding()]
param(
    [String]  $TaskID,		
    [Switch]  $F,       
    [String]  $ALL
  )	
Begin
{ Test-CLIConnectionB
}
Process
{ $cmd = "canceltask "	
  if ($F)       {  $cmd += " -f "	 }
  else          {  Return "Force cancellation is only supported with the Stop-Task cmdlet." }
  if ($TaskID)  {  $cmd += "$TaskID"  }
  if ($ALL)     {  $cmd += " -all"  }    	
  $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
  return 	$Result	
}
}

Function Wait-Task 
{
<#
.SYNOPSIS
  Wait for tasks to complete.
.DESCRIPTION
  The Wait-Task cmdlet asks the CLI to wait for a task to complete before proceeding. 
  The cmdlet automatically notifies you when the specified task is finished.
.PARAMETER V
  Displays the detailed status of the task specified by <TaskID> as it executes. When the task completes, this command exits.
.PARAMETER TaskID
  Indicates one or more tasks to wait for using their task IDs. When no task IDs are specified, the command 
  waits for all non-system tasks to complete. To wait for system tasks, <TaskID> must be specified.
.PARAMETER Q
  Quiet; do not report the end state of the tasks, only wait for them to exit.
.EXAMPLE
  The following example shows how to wait for a task using the task ID. When successful, the command returns only after the task completes.

  PS:> Wait-Task 1  
  
  Task 1 done      
.NOTES
    This cmdlet returns an error if any of the tasks it is waiting for fail.
#>
[CmdletBinding()]
param(  [Switch]  $V, 
        [String]  $TaskID,
        [Switch]  $Q
    )	
Begin	
{ Test-CLIConnectionB
}
Process
{ $cmd = "waittask "	
	if ($V)       {  $cmd += " -v "   }
  if ($TaskID)  {  $cmd += "$TaskID"}
  if ($Q)       {  $cmd += " -q"    }    	
  $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
  return 	$Result	
}
}

Export-ModuleMember Get-Task , Remove-Task , Stop-Task , Wait-Task