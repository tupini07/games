package managers;

import scenes.GameScene;
import haxe.display.Display.Define;
import Process.UpdateBubble;
import gui.Popup;

@:enum
abstract CMState(Int) {
	inline final Focusing = 1;
	inline final Focused = 2;
	inline final Unfocusing = 3;
	inline final Unfocused = 4;
}

class ConversationManager extends Process {
	public static var ME:ConversationManager;

	static inline final FOCUS_BAR_DELAY = 1;
	static inline final FOCUS_BAR_SPEED = 2;
	static inline final FOCUS_BAR_HEIGHT = 20;

	public var current_conversation(default, set):Popup;

	var current_state:CMState = Unfocused;

	var focus_bar_completion = 0;

	public function reset() {
		this.current_conversation = null;
		this.current_state = Unfocused;
		this.focus_bar_completion = 0;
	}

	public function set_current_conversation(newPopup:Popup):Popup {
		if (this.current_conversation != null && newPopup != null)
			throw "Tried to set a new focused conversation while we already had one";

		if (newPopup == null) {
			this.current_conversation = null;
			this.current_state = Unfocused;
			return null;
		} else {
			this.current_conversation = newPopup;
			this.current_state = Focusing;
			return this.current_conversation;
		}
	}

	private function new() {
		super(LevelMessage);
	}

	public static function get_instance():ConversationManager {
		if (ME == null) {
			ME = new ConversationManager();
		}

		return ME;
	}

	function handle_focusing() {
		if (this.focus_bar_completion <= 100) {
			Cam.trackEntity(this.current_conversation.entity);
			Timers.register_if_not_present('conversation-manager-focusing', FOCUS_BAR_DELAY, function() {
				this.focus_bar_completion += FOCUS_BAR_DELAY;
			});
		} else {
			this.current_state = Focused;
		}
	}

	function handle_focused() {
		if (!this.current_conversation.is_visible)
			this.current_conversation.start_popover_display();

		if (this.current_conversation.is_current_message_finished_displaying && T.btnp(A)) {
			if (!this.current_conversation.is_finished()) {
				this.current_conversation.show_next_message();
			}

			// separating these two conditionals since the above one might have altered the result of
			// .is_finished()
			if (this.current_conversation.is_finished()) {
				this.current_conversation.end_popover_display();
				this.current_state = Unfocusing;
			}
		}
	}

	function handle_unfocusing() {
		if (this.focus_bar_completion > 0) {
			Cam.trackEntity(GameScene.Hero);
			Timers.register_if_not_present('conversation-manager-unfocusing', FOCUS_BAR_DELAY, function() {
				this.focus_bar_completion -= FOCUS_BAR_SPEED;
			});
		} else {
			this.current_state = Unfocused;
		}
	}

	function handle_unfocused() {
		if (this.current_conversation != null)
			this.current_conversation.destroy();
		this.current_conversation = null;
		this.focus_bar_completion = 0;
	}

	override function update(ub:UpdateBubble) {
		if (this.current_conversation == null)
			return;

		ub.prevent_default = true;

		switch this.current_state {
			case Focusing:
				handle_focusing();
			case Focused:
				handle_focused();
			case Unfocusing:
				handle_unfocusing();
			case Unfocused:
				handle_unfocused();
		}
	}

	override function draw() {
		if (this.current_conversation == null)
			return;

		// draw top and bottom focusing rects
		var completion_perc = this.focus_bar_completion / 100;
		var current_height = Math.floor(FOCUS_BAR_HEIGHT * completion_perc);
		Cam.rect(Cam.off_x, Cam.off_y, C.SCREEN_WIDTH, current_height, 14);
		Cam.rect(Cam.off_x, Cam.off_y + C.SCREEN_HEIGHT - current_height, C.SCREEN_WIDTH, current_height, 14);

		if (this.focus_bar_completion >= 100 && this.current_conversation.is_current_message_finished_displaying) {
			var txt = 'Press A to continue';
			Cam.print(txt, Cam.off_x + C.SCREEN_WIDTH - Cam.get_len_of_print(txt) - 8, Cam.off_y + C.SCREEN_HEIGHT - 16);
		}
	}
}
