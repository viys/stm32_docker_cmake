param (
    [Parameter(Position = 0, Mandatory)]
    [ValidateSet("cmake", "make", "clean", "delete")]
    [string]$Action
)


$ErrorActionPreference = "Stop"

function Assert-Docker {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        throw "Docker 未安装或未加入 PATH"
    }
    docker info | Out-Null
}

function Invoke-CMake {
    $cmd = "mkdir -p build; cd build; cmake .. -DCMAKE_BUILD_TYPE=Debug"

    docker compose run --rm stm32 bash -lc $cmd
}

function Invoke-Make {
    param(
        [string]$Clean
    )

    # 并行度兜底：优先用 $Jobs，否则用本机 CPU 核心数
    if (-not $script:Jobs -or $script:Jobs -le 0) {
        $script:Jobs = [Environment]::ProcessorCount
    }

    # 组装 cmake build 命令（数组方式，避免引号/转义问题）
    $cmd = @(
        "cmake", "--build", ".", "--parallel", "$script:Jobs"
    )

    if ($Clean) {
        # 这里的 $Clean 可以是 "clean" 或者你自定义的 target 名
        $cmd += @("--target", $Clean)
    }

    # 用 docker compose 在容器内执行
    # -T: 禁用 TTY，PowerShell 下更稳定地输出日志
    # -w: 指定工作目录（不依赖 cd &&）
    docker compose run --rm -w /workspace/build stm32 @cmd

    if (-not $Clean) {
        Write-Host "Build time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    }
}

function Invoke-Delete {
    param(
        [string]$BuildDir = "build"
    )

    $fullPath = Join-Path (Get-Location) $BuildDir

    if (-not (Test-Path $fullPath)) {
        Write-Host "Build directory not found: $fullPath" -ForegroundColor Yellow
        return
    }

    Write-Host "Deleting build directory: $fullPath" -ForegroundColor Cyan

    Remove-Item -Recurse -Force $fullPath

    Write-Host "Build directory deleted." -ForegroundColor Green
}

function Test-CMakeConfigured {
    param(
        [string]$BuildDir = "build"
    )

    $cacheFile = Join-Path (Get-Location) "$BuildDir/CMakeCache.txt"

    if (Test-Path $cacheFile) {
        return $true
    }

    Write-Host ""
    Write-Host "ERROR: CMake has not been configured yet." -ForegroundColor Red
    Write-Host "Missing file: $cacheFile" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "Hint:" -ForegroundColor Yellow
    Write-Host "  Run: build.ps1 cmake" -ForegroundColor Cyan
    Write-Host ""

    return $false
}

Assert-Docker

try {
    switch ($Action) {
        "cmake" {
            Invoke-CMake
        }
        "make" {
            if (-not (Test-CMakeConfigured)) {
                return
            }
            Invoke-Make
        }
        "clean" {
            if (-not (Test-CMakeConfigured)) {
                return
            }
            Invoke-Make -Clean "clean"
        }
        "delete" {
            Invoke-Delete
        }
        Default {}
    }
} finally {
    Pop-Location
}