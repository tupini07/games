import { Source } from "love.audio";
import Vector2D from "../entities/vector2d";
import { isMousePressed } from "../lib/input";
import { IScene } from "./iscene";
import { Scene, switchScene } from "./scene_manager";

class Ball {
    position: Vector2D;
    radius: number;
    decreaseRate: number;
    fillColor: string;
    strokeColor: string;

    allowedColors = [
        "1D2B53",
        "7E2553",
        "008751",
        "AB5236",
        "5F574F",
        "C2C3C7",
        "FFF1E8",
        "FF004D",
        "FFA300",
        "FFEC27",
        "00E436",
        "29ADFF",
        "83769C",
        "FF77A8",
        "FFCCAA",
    ];

    constructor(position: Vector2D) {
        this.position = position;
        this.radius = love.math.random(10.0, 50.0);
        this.decreaseRate = love.math.random(5, 30);

        this.fillColor =
            this.allowedColors[
                love.math.random(0, this.allowedColors.length - 1)
            ];
        this.strokeColor =
            this.allowedColors[
                love.math.random(0, this.allowedColors.length - 1)
            ];
    }

    update(dt: number): boolean {
        this.radius -= this.decreaseRate * dt;
        return this.radius <= 0;
    }

    private setColorFromHexString(hex: string): void {
        const r = parseInt(hex.substring(0, 2), 16) / 255;
        const g = parseInt(hex.substring(2, 4), 16) / 255;
        const b = parseInt(hex.substring(4, 6), 16) / 255;
        love.graphics.setColor(r, g, b, 1); // Alpha is set to 1
    }

    draw(): void {
        this.setColorFromHexString(this.fillColor);
        love.graphics.circle(
            "fill",
            this.position.x,
            this.position.y,
            this.radius,
        );

        this.setColorFromHexString(this.strokeColor);
        love.graphics.circle(
            "line",
            this.position.x,
            this.position.y,
            this.radius,
        );
    }
}

export class BallSmash implements IScene {
    name: string = Scene.BallSmash;
    balls: Ball[] = [];

    createSounds: Source[] = [];

    init(): void {
        this.balls = [];
        this.createSounds = [
            love.audio.newSource("assets/audio/effects/jump1.wav", "static"),
            love.audio.newSource("assets/audio/effects/jump2.wav", "static"),
            love.audio.newSource("assets/audio/effects/jump3.wav", "static"),
            love.audio.newSource("assets/audio/effects/jump4.wav", "static"),
            love.audio.newSource("assets/audio/effects/coin1.wav", "static"),
        ];
    }
    draw(): void {
        love.graphics.clear(0.83, 0.8, 0.8);
        this.balls.forEach((b) => b.draw());
    }
    exit(): void {
        for (const source of this.createSounds) {
            source.release();
        }
    }
    update(dt: number): void {
        if (love.keyboard.isDown("escape")) {
            switchScene(Scene.Intro);
            return;
        }

        let mousePressed = isMousePressed(1);
        if (mousePressed) {
            // if there is a playing sound then stop it
            for (let soundSource of this.createSounds) {
                if (soundSource.isPlaying()) {
                    soundSource.stop();
                }
            }

            // play new sound
            let soundSource =
                this.createSounds[
                    love.math.random(0, this.createSounds.length - 1)
                ];

            soundSource.play();

            // create new ball
            let mousePosition = love.mouse.getPosition();
            let ball = new Ball(
                new Vector2D(mousePosition[0], mousePosition[1]),
            );
            this.balls.push(ball);
        }

        for (let ball of this.balls) {
            let shouldRemove = ball.update(dt);
            if (shouldRemove) {
                let idx = this.balls.indexOf(ball);
                this.balls.splice(idx, 1);
            }
        }
    }
}
