use crate::scenes::intro_scene::IntroScene;

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
}

pub struct SceneManager {
    current_state: Box<dyn Scene>,
}

impl SceneManager {
    pub fn new() -> Self {
        SceneManager {
            current_state: Box::new(IntroScene::new()),
        }
    }

    pub fn set_state(&mut self, new_state: GameStates) {
        dbg!(&new_state);
        self.current_state = Box::new(match new_state {
            GameStates::TITLE => IntroScene::new(),
        })
    }

    pub fn update(&mut self) {
        let new_state = self.current_state.update();

        if let Some(state) = new_state {
            self.set_state(state);
        }
    }
    pub fn draw(&self) {
        self.current_state.draw();
    }
}
