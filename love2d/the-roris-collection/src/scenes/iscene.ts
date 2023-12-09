export interface IScene {
    name: string;

    init(): void;
    draw(): void;
    exit(): void;
    
    update(dt: number): void;
}