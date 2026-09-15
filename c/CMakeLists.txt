cmake_minimum_required(VERSION 4.3.1)

project(c LANGUAGES C)

set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)

add_executable(main src/main.c)
