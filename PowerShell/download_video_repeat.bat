@echo off
setlocal enabledelayedexpansion

REM Define the filename for storing defaults
set "previous_inputs=yt-dlp_script_data.txt"

REM Get the current batch file name without extension
set "script_name=%~n0"

REM Check if the default file exists, and if so, load the stored values for this script
if exist %previous_inputs% (
    for /f "tokens=1,2,3 delims=," %%a in ('findstr /b /i "%script_name%," %previous_inputs%') do (
        set "default_vodlink=%%b"
        set "default_starttime=%%c"
        set "default_duration=%%d"
    )
) else (
    REM If no default file exists, set initial defaults to empty
    set "default_vodlink="
    set "default_starttime="
    set "default_duration="
)

REM Prompt the user for the Twitch VOD link, showing previous value if available
set /p vodlink="Twitch VOD link (enter '.' for previous value [%default_vodlink%]): "
if "%vodlink%"=="." set "vodlink=%default_vodlink%"

REM Prompt the user for the initial time, showing previous value if available
set /p starttime="Twitch VOD start time (format HH:MM:SS, enter '.' for previous value [%default_starttime%]): "
if "%starttime%"=="." set "starttime=%default_starttime%"

REM Split the input time into hours, minutes, and seconds
for /f "tokens=1-3 delims=:" %%a in ("%starttime%") do (
    set "hours=%%a"
    set "minutes=%%b"
    set "seconds=%%c"
)

REM Prompt the user for the duration in minutes, showing previous value if available
set /p duration="Twitch VOD duration in minutes (enter '.' for previous value [%default_duration%]): "
if "%duration%"=="." set "duration=%default_duration%"

REM Update or add the current inputs for this script in the defaults file
> "%temp%\temp_defaults.txt" (
    for /f "usebackq delims=" %%a in ("%previous_inputs%") do (
        echo %%a | findstr /b /i "%script_name%," >nul || echo %%a
    )
    echo %script_name%,%vodlink%,%starttime%,%duration%
)
move /y "%temp%\temp_defaults.txt" "%previous_inputs%" >nul

REM Convert the duration from minutes to seconds for the timeout command
set /a duration_seconds=%duration%*60

:loop
REM Form the start timestamp
set "start_timestamp=!hours!:!minutes!:!seconds!"

REM Calculate end time by adding the duration to the start time
set /a end_minutes=!minutes!+%duration%

REM If end minutes reach 60 or more, increment hours and adjust minutes
set /a end_hours=!hours! + end_minutes / 60
set /a end_minutes=end_minutes %% 60

REM Form the end timestamp
set "end_timestamp=!end_hours!:!end_minutes!:!seconds!"

REM Run the yt-dlp command with the calculated start and end timestamps and the user-provided VOD link
start yt-dlp --download-sections "*!start_timestamp!-!end_timestamp!" -o ./yt-dlp_dump/"%%(title)s {%%(uploader)s, %%(upload_date>%%Y-%%m-%%d)s, %%(id)s, %%(section_start>%%H-%%M-%%S)s_%%(section_end>%%H-%%M-%%S)s}.%%(ext)s" %vodlink%

REM Sleep for the duration specified by the user (in seconds)
timeout /t %duration_seconds% /nobreak

REM Increment the start time by the duration for next download
set /a minutes+=%duration%

REM If minutes reach 60 or more, increment hours and reset minutes to 00
set /a hours+=minutes / 60
set /a minutes=minutes %% 60

REM Repeat the loop
goto :loop
