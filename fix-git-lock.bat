@echo off
del /f "%~dp0.git\index.lock" 2>nul && echo Lock removed! || echo No lock file found.
pause
