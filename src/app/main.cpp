
#include <cmath>
#include <iostream>
#include <CLI/CLI.hpp>
#include <spdlog/spdlog.h>

//auto generated file by cmake
#include <internal_use_only/config.hpp>

//static const int NUM_ITEMS = 12;
//static const float_t RADIUS_OF_CIRCLE = 25.4f/2.0f;
static float StartingX = 0; //center pt of circle
static float StartingY = 0;

int main(int argc, const char **argv) {
  try {
    CLI::App app{ fmt::format("{} version {}", myproject::cmake::project_name, myproject::cmake::project_version) };

    uint32_t NumItems = 0;
    app.add_option("-n, --NumberOfItems", NumItems, "Number of items to place in the circle");
    float_t RadiusOfCircle = 10.0f;
    auto *has_radius = app.add_option("-r, --RadiusOfCircle",RadiusOfCircle, "Radius of circle");
    float_t DiameterOfCircle = 20.0f;
    auto *has_diameter = app.add_option("-d,--DiameterOfCircle",DiameterOfCircle, "Diameter of circle");
    has_diameter->excludes(has_radius);
    has_radius->excludes(has_diameter);


    bool show_version = false;
    app.add_flag("--version", show_version, "Show version information");


    CLI11_PARSE(app, argc, argv);

    if(has_diameter->count()) RadiusOfCircle = DiameterOfCircle/2.0f;

    if (show_version) {
      fmt::print("{}\n", myproject::cmake::project_version);
      return EXIT_SUCCESS;
    }
    std::printf("Number of Items = %u\r\nRadius of Circle = %f\r\n", NumItems, RadiusOfCircle);


    double px,py;
    for(uint32_t i=0;i<NumItems;++i) {
        px = StartingX + RadiusOfCircle * std::cos(2*3.14*i/NumItems);
        py = StartingY + RadiusOfCircle * std::sin(2*3.14*i/NumItems);
        std::printf("#%u: px: %0.2f  py: %0.2f\r\n", i, px, py);
        //std::cout << "#" << i << ":  " << px << "     " << py << std::endl;
    }
    /*
    if (is_turn_based) {
      consequence_game();
    } else {
      game_iteration_canvas();
    }
    */

  } catch (const std::exception &e) {
    spdlog::error("Unhandled exception in main: {}", e.what());
  }
}

