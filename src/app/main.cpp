
#include <cmath>
#include <iostream>
#include <CLI/CLI.hpp>
#include <spdlog/spdlog.h>

//auto generated file by cmake
#include <internal_use_only/config.hpp>

//static const int NUM_ITEMS = 12;
//static const float_t RADIUS_OF_CIRCLE = 25.4f/2.0f;

int main(int argc, const char **argv) {
  try {
    float_t StartingX = 0; //center pt of circle
    float_t StartingY = 0;

    CLI::App app{ fmt::format("{} version {}", PCBUtilityMaths::cmake::project_name, PCBUtilityMaths::cmake::project_version) };

    uint32_t NumItems = 0;
    app.add_option("-n, --NumberOfItems", NumItems, "Number of items to place in the circle");
    float_t RadiusOfCircle = 10.0f;
    auto *has_radius = app.add_option("-r, --RadiusOfCircle",RadiusOfCircle, "Radius of circle");
    float_t DiameterOfCircle = 20.0f;
    auto *has_diameter = app.add_option("-d,--DiameterOfCircle",DiameterOfCircle, "Diameter of circle");
    has_diameter->excludes(has_radius);
    has_radius->excludes(has_diameter);
    app.add_option("-x,--startx", StartingX, "X offset");
    app.add_option("-y,--starty", StartingY, "Y offset");

    float startingAngle = 0.0f;
    app.add_option("-a, --angleOffset",startingAngle, "angle offset");

    bool show_version = false;
    app.add_flag("--version", show_version, "Show version information");


    CLI11_PARSE(app, argc, argv);

    if(has_diameter->count()) RadiusOfCircle = DiameterOfCircle/2.0f;
    float startingAngleRad = static_cast<float>(startingAngle*(3.14/180));

    if (show_version) {
      fmt::print("{}\n", PCBUtilityMaths::cmake::project_version);
      return EXIT_SUCCESS;
    }
    std::printf("Number of Items = %u\r\nRadius of Circle = %f starting Angle Offset = %f (%f)\r\n", NumItems, RadiusOfCircle, startingAngle, startingAngleRad);


    double px,py;
    for(uint32_t i=0;i<NumItems;++i) {
        float angle = static_cast<float>(2*3.14*i/NumItems);
        angle+=startingAngleRad;
        std::printf("degrees: %4.4f", (angle*180/3.14));

        px = StartingX + RadiusOfCircle * std::cos(angle);//std::cos((2*3.14*i/NumItems)+startingAngleRad);
        py = StartingY + RadiusOfCircle * std::sin(angle); //std::sin((2*3.14*i/NumItems)+startingAngleRad);
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

