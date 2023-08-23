package scenes;

import h2d.SpriteBatch;

class IntroScene extends UpdatableScene {
	var obj:h2d.Object;
	var tf:h2d.Text;

	var weirdText:h2d.Text;

	public function new() {
		super();

		// creates a new object and put it at the center of the sceen
		obj = new h2d.Object(this);
		obj.x = Std.int(this.width / 2);
		obj.y = Std.int(this.height / 2);

		// load the haxe logo png into a tile
		var tile = hxd.Res.title.toTile();

		// change its pivot so it is centered
		tile = tile.center();

		var batch = new SpriteBatch(tile, this);

		for (i in 0...15) {
			// creates a bitmap into the object
			var bmp = new h2d.Bitmap(tile, obj);

			// move its position
			bmp.x = Math.cos(i * Math.PI / 8) * 100;
			bmp.y = Math.sin(i * Math.PI / 8) * 100;

			// makes it transparent by 10%
			bmp.alpha = 0.1;

			// makes the colors adds to the background
			bmp.blendMode = Add;
		}

		// load a bitmap font Resource
		var font = hxd.Res.minecraftia_regular_6.toFont();

		// creates another text field with this font
		var tf = new h2d.Text(font, this);
		tf.textColor = 0xFFFFFF;
		tf.dropShadow = {
			dx: 0.5,
			dy: 0.5,
			color: 0xFF0000,
			alpha: 0.8
		};
		tf.text = "Héllò h2d !";

		tf.y = 20;
		tf.x = 20;
		tf.scale(7);

		var tf2 = new h2d.Text(font, this);
		tf2.textColor = 0xFFFFFF;
		tf2.text = "Press X to go to game whoo";
		tf2.y = 200;
		tf2.x = 20;
		tf2.scale(3);
	}

	function update(dt:Float) {
		// rotate our object every frame
		if (obj != null)
			obj.rotation += 0.6 * dt;

		if (Key.isPressed(Key.X)) {
			Game.ME.currentScene = new GameScene();
            return;
		}

		if (Key.isPressed(Key.SPACE) && weirdText == null) {
			var font = hxd.Res.minecraftia_regular_6.toFont();

			weirdText = new h2d.Text(font, this);
			weirdText.text = "Hello World";
			weirdText.x = 19;
			weirdText.y = 10;
			weirdText.scale(3);

			camera.clipViewport = true;
			camera.follow = weirdText;

			// center object in camera
			camera.anchorX = 0.4;
			camera.anchorY = 0.4;
		}

		if (weirdText != null) {
			var speed = 600 * dt;
			if (Key.isDown(Key.W)) {
				weirdText.y -= speed;
			} else if (Key.isDown(Key.S)) {
				weirdText.y += speed;
			} else if (Key.isDown(Key.A)) {
				weirdText.x -= speed;
			} else if (Key.isDown(Key.D)) {
				weirdText.x += speed;
			} else if (Key.isDown(Key.Q)) {
				weirdText.scale(1.01);
			} else if (Key.isDown(Key.E)) {
				weirdText.scale(0.99);
			}
		}
	}
}
