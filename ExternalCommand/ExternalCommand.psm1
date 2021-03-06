function Invoke-ExternalCommand
{
    <#
    .SYNOPSIS
    This is a helper function that runs a external executable binary and checks
    exit code for success to see if an error occurred. If an non 0 exit code is
    detected then an exception is thrown by default. It also properly creates
    and escapes arguments supplied via Arguments array parameter. Supports UTF8
    and whitespace in the argument values.
    .PARAMETER Command
    Executable name/command to run. Must be available at PATH env var or you can specify full path to the binary.
    .PARAMETER Arguments
    Arguments string array to path to Command as arguments
    .PARAMETER HideArguments
    List indexes (starting with 0) of arguments you would like to obscure in the message that command and its
    arguments that being executed.
    .PARAMETER DontEscapeArguments
    List indexes (starting with 0) of arguments you would like to skip escape logic on. 
    When used, unless is a simple argument it's on you to escape it correctly
    .PARAMETER OutVarStdout
    Provide variable name that will be used to save STDOUT output of the command execution.
    .PARAMETER OutVarStderr
    Provide variable name that will be used to save STDERR output of the command execution.
    .PARAMETER OutVarCode
    Provide variable name that will be used to save process exit code.
    .PARAMETER Return
    By default this function returns $null, if specified you will get this object:
    @{Stdout="Contains Stdout",Stderr="Contains Stderr",All="Stdout and Stderr output as it was generated",Code="Int from process exit code"}
    Stdout output sequence order is guaranteed, while Stderr lines sequence might be out of order (eventing nature?).
    .PARAMETER IgnoreExitCode
    Specify if you expect non 0 exit code from the Command and would like to avoid non 0 exit code exception.
    .PARAMETER HideStdout
    Specify if don't want STDOUT to be written to the host
    .PARAMETER HideStderr
    Specify if don't want STDERR to be written to the host
    .PARAMETER HideCommand
    Specify if don't want `Running command` informational message to be written to the host STDERR
    .EXAMPLE
    > Invoke-ExternalCommand -Command git -Arguments version
    Running command [ C:\Program Files\Git\cmd\git.exe ] with arguments: "version"
    git version 2.20.1.windows.1

    > Invoke-ExternalCommand -Command helm -Arguments version,--client
    Running command [ C:\ProgramData\chocolatey\bin\helm.exe ] with arguments: "version" "--client"
    Client: &version.Version{SemVer:"v2.12.2", GitCommit:"7d2b0c73d734f6586ed222a567c5d103fed435be", GitTreeState:"clean"}

    > Invoke-ExternalCommand -Command helm -Arguments versiondd,--client
    Running command [ C:\ProgramData\chocolatey\bin\helm.exe ] with arguments: "versiondd" "--client"
    Error: unknown command "versiondd" for "helm"
    Did you mean this?


        version
    Run 'helm --help' for usage.

    Command returned non zero exit code of '1'. Command: helm
    At C:\Users\user\dev\ps-modules\Igloo.Powershell.ExternalCommand\Igloo.Powershell.ExternalCommand.psm1:237 char:9
    +         throw ([string]::Format("Command returned non zero exit code  ...
    +         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (Command returne.... Command: helm:String) [], RuntimeException
    + FullyQualifiedErrorId : Command returned non zero exit code of '1'. Command: helm
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = 1)][string]$Command,
        [string[]]$Arguments = @(),
        [int[]]$HideArguments = @(),
        [int[]]$DontEscapeArguments = @(),
        [string]$OutVarStdout = $null,
        [string]$OutVarStderr = $null,
        [string]$OutVarCode = $null,
        [switch]$Return,
        [switch]$IgnoreExitCode,
        [switch]$HideStdout,
        [switch]$HideStderr,
        [switch]$HideCommand
    )
    # setting desired $ErrorActionPreference, backup old one
    $OldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Stop"

    $CommandObject = (Get-Command $Command -CommandType Application -ErrorAction Ignore | Select-Object -First 1)
    if (!$CommandObject)
    {
        throw "Invalid application name\path provided (Cmdlets not supported): $Command"
    }

    # for debug info hiding args
    # looping through all arguments
    $ArgsToShow = New-Object System.Collections.Generic.List[String]

    for ($i = 0; $i -lt $Arguments.length; $i++)
    {
        # replacing sensitive arguments with "<sensitive>"
        if ($HideArguments -contains $i)
        {
            $ArgsToShow.Add("<sensitive>")
        }
        else
        {
            $ArgsToShow.Add($Arguments[$i])
        }
    }
    if ($ArgsToShow.Length -gt 0)
    {
        $ArgsToShow = (EscapeArguments -Arguments $ArgsToShow -DontEscapeArguments $DontEscapeArguments)
    }
    # Displaying what will be executed
    if (!$HideCommand)
    {
        # output to STDERR not to corrupt STDOUT
        [Console]::Error.WriteLine([string]::Format("Running command [{0}] with arguments: {1}", $CommandObject.Source, $ArgsToShow -join " "))
    }

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    # Full pth to the binary
    $pinfo.FileName = $CommandObject.Source
    # enable UTF-8 Support and redirecting STDERR and STDOUT
    $pinfo.StandardOutputEncoding = New-Object System.Text.UTF8Encoding $false
    $pinfo.StandardErrorEncoding = New-Object System.Text.UTF8Encoding $false
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true

    # please no shell
    $pinfo.UseShellExecute = $false

    # set process working directory
    $pinfo.WorkingDirectory = (Get-Location).Path

    # adding arguments if needed
    if ($Arguments.Length -gt 0)
    {
        $pinfo.Arguments = (EscapeArguments -Arguments $Arguments -DontEscapeArguments $DontEscapeArguments)
    }

    # Creating process
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo

    # https://xiaalex.wordpress.com/2013/05/03/use-asynchronous-read-on-standard-output-of-a-process/

    # object in which we will capture STDOUT and STDERR
    $Results = @{
        Stderr     = ""
        Stdout     = ""
        All        = ""
        Code       = 0
        HideStderr = $HideStderr
    }

    # Event handler for STDERR lines
    # Additional output handler to print STDERR into console realtime and capture it into var
    $ErrAction = {
        $EventData = $Event.SourceEventArgs.Data
        if (![String]::IsNullOrWhiteSpace($EventData))
        {
            $Event.MessageData.Stderr += "$EventData`n"
            $Event.MessageData.All += "$EventData`n"
            if (!$Event.MessageData.HideStderr)
            {
                [Console]::Error.WriteLine($EventData)
            }
        }
    }

    # STDOUT might get captured out of sequence
    $ErrEvent = Register-ObjectEvent -InputObject $p -EventName ErrorDataReceived -Action $ErrAction -MessageData $Results
    # Start command process
    $p.Start() | Out-Null

    # Start triggering events for STDERR
    $p.BeginErrorReadLine();

    # running until process have exited and ErrorDataReceived events are done and no more data in StandardOutput stream
    do
    {
        # capturing STDOUT this way guaranties sequence of lines (important)
        $StdoutLine = $p.StandardOutput.ReadLine()
        if ($null -ne $StdoutLine)
        {
            if (!$HideStdout)
            {
                Write-Host $StdoutLine -ForegroundColor Green
            }
            $Results.Stdout += $StdoutLine
            $Results.All += $StdoutLine
            if (!$p.StandardOutput.EndOfStream)
            {
                # dont add new line at the end
                $Results.Stdout += "`n"
                $Results.All += "`n"
            }
        }
    } while (!$p.HasExited -or !$ErrEvent.HasMoreData -or !$p.StandardOutput.EndOfStream)
    Unregister-Event -SourceIdentifier $ErrEvent.Name

    # Cleanup flag we used in the error event handler
    $Results.Remove('HideStderr')

    # Some Trimming
    $Results.Stderr = $Results.Stderr.TrimEnd("`n")
    $Results.All = $Results.All.TrimEnd("`n")

    # Saving exit code
    $Results.Code = $p.ExitCode

    # Exit code check if not asked to ignore it
    if ( ($Results.Code -ne 0) -and !$IgnoreExitCode)
    {
        throw ([string]::Format("Command returned non zero exit code of '{0}'. Command: {1}`nSTDERR: {2}", $p.ExitCode, $Command, $Results.Stderr))
    }

    # Setting OutVarCode variable if requested
    if ($OutVarCode)
    {
        $PSCmdlet.SessionState.PSVariable.Set($OutVarCode, $Results.Code)
    }

    # Setting OutVarStderr variable if requested
    if ($OutVarStderr)
    {
        $PSCmdlet.SessionState.PSVariable.Set($OutVarStderr, $Results.Stderr)
    }

    # Setting OutVarStdout variable if requested
    if ($OutVarStdout)
    {
        $PSCmdlet.SessionState.PSVariable.Set($OutVarStdout, $Results.Stdout)
    }

    # Restoring $ErrorActionPreference on success
    $ErrorActionPreference = $OldErrorActionPreference

    # Returning if requested
    if ($Return)
    {
        return $Results
    }
    return $null
}


