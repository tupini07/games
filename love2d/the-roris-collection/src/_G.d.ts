declare namespace SlabType {
    interface WindowOptions {
        Title: string;
        X: number;
        Y: number;
        W: number;
        H: number;
        ShowMinimize: boolean;
        AllowMove: boolean;
        AllowResize: boolean;
        AutoSizeWindow: boolean;
        ResetPosition: boolean;
        ResetSize: boolean;
    }

    interface ListBoxOptions {
        StretchW: boolean;
        StretchH: boolean;
    }

    function Initialize(args: any): void;
    function BeginWindow(id: string, options: WindowOptions): void;
    function Text(text: string): void;
    function BeginListBox(id: string, options: ListBoxOptions): void;
    function BeginListBoxItem(id: string): void;
    function IsListBoxItemClicked(button: number): boolean;
    function EndListBoxItem(): void;
    function EndListBox(): void;
    function EndWindow(): void;
    function Draw(): void;
    function Update(dt: number): void;
    function BeginMainMenuBar(): boolean;
    function EndMainMenuBar(): void;
    function BeginMenu(label: string): boolean;
    function MenuItem(label: string): boolean;
    function EndMenu(): void;
}

declare namespace SlabDebugType {
    function Menu(): void;
    function Begin(): void;
}

declare var Slab: typeof SlabType;
declare var SlabDebug: typeof SlabDebugType;