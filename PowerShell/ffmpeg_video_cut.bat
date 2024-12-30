@echo off
setlocal enabledelayedexpansion

REM Define the filename for storing defaults
set "previous_inputs=ffmpeg_script_data.txt"

REM Get the current batch file name without extension
set "script_name=%~n0"

REM Check if the defaults file exists, and if so, load stored values for this script
if exist %previous_inputs% (
    for /f "tokens=1,* delims=," %%a in ('findstr /b /i "{%script_name%," %previous_inputs%') do (
        set "default_filepath=%%~b"
        set "default_starttime=%%c"
        set "default_endtime=%%d"
        REM Remove surrounding quotes from variables
        set "default_filepath=!default_filepath:"=!"
        set "default_starttime=!default_starttime:"=!"
        set "default_endtime=!default_endtime:"=!"
    )
) else (
    REM If no defaults file exists, set initial defaults to empty
    set "default_filepath="
    set "default_starttime="
    set "default_endtime="
)

REM Expand variables explicitly to avoid issues in the prompts
set "default_filepath=!default_filepath!"
set "default_starttime=!default_starttime!"
set "default_endtime=!default_endtime!"

REM Prompt the user for the file path, showing previous value if available
set /p filepath="File path (enter '.' for previous value [%default_filepath%]): "
if "%filepath%"=="." set "filepath=!default_filepath!"

REM Prompt the user for the start time, showing previous value if available
set /p starttime="Start time (format HH:MM:SS, enter '.' for previous value [%default_starttime%]): "
if "%starttime%"=="." set "starttime=!default_starttime!"

REM Prompt the user for the end time, showing previous value if available
set /p endtime="End time (format HH:MM:SS, enter '.' for previous value [%default_endtime%]): "
if "%endtime%"=="." set "endtime=!default_endtime!"

REM Update or add the current inputs for this script in the defaults file
> "%temp%\temp_defaults.txt" (
    for /f "usebackq delims=" %%a in ("%previous_inputs%") do (
        echo %%a | findstr /b /i "{%script_name%," >nul || echo %%a
    )
    REM Save inputs with quotes to handle special characters in the filepath
    echo {%script_name%,"%filepath%","%starttime%","%endtime%"}
)
move /y "%temp%\temp_defaults.txt" "%previous_inputs%" >nul

REM Create the output directory if it doesn't exist
if not exist "./ffmpeg_dump/" mkdir "./ffmpeg_dump/"

REM Generate output filename with timestamped segment
for %%A in ("%filepath%") do (
    set "filename=%%~nA"
    set "extension=%%~xA"
)
set "output_filename=%filename% {%starttime%-%endtime%}%extension%"
set "output_filepath=./ffmpeg_dump/%output_filename%"

REM Run the ffmpeg command with the specified start and end timestamps
ffmpeg -y -i "%filepath%" -ss %starttime% -to %endtime% -async 1 "%output_filepath%" 2>error_log.txt

REM Display error log if ffmpeg fails, and pause to view any messages
if %errorlevel% neq 0 (
    echo.
    echo An error occurred during ffmpeg execution. Check error_log.txt for details.
)
pause
