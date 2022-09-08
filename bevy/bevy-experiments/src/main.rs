// disable console on windows for release builds
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use bevy::app::AppExit;
use bevy::prelude::*;
use bevy_prototype_debug_lines::*;
use heron::*;

fn main() {
    App::new()
        // setup window stuff
        .insert_resource(WindowDescriptor {
            width: 800.,
            height: 600.,
            title: "Bouncy valls".to_string(),
            ..Default::default()
        })
        .add_plugins(DefaultPlugins)
        .add_plugin(DebugLinesPlugin::default())
        // configure heron
        .add_plugin(PhysicsPlugin::default()) // Add the plugin
        .insert_resource(Gravity::from(Vec3::new(0.0, -9.81 * 10.0, 0.0))) // Optionally define gravity
        // game stuff
        .add_startup_system(setup_balls)
        .add_system(exit_on_q)
        .add_system(some_system)
        .run();
}

fn exit_on_q(mut exit: EventWriter<AppExit>, keys: Res<Input<KeyCode>>) {
    // note that we could also use
    //              .add_system(bevy::window::close_on_esc)
    if keys.just_pressed(KeyCode::Q) {
        exit.send(AppExit);
    }
}

#[derive(Component)]
struct DebugLine;

fn setup_balls(mut commands: Commands) {
    commands.spawn_bundle(Camera2dBundle::default());

    commands
        .spawn()
        .insert_bundle(SpriteBundle {
            sprite: Sprite {
                color: Color::rgb(0.25, 0.25, 0.75),
                custom_size: Some(Vec2::new(50.0, 50.0)),
                ..default()
            },
            ..default()
        })
        .insert_bundle(SpatialBundle {
            visibility: Visibility::visible(),
            transform: Transform::from_xyz(0.0, 0.0, 0.0),
            ..Default::default()
        })
        .insert(CollisionShape::Cuboid {
            half_extends: Vec2::new(25.0, 25.0).extend(0.0),
            border_radius: None,
        })
        .insert(RigidBody::Dynamic);

    commands
        .spawn()
        .insert_bundle(SpriteBundle {
            sprite: Sprite {
                color: Color::rgb(0.78, 0.3, 0.75),
                custom_size: Some(Vec2::new(50.0, 50.0)),
                ..default()
            },
            ..default()
        })
        .insert_bundle(SpatialBundle {
            visibility: Visibility::visible(),
            transform: Transform::from_xyz(-25.0, -200.0, 0.0),
            ..Default::default()
        })
        .insert(CollisionShape::Cuboid {
            half_extends: Vec2::new(25.0, 25.0).extend(0.0),
            border_radius: None,
        })
        .insert(RigidBody::Static);

    commands.spawn_bundle(Text2dBundle {
        transform: Transform::from_xyz(0.0, 0.0, 1.0),
        text: Text::from_section(
            "I like potatoes",
            TextStyle {
                font: Default::default(),
                font_size: 60.0,
                color: Color::CYAN,
            },
        ),
        ..default()
    });

    commands
        .spawn()
        .insert_bundle(SpriteBundle {
            sprite: Sprite {
                color: Color::rgb(0.18, 0.2, 0.95),
                custom_size: Some(Vec2::new(800.0, 70.0)),
                ..default()
            },
            ..default()
        })
        .insert_bundle(SpatialBundle {
            visibility: Visibility::visible(),
            transform: Transform::from_xyz(-25.0, -260.0, 0.0),
            ..Default::default()
        })
        .insert(CollisionShape::Cuboid {
            half_extends: Vec2::new(400.0, 35.0).extend(0.0),
            border_radius: None,
        })
        .insert(RigidBody::Static);
}

fn some_system(windows: Res<Windows>, mut lines: ResMut<DebugLines>) {
    let window = windows.get_primary().unwrap();

    if let Some(position) = window.cursor_position() {
        let pos3 = position.extend(0.0) - Vec3::new(400.0, 300.0, 0.0);

        lines.line(Vec3::new(399.0, 299.0, 0.0), pos3, 0.0);
        lines.line(Vec3::new(-399.0, 299.0, 0.0), pos3, 0.0);
        lines.line(Vec3::new(399.0, -299.0, 0.0), pos3, 0.0);
        lines.line(Vec3::new(-399.0, -299.0, 0.0), pos3, 0.0);
    }
}
