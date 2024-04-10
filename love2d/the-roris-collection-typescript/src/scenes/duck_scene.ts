import Vector2D from "../entities/vector2d";
import { IScene } from "./iscene";

enum DuckAnimState {
    Idle,
    Walk,
    Run,
    Jump,
    Dead,
    Crouch,
}

class DuckAnimator {
    private idleSprites = [
        love.graphics.newImage("assets/images/duck/Idle 001.png"),
        love.graphics.newImage("assets/images/duck/Idle 002.png"),
    ];

    private walkingSprites = [
        love.graphics.newImage("assets/images/duck/Walking 001.png"),
        love.graphics.newImage("assets/images/duck/Walking 002.png"),
    ];

    private runningSprites = [
        love.graphics.newImage("assets/images/duck/Running 001.png"),
        love.graphics.newImage("assets/images/duck/Running 002.png"),
    ];

    private jumpingSprites = [
        love.graphics.newImage("assets/images/duck/Jumping 001.png"),
    ];

    private deadSprites = [
        love.graphics.newImage("assets/images/duck/Dead 001.png"),
    ];

    private crouchingSprites = [
        love.graphics.newImage("assets/images/duck/Crouching 001.png"),
    ];

    currentState = DuckAnimState.Idle;
    private frameCounter = 0;
    animSpeed = 3.5; // fps

    switchState(newState: DuckAnimState, newAnimSpeed?: number) {
        this.currentState = newState;
        this.frameCounter = 0;

        if (newAnimSpeed) {
            this.animSpeed = newAnimSpeed;
        }
    }

    update(dt: number) {
        this.frameCounter += this.animSpeed * dt;
    }

    getCurrentSprite() {
        let sprites;
        switch (this.currentState) {
            case DuckAnimState.Idle:
                sprites = this.idleSprites;
                break;
            case DuckAnimState.Walk:
                sprites = this.walkingSprites;
                break;
            case DuckAnimState.Run:
                sprites = this.runningSprites;
                break;
            case DuckAnimState.Jump:
                sprites = this.jumpingSprites;
                break;
            case DuckAnimState.Dead:
                sprites = this.deadSprites;
                break;
            case DuckAnimState.Crouch:
                sprites = this.crouchingSprites;
                break;
            default:
                const exhaustiveCheck: never = this.currentState;
                throw new Error(`Unhandled DuckAnimState: ${exhaustiveCheck}`);
        }

        return sprites[math.floor(this.frameCounter) % sprites.length];
    }
}

enum DuckMode {
    WalkSlowly,
    WalkFast,
    Run,
}

class Duck {
    animator = new DuckAnimator();

    pos: Vector2D;
    speed: number = 100;
    direction: number = 1; // 1 for right, -1 for left
    mode: DuckMode = DuckMode.WalkSlowly;

    constructor() {
        this.pos = new Vector2D(0, love.graphics.getHeight() - 100); // 100 pixels from the bottom
        this.animator.switchState(DuckAnimState.Walk);
        this.setMode(DuckMode.WalkSlowly);
    }

    setMode(mode: DuckMode) {
        switch (mode) {
            case DuckMode.WalkSlowly:
                this.speed = 30;
                this.animator.animSpeed = 2.107;
                this.animator.switchState(DuckAnimState.Walk);
                break;
            case DuckMode.WalkFast:
                this.speed = 100;
                this.animator.animSpeed = 3.5;
                this.animator.switchState(DuckAnimState.Walk);
                break;
            case DuckMode.Run:
                break;
            default:
                const exhaustiveCheck: never = mode;
                throw new Error(`Unhandled DuckAnimState: ${exhaustiveCheck}`);
        }
    }

    update(dt: number) {
        this.animator.update(dt);

        // Move the duck
        this.pos.x += this.speed * dt * this.direction;

        // If the duck has moved off the right edge of the screen, change direction to left
        if (
            this.pos.x + this.animator.getCurrentSprite().getWidth() / 2 >
            love.graphics.getWidth()
        ) {
            this.direction = -1;
        }

        // If the duck has moved off the left edge of the screen, change direction to right
        if (this.pos.x - this.animator.getCurrentSprite().getWidth() / 2 < 0) {
            this.direction = 1;
        }

        Slab.BeginWindow("3rwetwert", { Title: "Duck mode" });
        Slab.Text("Speed");
        Slab.SameLine();
        if (Slab.InputNumberSlider("Duck mode speed", this.speed, 0.0, 300)) {
            this.speed = Slab.GetInputNumber();
        }

        Slab.Text("Raw anim");
        let currentStateName = DuckAnimState[this.animator.currentState];
        if (
            Slab.BeginComboBox("duck mode anim cbx", {
                Selected: currentStateName,
            })
        ) {
            for (let enumMember in DuckAnimState) {
                let isValueProperty = Number(enumMember) >= 0;
                if (isValueProperty) {
                    if (Slab.TextSelectable(DuckAnimState[enumMember])) {
                        this.animator.currentState =
                            enumMember as unknown as DuckAnimState;
                    }
                }
            }

            Slab.EndComboBox();
        }
        Slab.EndWindow();
    }

    draw() {
        let currentSprite = this.animator.getCurrentSprite();
        love.graphics.draw(
            currentSprite,
            this.pos.x,
            this.pos.y,
            0,
            this.direction,
            1,
            currentSprite.getWidth() / 2,
        );
    }
}

export class DuckScene implements IScene {
    name: string = "duck_scene";
    duck = new Duck();
    floorY: number =
        this.duck.pos.y + this.duck.animator.getCurrentSprite().getHeight();

    init(): void {}

    exit(): void {}

    draw(): void {
        love.graphics.clear(0.2, 0.2, 0.2);
        this.duck.draw();

        love.graphics.line(
            0,
            this.floorY,
            love.graphics.getWidth(),
            this.floorY,
        );
    }

    update(dt: number): void {
        this.duck.update(dt);
    }
}