function EscapeArguments
{
    <#
    .SYNOPSIS
    Utility function to convert list of arguments from array of string to properly escaped string of arguments
    .PARAMETER Arguments
    Array of stings with arguments values
    .PARAMETER DontEscapeArguments
    List indexes (starting with 0) of arguments you would like to skip escape logic on. 
    #>
    param (
        [string[]]$Arguments,
        [int[]]$DontEscapeArguments = @()
    )
    $EscapedArguments = New-Object System.Collections.Generic.List[String]
    $ArgPosition = -1
    foreach ($EscapedArg in $Arguments)
    {
        $ArgPosition++
        if ($DontEscapeArguments.Contains($ArgPosition))
        {
            $EscapedArguments.Add($EscapedArg)
            Write-Host "Unescaped Arguments: $EscapedArg"    
            continue
        }
        # https://docs.microsoft.com/en-gb/windows/desktop/api/shellapi/nf-shellapi-commandlinetoargvw
        # https://stackoverflow.com/questions/21314633/how-do-i-pass-a-literal-double-quote-from-powershell-to-a-native-command

        # stdlib Rules: 
        # 2N backslashes + " ==> N backslashes and begin/end quote
        # 2N+1 backslashes + " ==> N backslashes + literal " 
        # N backslashes ==> N backslashes

        # escaping double quotes as we use them to indicate start/end of argument
        $EscapedArg = $EscapedArg.Replace('"', '\"')

        # double all the slashes followed by \" (no more org before quote, so quote is never end/begin arg char)
        $EscapedArg = $EscapedArg -replace '(\\+)\\\"', '$1$1\"'

        # double all the slashes at the end of the argument
        $EscapedArg = $EscapedArg -replace '(\\+)$', '$1$1'

        # wrapping argument
        $EscapedArg = "`"$EscapedArg`""

        # appending to result
        $EscapedArguments.Add($EscapedArg)
        Write-Verbose "Escaped Arguments: $EscapedArg"

    }
    return $EscapedArguments -join " "
}