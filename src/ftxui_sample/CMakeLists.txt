add_executable(PCBUtilityMaths main.cpp)

target_link_libraries(
        PCBUtilityMaths
  PRIVATE PCBUtilityMaths::PCBUtilityMaths_options
          PCBUtilityMaths::PCBUtilityMaths_warnings)

target_link_system_libraries(
        PCBUtilityMaths
  PRIVATE
          CLI11::CLI11
          fmt::fmt
          spdlog::spdlog
          lefticus::tools
          ftxui::screen
          ftxui::dom
          ftxui::component)

target_include_directories(intro PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")
