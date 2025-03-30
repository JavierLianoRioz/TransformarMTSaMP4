class VideoConverter {
    [string]$ScriptDirectory
    [string]$InputDirectory
    [string]$OutputDirectory

    VideoConverter([string]$scriptDirectory, [string]$inputDirectory, [string]$outputDirectory) {
        $this.ScriptDirectory = $scriptDirectory
        $this.InputDirectory = $inputDirectory
        $this.OutputDirectory = $outputDirectory
    }

    [string[]] GetPendingMtsFiles() {
        if (-not (Test-Path -Path $this.InputDirectory)) {
            Write-Host "Input directory '$($this.InputDirectory)' does not exist. Creating it..."
            New-Item -ItemType Directory -Path $this.InputDirectory | Out-Null
            Write-Host "Input directory created."
            return @()
        }

        $pendingFiles = Get-ChildItem -Path $this.InputDirectory -Filter *.mts -Recurse | Where-Object {
            $_.Extension -ieq '.mts' -and -not (Test-Path (Join-Path -Path $this.OutputDirectory -ChildPath ([System.IO.Path]::GetFileNameWithoutExtension($_.Name) + ".mp4")))
        } | Select-Object -ExpandProperty FullName

        if ($pendingFiles.Count -eq 0) {
            Write-Warning "No pending .mts files found in '$($this.InputDirectory)' or they have already been converted."
            return @()
        }

        Write-Host "Found $($pendingFiles.Count) pending .mts files."
        return $pendingFiles
    }

    [void] ConvertFileToMp4([string]$inputFilePath, [string]$outputFilePath) {
        $useHardwareAcceleration = $this.IsNvidiaGpuAvailable()
        $codecOption = $useHardwareAcceleration ? "-c:v hevc_nvenc" : ""

        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = "ffmpeg"
        $processInfo.Arguments = "-i `"$inputFilePath`" $codecOption `"$outputFilePath`" -loglevel info"
        $processInfo.RedirectStandardError = $true
        $processInfo.UseShellExecute = $false
        $processInfo.CreateNoWindow = $true

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $processInfo
        $process.Start() | Out-Null

        $errorOutput = $process.StandardError
        $totalDuration = 0
        $progressPercentage = 0

        while (-not $errorOutput.EndOfStream) {
            $line = $errorOutput.ReadLine()

            if ($line -match "Duration: ([0-9]+):([0-9]+):([0-9]+)") {
                $totalDuration = [int]$matches[1] * 3600 + [int]$matches[2] * 60 + [int]$matches[3]
            }

            if ($line -match "time=([0-9]+):([0-9]+):([0-9]+)") {
                $currentTime = [int]$matches[1] * 3600 + [int]$matches[2] * 60 + [int]$matches[3]
                $progressPercentage = ($currentTime / $totalDuration) * 100
                Write-Progress -Activity "Converting file" -Status "Processing: $inputFilePath" -PercentComplete $progressPercentage
            }
        }

        $process.WaitForExit()
        Write-Progress -Activity "Converting file" -Status "Completed" -PercentComplete 100 -Completed
    }

    [bool] IsNvidiaGpuAvailable() {
        try {
            $nvidiaSmi = Get-Command nvidia-smi -ErrorAction Stop
            if ($nvidiaSmi) {
                Write-Host "NVIDIA GPU detected. Using hardware acceleration."
                return $true
            }
        } catch {
            Write-Host "No NVIDIA GPU detected. Using software encoding."
        }
        return $false
    }

    [void] EnsureOutputDirectoryExists() {
        if (-not (Test-Path -Path $this.OutputDirectory)) {
            Write-Host "Output directory does not exist. Creating it at '$($this.OutputDirectory)'..."
            New-Item -ItemType Directory -Path $this.OutputDirectory | Out-Null
            Write-Host "Output directory created."
        } else {
            Write-Host "Output directory already exists at '$($this.OutputDirectory)'."
        }
    }

    [void] ProcessPendingFiles() {
        $pendingFiles = $this.GetPendingMtsFiles()

        if ($pendingFiles.Count -eq 0) {
            Write-Warning "No files to process."
            return
        }

        $this.EnsureOutputDirectoryExists()

        foreach ($file in $pendingFiles) {
            $outputFilePath = Join-Path -Path $this.OutputDirectory -ChildPath ([System.IO.Path]::GetFileNameWithoutExtension($file) + ".mp4")
            Write-Host "Processing file: $file"
            $this.ConvertFileToMp4($file, $outputFilePath)
            Write-Host "File converted: $outputFilePath"
        }

        Write-Host "All files have been processed."
    }

    [void] Run() {
        Write-Host "Starting video conversion process..."
        $this.ProcessPendingFiles()
        Write-Host "Video conversion process completed."
    }
}

$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition
$inputDirectory = Join-Path -Path $scriptDirectory -ChildPath "input"
$outputDirectory = Join-Path -Path $scriptDirectory -ChildPath "output"

$videoConverter = [VideoConverter]::new($scriptDirectory, $inputDirectory, $outputDirectory)
$videoConverter.Run()
