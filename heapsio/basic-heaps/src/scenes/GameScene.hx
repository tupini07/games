package scenes;

class GameScene extends UpdatableScene {
	var player:h2d.Object;

	public function new() {
		super();

		var p = new assets.LdtkData();
		trace(p.all_worlds);

		for (level in p.all_worlds.SampleWorld.levels) {
			trace("Rending level: " + level.identifier);

			var levelWrapper = new h2d.Object(this);
			// Position accordingly to world pixel coords
			levelWrapper.x = level.worldX;
			levelWrapper.y = level.worldY;

			// Level background image
			if (level.hasBgImage()) {
				trace("Adding bg image");
				levelWrapper.addChild(level.getBgBitmap());
			}

			// Render background layer
			levelWrapper.addChild(level.l_Collisions.render());

			// Render collision layer tiles
			var playerStart = level.l_Entities.all_PlayerStart[0];

			player = new h2d.Object(this);
			player.x = playerStart.pixelX;
			player.y = playerStart.pixelY;

			var playerTile = h2d.Tile.fromColor(dn.Col.ColorEnum.Green, playerStart.width, playerStart.height);
			new h2d.Bitmap(playerTile, player);

			new entities.PimpCamera(camera);
			camera.follow = player;
			camera.setScale(3, 3);
		}
	}

	public function update(dt:Float) {
		if (player != null) {
			if (Key.isDown(Key.A)) {
				player.x -= 1;
			} else if (Key.isDown(Key.D)) {
				player.x += 1;
			}

			if (Key.isDown(Key.W)) {
				player.y -= 1;
			} else if (Key.isDown(Key.S)) {
				player.y += 1;
			}
		}
	}
}
