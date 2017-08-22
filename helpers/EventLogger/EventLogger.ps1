class EventLogger
{
    ###########################################################################
    # Static properties
    ###########################################################################

    static [string] $EventDelimiter

    ###########################################################################
    # Constructors
    ###########################################################################

    static EventLogger()
    {
        # Create event delimiter line
        [EventLogger]::EventDelimiter = (
            [EventLogger]::GetDelimiterLine('-', 120))
    }

    ###########################################################################
    # Loggers
    ###########################################################################

    # Logs an event
    static LogEvent([LoggedEventLevel] $Level, $Data)
    { 
        $_eventData = (Get-PSCallStack)[2]

        if ($Level -eq [LoggedEventLevel]::Exception)
        {
            if ($Data.MainMessage) { $_message = $Data.MainMessage}
            else { $_message = $Data.Message }

            $_event = (
                New-Object -Type PSCustomObject -Property (
                    [ordered] @{
                        Level = $Level;
                        Exception = $Data;
                        Type = $Data.GetType().FullName;
                        Message  = $_message;
                        Location = $_eventData.Location;
                        SourceFunction = $_eventData.FunctionName;
                    }))
        }
        else
        {
            $_event = (
                New-Object -Type PSCustomObject -Property (
                    [ordered] @{
                        Level = $Level;
                        Message  = $Data;
                        Location = $_eventData.Location;
                        SourceFunction = $_eventData.FunctionName;
                    }))
        }

        [EventLogger]::ShowEvent($_event)
    }

    # Logs an exception
    static [void] LogException([System.Exception] $Exception)
    {
        [EventLogger]::LogEvent([LoggedEventLevel]::Exception, $Exception)
    }

    # Proxy method for logging a debug event
    static LogDebug([string] $Data)
    {
        if ([bool] (Write-Debug ([String]::Empty) 5>&1))
        {
            [EventLogger]::LogEvent([LoggedEventLevel]::Debug, $Data)
        }        
    }

    # Proxy method for logging a verbose event
    static LogVerbose([string] $Data)
    {
        if ([bool] (Write-Verbose ([String]::Empty) 4>&1))
        {
            [EventLogger]::LogEvent([LoggedEventLevel]::Verbose, $Data)
        }
    }

    # Proxy method for logging a verbose event
    static LogInformation([string] $Data)
    {
        [EventLogger]::LogEvent([LoggedEventLevel]::Information, $Data)
    }

    # Proxy method for logging an error event
    static LogWarning([string] $Data)
    {
        if ([bool] (Write-Warning ([String]::Empty) 3>&1))
        {
            [EventLogger]::LogEvent([LoggedEventLevel]::Warning, $Data)
        } 
    }

    # Proxy method for logging an error event
    static LogError([string] $Data)
    {
        if ([bool] (Write-Error ([String]::Empty) 2>&1))
        {
            [EventLogger]::LogEvent([LoggedEventLevel]::Error, $Data)
        } 
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Returns a string which contains a single character repeated as many times
    # as needed to fill the console width.
    static [string] GetDelimiterLine([char] $Character, [int] $Width)
    {
        [System.Text.StringBuilder] $_sb = (
            [System.Text.StringBuilder]::new("", $Width))

        for ($i = 0; $i -lt $Width; $i++)
        {
            $_sb.Append($Character)
        }

        return $_sb.ToString()
    }

    ###########################################################################
    # Dumpers
    ###########################################################################

    # Shows a single event on the console
    # Dumps the whole event log to the console then flushes the event log.
    static [void] ShowEvent([PSCustomObject] $Event)
    {
        if ($Event.Level -eq "Exception")
        {
            Write-Host -ForegroundColor DarkRed ([EventLogger]::EventDelimiter)
        }

        Write-Host -NoNewLine -ForegroundColor Gray "["
        
        switch ($Event.Level)
        {
            "Debug"
            {
                Write-Host -NoNewLine -ForegroundColor DarkGray "  DEBUG  "
            }

            "Verbose"
            {
                Write-Host -NoNewLine -ForegroundColor Cyan " VERBOSE "
            }

            "Information"
            {
                Write-Host -NoNewLine -ForegroundColor Cyan "  INFO   "
            }

            "Warning"
            {
                Write-Host -NoNewLine -ForegroundColor Yellow " WARNING "
            }

            "Error"
            {
                Write-Host -NoNewLine -ForegroundColor DarkRed "  ERROR  "
            }

            "Exception"
            {
                Write-Host -NoNewLine -ForegroundColor Red "EXCEPTION"
            }
        }

        Write-Host -NoNewLine -ForegroundColor White "] "

        if ($Event.Level -eq "Exception")
        {
            Write-Host `
                -ForegroundColor Black `
                -BackgroundColor DarkRed `
                $($Event.Exception.GetType().FullName)
            Write-Host -NoNewLine "            "
        }
        
        Write-Host -NoNewLine -ForegroundColor White "("
        Write-Host -NoNewLine -ForegroundColor DarkGray $Event.SourceFunction
        Write-Host -NoNewLine -ForegroundColor White ", "
        Write-Host -NoNewLine -ForegroundColor DarkGray $Event.Location
        Write-Host -NoNewLine -ForegroundColor White ")"

        if ($Event.Level -eq "Exception")
        {
            Write-Host ""
            Write-Host -NoNewLine "            "
            Write-Host -ForegroundColor White $Event.Message
            foreach ($_submessage in $Event.Exception.SubMessages)
            {
                Write-Host "            `t"$_submessage
            }
            Write-Host -ForegroundColor DarkRed ([EventLogger]::EventDelimiter)
        }
        else
        {
            Write-Host -NoNewLine -ForegroundColor White ": "
            Write-Host $Event.Message
        }
    }
}

Enum LoggedEventLevel
{
    Debug
    Error
    Verbose
    Information
    Warning
    Exception
}