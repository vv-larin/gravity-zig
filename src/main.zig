const rl = @import("raylib");

const Vec2 = struct {
    x: f32,
    y: f32,
};

const Planet = struct {
    position: Vec2,
    velocity: Vec2,
};

const gravitational_constant: f32 = 8e-7;
const solar_mass: f32 = 330000.0;
const physics_dt: f32 = 1.0 / 120.0;
const initial_window_width: i32 = 1000;
const initial_window_height: i32 = 700;

pub fn main() void {
    rl.setConfigFlags(.{ .window_resizable = true });
    rl.initWindow(initial_window_width, initial_window_height, "Gravity");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var earth = Planet{
        .position = .{ .x = 1.0, .y = 0.0 },
        .velocity = .{ .x = 0.0, .y = -1.0 * @sqrt(gravitational_constant * solar_mass / 1.0) },
    };

    const pixels_per_unit = 200.0;

    var accumulator: f32 = 0.0;

    while (!rl.windowShouldClose()) {
        const frame_dt = @min(rl.getFrameTime(), 0.25);
        accumulator += frame_dt;

        while (accumulator >= physics_dt) {
            updatePlanet(&earth, physics_dt);
            accumulator -= physics_dt;
        }

        const centre = rl.Vector2{
            .x = @as(f32, @floatFromInt(rl.getScreenWidth())) / 2.0,
            .y = @as(f32, @floatFromInt(rl.getScreenHeight())) / 2.0,
        };

        rl.beginDrawing();
        rl.clearBackground(.black);

        rl.drawCircleV(centre, 20.0, .yellow);

        rl.drawCircleV(.{
            .x = centre.x + earth.position.x * pixels_per_unit,
            .y = centre.y + earth.position.y * pixels_per_unit,
        }, 8.0, .sky_blue);

        rl.drawText("Press ESC to close", 20, 20, 20, .white);
        rl.endDrawing();
    }
}

fn updatePlanet(planet: *Planet, dt: f32) void {
    const x = planet.position.x;
    const y = planet.position.y;

    const distance_squared = x * x + y * y;

    if (distance_squared == 0) {
        return;
    }

    const distance = @sqrt(distance_squared);
    const acceleration = -gravitational_constant * solar_mass / distance_squared;

    planet.velocity.x += (x / distance) * acceleration * dt;
    planet.velocity.y += (y / distance) * acceleration * dt;

    planet.position.x += planet.velocity.x * dt;
    planet.position.y += planet.velocity.y * dt;
}
