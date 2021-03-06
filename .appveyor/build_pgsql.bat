@echo off
REM Copyright (C) 1994-2017 Altair Engineering, Inc.
REM For more information, contact Altair at www.altair.com.
REM
REM This file is part of the PBS Professional ("PBS Pro") software.
REM
REM Open Source License Information:
REM
REM PBS Pro is free software. You can redistribute it and/or modify it under the
REM terms of the GNU Affero General Public License as published by the Free
REM Software Foundation, either version 3 of the License, or (at your option) any
REM later version.
REM
REM PBS Pro is distributed in the hope that it will be useful, but WITHOUT ANY
REM WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
REM PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
REM
REM You should have received a copy of the GNU Affero General Public License along
REM with this program.  If not, see <http://www.gnu.org/licenses/>.
REM
REM Commercial License Information:
REM
REM The PBS Pro software is licensed under the terms of the GNU Affero General
REM Public License agreement ("AGPL"), except where a separate commercial license
REM agreement for PBS Pro version 14 or later has been executed in writing with Altair.
REM
REM Altair’s dual-license business model allows companies, individuals, and
REM organizations to create proprietary derivative works of PBS Pro and distribute
REM them - whether embedded or bundled with other software - under a commercial
REM license agreement.
REM
REM Use of Altair’s trademarks, including but not limited to "PBS™",
REM "PBS Professional®", and "PBS Pro™" and Altair’s logos is subject to Altair's
REM trademark licensing policies.

@echo on
setlocal

call "%~dp0set_paths.bat"

cd "%BUILDDIR%"

if not defined PGSQL_VERSION (
    echo "Please set PGSQL_VERSION to PostgreSQL version!"
    exit /b 1
)

if exist "%BINARIESDIR%\pgsql" (
    echo "%BINARIESDIR%\pgsql exist already!"
    exit /b 0
)

if not exist "%BUILDDIR%\postgresql-%PGSQL_VERSION%.tar.bz2" (
    "%CURL_BIN%" -qkL -o "%BUILDDIR%\postgresql-%PGSQL_VERSION%.tar.bz2" https://ftp.postgresql.org/pub/source/v%PGSQL_VERSION%/postgresql-%PGSQL_VERSION%.tar.bz2
    if not exist "%BUILDDIR%\postgresql-%PGSQL_VERSION%.tar.bz2" (
        echo "Failed to download postgresql"
        exit /b 1
    )
)

2>nul rd /S /Q "%BUILDDIR%\postgresql-%PGSQL_VERSION%"
"%MSYSDIR%\bin\bash" --login -i -c "cd \"$BUILDDIR_M/\" && tar -xf postgresql-%PGSQL_VERSION%.tar.bz2"
if not %ERRORLEVEL% == 0 (
    echo "Failed to extract %BUILDDIR%\postgresql-%PGSQL_VERSION%.tar.bz2"
    exit /b 1
)
if not exist "%BUILDDIR%\postgresql-%PGSQL_VERSION%" (
    echo "Could not find %BUILDDIR%\postgresql-%PGSQL_VERSION%"
    exit /b 1
)
if not exist "%BUILDDIR%\postgresql-%PGSQL_VERSION%\src\tools\msvc" (
    echo "Could not find %BUILDDIR%\postgresql-%PGSQL_VERSION%\src\tools\msvc"
    exit /b 1
)

call "%VS90COMNTOOLS%\vsvars32.bat"

cd "%BUILDDIR%\postgresql-%PGSQL_VERSION%\src\tools\msvc"

call "%BUILDDIR%\postgresql-%PGSQL_VERSION%\src\tools\msvc\build.bat"
if not %ERRORLEVEL% == 0 (
    echo "Failed to compile pgsql"
    exit /b 1
)

REM This is for Perl to find ./inc/Module/Install.pm, see header of http://cpansearch.perl.org/src/AUDREYT/Module-Install-0.64/lib/Module/Install.pm
set PERL5LIB=.
call "%BUILDDIR%\postgresql-%PGSQL_VERSION%\src\tools\msvc\install.bat" "%BINARIESDIR%\pgsql"
if not %ERRORLEVEL% == 0 (
    echo "Failed to install pgsql"
    exit /b 1
)

exit /b 0

