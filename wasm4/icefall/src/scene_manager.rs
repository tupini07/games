pub trait Scene {
    fn new() -> Self
    where
        Self: Sized;

    fn update(&mut self) -> Option<GameStates>;
    fn draw(&self);
}

#[derive(Debug)]
pub enum GameStates {
    TITLE,
    GAME
}

pub struct SceneManager {}

impl SceneManager {
    pub fn do_tick<S: Scene>(scene: &mut Option<S>) -> Option<GameStates> {
        let scene_opt_ref = scene.as_mut();
        let scene_ref = scene_opt_ref.unwrap();

        let up_res = scene_ref.update();
        scene_ref.draw();

        up_res
    }
}
