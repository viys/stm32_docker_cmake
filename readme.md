# STM32 Docker cmake 工程

1. 使用 Stm32CubeMX创建 cmake 功能
2. 运行 docker
   1. docker compose up -d
   2. docker compose exec stm32 bash -c "mkdir -p build/ && cd build/ && cmake .. && make"

