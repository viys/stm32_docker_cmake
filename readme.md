# stm32_docker_cmake

使用 Docker Compose 在容器内完成 CMake 配置与构建的脚本说明。核心入口为 `build.ps1`。

## 依赖

- 已安装 Docker，且 `docker` 已加入 PATH
- 可用的 Docker Compose（`docker compose` 子命令）

## 使用方式

在仓库根目录执行：

```powershell
# 生成 build 目录并进行 CMake 配置（Debug）
.\build.ps1 cmake

# 编译（默认并行度为本机 CPU 核心数）
.\build.ps1 make

# 只清理构建产物（等价于 cmake --build . --target clean）
.\build.ps1 clean

# 删除 build 目录
.\build.ps1 delete
```

## 行为说明

- `cmake`：在容器内执行 `cmake .. -DCMAKE_BUILD_TYPE=Debug`，生成 `build` 目录。
- `make`：在容器内执行 `cmake --build . --parallel N`，完成编译。
- `clean`：在容器内执行 `cmake --build . --target clean`。
- `delete`：删除本地 `build` 目录。

## 并行度设置

脚本默认使用本机 CPU 核心数作为并行度。可在同一 PowerShell 会话中手动设置：

```powershell
$Jobs = 8
.\build.ps1 make
```

## 常见问题

- 报错 “CMake has not been configured yet.”：先执行 `.\build.ps1 cmake`。
- 报错 “Docker 未安装或未加入 PATH”：请确认 Docker 已安装且命令可用。
