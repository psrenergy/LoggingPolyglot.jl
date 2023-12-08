@echo off

SET FORMATTER_DIR=%~dp0

CALL "%JULIA_194%" --project=%FORMATTER_DIR% %FORMATTER_DIR%\format.jl