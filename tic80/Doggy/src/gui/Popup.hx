package gui;

import managers.ConversationManager;
import Process.UpdateBubble;
import scenes.GameScene;
import physics.Vector2d;
import utils.Text;

class Popup extends Process {
	var popup_id:String;

	public var entity(default, null):Entity;

	var callback:() -> Void;
	var should_fire:() -> Bool;

	var messages:Array<WrapTextResult>;

	var current_message_i:Int = 0;
	var current_message(get, never):WrapTextResult;

	function get_current_message():WrapTextResult {
		return this.messages[this.current_message_i];
	}

	public var is_current_message_finished_displaying(get, never):Bool;

	function get_is_current_message_finished_displaying():Bool {
		return current_message == null || current_message.text == "";
	}

	var displayed_text = "";

	public var is_visible(default, null) = false;

	var is_started = false;

	var text_origin:Vector2d = new Vector2d(0, 0);

	/**
	 * Constructs a new textual popup that can potentially start a conversation scene
	 * @param entity The entity on top of which this popup sould appear
	 * @param messages An array of messages. One popup will be shown for each message, sequentially
	 * @param should_fire Optional function that returns true if the popup should fire when player is in range. If not provided then it will always fire when in range.
	 * @param callback Optional callback function that gets called once this conversation is done
	 * @return -> Void
	 */
	public function new(entity, messages:Array<String>, ?should_fire:() -> Bool, ?callback:() -> Void) {
		super(LevelMessage);

		this.entity = entity;
		this.messages = [for (m in messages) Text.wrap_text_at_length(m, 10)];

		this.popup_id = '${Type.getClassName(Type.getClass(this.entity))}-${Math.random() * this.messages.length}';

		this.should_fire = should_fire;
		this.callback = callback;
	}

	public function is_finished() {
		return this.current_message_i >= this.messages.length;
	}

	public function start_popover_display() {
		this.is_visible = true;
	}

	public function end_popover_display() {
		if (this.destroyed)
			return;

		if (this.callback != null)
			this.callback();

		this.is_visible = false;
	}

	public function show_next_message() {
		this.displayed_text = "";
		this.current_message_i += 1;
		this.is_visible = true;
	}

	public override function update(ub:UpdateBubble) {
		if (this.destroyed || this.is_finished()) {
			return;
		}

		if (this.should_fire != null && !this.should_fire()) {
			// don't do anything fire if we're not supposed to
			return;
		}

		this.text_origin.x = Math.floor(this.entity.pos.x + 8 - (current_message.width_px / 2));

		this.text_origin.y = Math.floor(this.entity.pos.y - 4 - current_message.height_px);

		if (!this.is_started && Math.abs(GameScene.Hero.pos.distance(this.text_origin)) < C.SCREEN_HEIGHT / 2.5) {
			this.is_started = true;
		}

		if (this.is_started && ConversationManager.ME.current_conversation != this)
			ConversationManager.ME.current_conversation = this;

		if (this.is_visible && current_message.text.length != 0) {
			Timers.register_if_not_present('popup-reveal-${this.popup_id}', 5, function() {
				this.displayed_text += current_message.text.charAt(0);
				current_message.text = current_message.text.substr(1);
			});
		}
	}

	public override function draw() {
		if (!this.is_visible || this.is_finished())
			return;

		Cam.rect(cast this.text_origin.x, cast this.text_origin.y, current_message.width_px, current_message.height_px, 6);
		Cam.print(this.displayed_text, cast this.text_origin.x, cast this.text_origin.y);
	}
}
