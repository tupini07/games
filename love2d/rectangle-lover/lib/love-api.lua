local love = {["__generator-version"] = "1.0.0", version = "11.4"}
love.conf = function(t)
  return {}
end
love.directorydropped = function(path)
  return {}
end
love.displayrotated = function(index, orientation)
  return {}
end
love.draw = function()
  return {}
end
love.errorhandler = function(msg)
  return {}
end
love.filedropped = function(file)
  return {}
end
love.focus = function(focus)
  return {}
end
love.gamepadaxis = function(joystick, axis, value)
  return {}
end
love.gamepadpressed = function(joystick, button)
  return {}
end
love.gamepadreleased = function(joystick, button)
  return {}
end
love.joystickadded = function(joystick)
  return {}
end
love.joystickaxis = function(joystick, axis, value)
  return {}
end
love.joystickhat = function(joystick, hat, direction)
  return {}
end
love.joystickpressed = function(joystick, button)
  return {}
end
love.joystickreleased = function(joystick, button)
  return {}
end
love.joystickremoved = function(joystick)
  return {}
end
love.keypressed = function(key, scancode, isrepeat)
  return {}
end
love.keyreleased = function(key, scancode)
  return {}
end
love.load = function(arg, unfilteredArg)
  return {}
end
love.lowmemory = function()
  return {}
end
love.mousefocus = function(focus)
  return {}
end
love.mousemoved = function(x, y, dx, dy, istouch)
  return {}
end
love.mousepressed = function(x, y, button, istouch, presses)
  return {}
end
love.mousereleased = function(x, y, button, istouch, presses)
  return {}
end
love.quit = function()
  return {}
end
love.resize = function(w, h)
  return {}
end
love.run = function()
  return {}
end
love.textedited = function(text, start, _length)
  return {}
end
love.textinput = function(text)
  return {}
end
love.threaderror = function(thread, errorstr)
  return {}
end
love.touchmoved = function(id, x, y, dx, dy, pressure)
  return {}
end
love.touchpressed = function(id, x, y, dx, dy, pressure)
  return {}
end
love.touchreleased = function(id, x, y, dx, dy, pressure)
  return {}
end
love.update = function(dt)
  return {}
end
love.visible = function(visible)
  return {}
end
love.wheelmoved = function(x, y)
  return {}
end
love.getVersion = function()
  return {}
end
love.hasDeprecationOutput = function()
  return {}
end
love.isVersionCompatible = function(version)
  return {}
end
love.setDeprecationOutput = function(enable)
  return {}
end
love["math"] = {}
love.math.gammaToLinear = function(r, g, b)
  return {}
end
love.math.decompress = function(compressedData)
  return {}
end
love.math.isConvex = function(vertices)
  return {}
end
love.math.getRandomState = function()
  return {}
end
love.math.colorToBytes = function(r, g, b, a)
  return {}
end
love.math.compress = function(rawstring, format, level)
  return {}
end
love.math.getRandomSeed = function()
  return {}
end
love.math.triangulate = function(polygon)
  return {}
end
love.math.newTransform = function()
  return {}
end
love.math.newBezierCurve = function(vertices)
  return {}
end
love.math.setRandomSeed = function(seed)
  return {}
end
love.math.noise = function(x)
  return {}
end
love.math.colorFromBytes = function(rb, gb, bb, ab)
  return {}
end
love.math.randomNormal = function(stddev, mean)
  return {}
end
love.math.linearToGamma = function(lr, lg, lb)
  return {}
end
love.math.setRandomState = function(state)
  return {}
end
love.math.newRandomGenerator = function()
  return {}
end
love.math.random = function()
  return {}
end
love["font"] = {}
love.font.newBMFontRasterizer = function(imageData, glyphs, dpiscale)
  return {}
end
love.font.newImageRasterizer = function(imageData, glyphs, extraSpacing, dpiscale)
  return {}
end
love.font.newRasterizer = function(filename)
  return {}
end
love.font.newTrueTypeRasterizer = function(size, hinting, dpiscale)
  return {}
end
love.font.newGlyphData = function(rasterizer, glyph)
  return {}
end
love["physics"] = {}
love.physics.newPrismaticJoint = function(body1, body2, x, y, ax, ay, collideConnected)
  return {}
end
love.physics.newPulleyJoint = function(body1, body2, gx1, gy1, gx2, gy2, x1, y1, x2, y2, ratio, collideConnected)
  return {}
end
love.physics.newCircleShape = function(radius)
  return {}
end
love.physics.getMeter = function()
  return {}
end
love.physics.newFrictionJoint = function(body1, body2, x, y, collideConnected)
  return {}
end
love.physics.newGearJoint = function(joint1, joint2, ratio, collideConnected)
  return {}
end
love.physics.newRectangleShape = function(width, height)
  return {}
end
love.physics.newWorld = function(xg, yg, sleep)
  return {}
end
love.physics.setMeter = function(scale)
  return {}
end
love.physics.newMotorJoint = function(body1, body2, correctionFactor)
  return {}
end
love.physics.newWeldJoint = function(body1, body2, x, y, collideConnected)
  return {}
end
love.physics.newRopeJoint = function(body1, body2, x1, y1, x2, y2, maxLength, collideConnected)
  return {}
end
love.physics.newMouseJoint = function(body, x, y)
  return {}
end
love.physics.newRevoluteJoint = function(body1, body2, x, y, collideConnected)
  return {}
end
love.physics.newPolygonShape = function(x1, y1, x2, y2, x3, y3, ...)
  return {}
end
love.physics.newChainShape = function(loop, x1, y1, x2, y2, ...)
  return {}
end
love.physics.getDistance = function(fixture1, fixture2)
  return {}
end
love.physics.newFixture = function(body, shape, density)
  return {}
end
love.physics.newEdgeShape = function(x1, y1, x2, y2)
  return {}
end
love.physics.newBody = function(world, x, y, type)
  return {}
end
love.physics.newWheelJoint = function(body1, body2, x, y, ax, ay, collideConnected)
  return {}
end
love.physics.newDistanceJoint = function(body1, body2, x1, y1, x2, y2, collideConnected)
  return {}
end
love["image"] = {}
love.image.isCompressed = function(filename)
  return {}
end
love.image.newImageData = function(width, height)
  return {}
end
love.image.newCompressedData = function(filename)
  return {}
end
love["data"] = {}
love.data.compress = function(container, format, rawstring, level)
  return {}
end
love.data.getPackedSize = function(format)
  return {}
end
love.data.decode = function(container, format, sourceString)
  return {}
end
love.data.newDataView = function(data, offset, size)
  return {}
end
love.data.newByteData = function(datastring)
  return {}
end
love.data.unpack = function(format, datastring, pos)
  return {}
end
love.data.pack = function(container, format, v1, ...)
  return {}
end
love.data.encode = function(container, format, sourceString, line_length)
  return {}
end
love.data.decompress = function(container, compressedData)
  return {}
end
love.data.hash = function(hashFunction, string)
  return {}
end
love["timer"] = {}
love.timer.getAverageDelta = function()
  return {}
end
love.timer.getFPS = function()
  return {}
end
love.timer.getDelta = function()
  return {}
end
love.timer.getTime = function()
  return {}
end
love.timer.sleep = function(s)
  return {}
end
love.timer.step = function()
  return {}
end
love["filesystem"] = {}
love.filesystem.setSource = function(path)
  return {}
end
love.filesystem.getInfo = function(path, filtertype)
  return {}
end
love.filesystem.areSymlinksEnabled = function()
  return {}
end
love.filesystem.lines = function(name)
  return {}
end
love.filesystem.createDirectory = function(name)
  return {}
end
love.filesystem.write = function(name, data, size)
  return {}
end
love.filesystem.read = function(name, size)
  return {}
end
love.filesystem.unmount = function(archive)
  return {}
end
love.filesystem.getIdentity = function()
  return {}
end
love.filesystem.getWorkingDirectory = function()
  return {}
end
love.filesystem.newFileData = function(contents, name)
  return {}
end
love.filesystem.setSymlinksEnabled = function(enable)
  return {}
end
love.filesystem.remove = function(name)
  return {}
end
love.filesystem.getDirectoryItems = function(dir)
  return {}
end
love.filesystem.getSourceBaseDirectory = function()
  return {}
end
love.filesystem.init = function(appname)
  return {}
end
love.filesystem.getAppdataDirectory = function()
  return {}
end
love.filesystem.load = function(name)
  return {}
end
love.filesystem.setRequirePath = function(paths)
  return {}
end
love.filesystem.getSource = function()
  return {}
end
love.filesystem.getUserDirectory = function()
  return {}
end
love.filesystem.getCRequirePath = function()
  return {}
end
love.filesystem.getSaveDirectory = function()
  return {}
end
love.filesystem.mount = function(archive, mountpoint, appendToPath)
  return {}
end
love.filesystem.setCRequirePath = function(paths)
  return {}
end
love.filesystem.newFile = function(filename)
  return {}
end
love.filesystem.getRealDirectory = function(filepath)
  return {}
end
love.filesystem.isFused = function()
  return {}
end
love.filesystem.setIdentity = function(name)
  return {}
end
love.filesystem.getRequirePath = function()
  return {}
end
love.filesystem.append = function(name, data, size)
  return {}
end
love["joystick"] = {}
love.joystick.getJoystickCount = function()
  return {}
end
love.joystick.getGamepadMappingString = function(guid)
  return {}
end
love.joystick.loadGamepadMappings = function(filename)
  return {}
end
love.joystick.setGamepadMapping = function(guid, button, inputtype, inputindex, hatdir)
  return {}
end
love.joystick.saveGamepadMappings = function(filename)
  return {}
end
love.joystick.getJoysticks = function()
  return {}
end
love["graphics"] = {}
love.graphics.getPixelHeight = function()
  return {}
end
love.graphics.setLineStyle = function(style)
  return {}
end
love.graphics.getStencilTest = function()
  return {}
end
love.graphics.getPixelDimenions = function()
  return {}
end
love.graphics.getSupported = function()
  return {}
end
love.graphics.intersectScissor = function(x, y, width, height)
  return {}
end
love.graphics.newText = function(font, textstring)
  return {}
end
love.graphics.getImageFormats = function()
  return {}
end
love.graphics.getCanvas = function()
  return {}
end
love.graphics.newCubeImage = function(filename, settings)
  return {}
end
love.graphics.newFont = function(filename)
  return {}
end
love.graphics.getLineStyle = function()
  return {}
end
love.graphics.line = function(x1, y1, x2, y2, ...)
  return {}
end
love.graphics.isGammaCorrect = function()
  return {}
end
love.graphics.setBackgroundColor = function(red, green, blue, alpha)
  return {}
end
love.graphics.getShader = function()
  return {}
end
love.graphics.translate = function(dx, dy)
  return {}
end
love.graphics.setShader = function(shader)
  return {}
end
love.graphics.setMeshCullMode = function(mode)
  return {}
end
love.graphics.setColorMask = function(red, green, blue, alpha)
  return {}
end
love.graphics.newSpriteBatch = function(image, maxsprites)
  return {}
end
love.graphics.newParticleSystem = function(image, buffer)
  return {}
end
love.graphics.getMeshCullMode = function()
  return {}
end
love.graphics.getStackDepth = function()
  return {}
end
love.graphics.newArrayImage = function(slices, settings)
  return {}
end
love.graphics.getWidth = function()
  return {}
end
love.graphics.clear = function()
  return {}
end
love.graphics.circle = function(mode, x, y, radius)
  return {}
end
love.graphics.newVideo = function(filename)
  return {}
end
love.graphics.drawLayer = function(texture, layerindex, x, y, r, sx, sy, ox, oy, kx, ky)
  return {}
end
love.graphics.getDimensions = function()
  return {}
end
love.graphics.ellipse = function(mode, x, y, radiusx, radiusy)
  return {}
end
love.graphics.validateShader = function(gles, code)
  return {}
end
love.graphics.flushBatch = function()
  return {}
end
love.graphics.getBackgroundColor = function()
  return {}
end
love.graphics.getRendererInfo = function()
  return {}
end
love.graphics.inverseTransformPoint = function(screenX, screenY)
  return {}
end
love.graphics.stencil = function(stencilfunction, action, value, keepvalues)
  return {}
end
love.graphics.shear = function(kx, ky)
  return {}
end
love.graphics.getDPIScale = function()
  return {}
end
love.graphics.getLineJoin = function()
  return {}
end
love.graphics.getBlendMode = function()
  return {}
end
love.graphics.setWireframe = function(enable)
  return {}
end
love.graphics.setStencilTest = function(comparemode, comparevalue)
  return {}
end
love.graphics.discard = function(discardcolor, discardstencil)
  return {}
end
love.graphics.setPointSize = function(size)
  return {}
end
love.graphics.setScissor = function(x, y, width, height)
  return {}
end
love.graphics.newVolumeImage = function(layers, settings)
  return {}
end
love.graphics.isActive = function()
  return {}
end
love.graphics.getColor = function()
  return {}
end
love.graphics.setNewFont = function(size)
  return {}
end
love.graphics.setLineWidth = function(width)
  return {}
end
love.graphics.getHeight = function()
  return {}
end
love.graphics.setDefaultFilter = function(min, mag, anisotropy)
  return {}
end
love.graphics.scale = function(sx, sy)
  return {}
end
love.graphics.present = function()
  return {}
end
love.graphics.newMesh = function(vertices, mode, usage)
  return {}
end
love.graphics.reset = function()
  return {}
end
love.graphics.pop = function()
  return {}
end
love.graphics.rotate = function(angle)
  return {}
end
love.graphics.setLineJoin = function(join)
  return {}
end
love.graphics.setBlendMode = function(mode)
  return {}
end
love.graphics.isWireframe = function()
  return {}
end
love.graphics.setColor = function(red, green, blue, alpha)
  return {}
end
love.graphics.getDefaultFilter = function()
  return {}
end
love.graphics.newShader = function(code)
  return {}
end
love.graphics.setFrontFaceWinding = function(winding)
  return {}
end
love.graphics.getCanvasFormats = function()
  return {}
end
love.graphics.setDepthMode = function(comparemode, write)
  return {}
end
love.graphics.setFont = function(font)
  return {}
end
love.graphics.replaceTransform = function(transform)
  return {}
end
love.graphics.rectangle = function(mode, x, y, width, height)
  return {}
end
love.graphics.draw = function(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
  return {}
end
love.graphics.getLineWidth = function()
  return {}
end
love.graphics.getTextureTypes = function()
  return {}
end
love.graphics.captureScreenshot = function(filename)
  return {}
end
love.graphics.origin = function()
  return {}
end
love.graphics.newImage = function(filename, flags)
  return {}
end
love.graphics.printf = function(text, x, y, limit, align, r, sx, sy, ox, oy, kx, ky)
  return {}
end
love.graphics.push = function()
  return {}
end
love.graphics.print = function(text, x, y, r, sx, sy, ox, oy, kx, ky)
  return {}
end
love.graphics.getFont = function()
  return {}
end
love.graphics.polygon = function(mode, ...)
  return {}
end
love.graphics.drawInstanced = function(mesh, instancecount, x, y, r, sx, sy, ox, oy, kx, ky)
  return {}
end
love.graphics.getFrontFaceWinding = function()
  return {}
end
love.graphics.applyTransform = function(transform)
  return {}
end
love.graphics.arc = function(drawmode, x, y, radius, angle1, angle2, segments)
  return {}
end
love.graphics.getPointSize = function()
  return {}
end
love.graphics.getDepthMode = function()
  return {}
end
love.graphics.transformPoint = function(globalX, globalY)
  return {}
end
love.graphics.getStats = function()
  return {}
end
love.graphics.getScissor = function()
  return {}
end
love.graphics.getColorMask = function()
  return {}
end
love.graphics.getSystemLimits = function()
  return {}
end
love.graphics.points = function(x, y, ...)
  return {}
end
love.graphics.getPixelWidth = function()
  return {}
end
love.graphics.newCanvas = function()
  return {}
end
love.graphics.newImageFont = function(filename, glyphs)
  return {}
end
love.graphics.newQuad = function(x, y, width, height, sw, sh)
  return {}
end
love.graphics.setCanvas = function(canvas, mipmap)
  return {}
end
love["system"] = {}
love.system.setClipboardText = function(text)
  return {}
end
love.system.hasBackgroundMusic = function()
  return {}
end
love.system.getOS = function()
  return {}
end
love.system.vibrate = function(seconds)
  return {}
end
love.system.getClipboardText = function()
  return {}
end
love.system.getProcessorCount = function()
  return {}
end
love.system.getPowerInfo = function()
  return {}
end
love.system.openURL = function(url)
  return {}
end
love["sound"] = {}
love.sound.newSoundData = function(filename)
  return {}
end
love.sound.newDecoder = function(file, buffer)
  return {}
end
love["video"] = {}
love.video.newVideoStream = function(filename)
  return {}
end
love["event"] = {}
love.event.clear = function()
  return {}
end
love.event.pump = function()
  return {}
end
love.event.poll = function()
  return {}
end
love.event.wait = function()
  return {}
end
love.event.push = function(n, a, b, c, d, e, f, ...)
  return {}
end
love.event.quit = function(exitstatus)
  return {}
end
love["thread"] = {}
love.thread.newChannel = function()
  return {}
end
love.thread.getChannel = function(name)
  return {}
end
love.thread.newThread = function(filename)
  return {}
end
love["mouse"] = {}
love.mouse.getCursor = function()
  return {}
end
love.mouse.isDown = function(button, ...)
  return {}
end
love.mouse.setX = function(x)
  return {}
end
love.mouse.getSystemCursor = function(ctype)
  return {}
end
love.mouse.setVisible = function(visible)
  return {}
end
love.mouse.setY = function(y)
  return {}
end
love.mouse.setCursor = function(cursor)
  return {}
end
love.mouse.getRelativeMode = function()
  return {}
end
love.mouse.isCursorSupported = function()
  return {}
end
love.mouse.setGrabbed = function(grab)
  return {}
end
love.mouse.newCursor = function(imageData, hotx, hoty)
  return {}
end
love.mouse.isGrabbed = function()
  return {}
end
love.mouse.setPosition = function(x, y)
  return {}
end
love.mouse.getX = function()
  return {}
end
love.mouse.setRelativeMode = function(enable)
  return {}
end
love.mouse.getPosition = function()
  return {}
end
love.mouse.isVisible = function()
  return {}
end
love.mouse.getY = function()
  return {}
end
love["window"] = {}
love.window.setIcon = function(imagedata)
  return {}
end
love.window.getDisplayName = function(displayindex)
  return {}
end
love.window.minimize = function()
  return {}
end
love.window.getDisplayCount = function()
  return {}
end
love.window.getMode = function()
  return {}
end
love.window.updateMode = function(width, height, settings)
  return {}
end
love.window.getDisplayOrientation = function(displayindex)
  return {}
end
love.window.isVisible = function()
  return {}
end
love.window.isMaximized = function()
  return {}
end
love.window.setTitle = function(title)
  return {}
end
love.window.showMessageBox = function(title, message, type, attachtowindow)
  return {}
end
love.window.setPosition = function(x, y, displayindex)
  return {}
end
love.window.restore = function()
  return {}
end
love.window.getFullscreen = function()
  return {}
end
love.window.getPosition = function()
  return {}
end
love.window.setDisplaySleepEnabled = function(enable)
  return {}
end
love.window.hasFocus = function()
  return {}
end
love.window.getTitle = function()
  return {}
end
love.window.getSafeArea = function()
  return {}
end
love.window.getDesktopDimensions = function(displayindex)
  return {}
end
love.window.getFullscreenModes = function(displayindex)
  return {}
end
love.window.setVSync = function(vsync)
  return {}
end
love.window.isMinimized = function()
  return {}
end
love.window.isDisplaySleepEnabled = function()
  return {}
end
love.window.toPixels = function(value)
  return {}
end
love.window.getIcon = function()
  return {}
end
love.window.close = function()
  return {}
end
love.window.fromPixels = function(pixelvalue)
  return {}
end
love.window.getDPIScale = function()
  return {}
end
love.window.getVSync = function()
  return {}
end
love.window.hasMouseFocus = function()
  return {}
end
love.window.maximize = function()
  return {}
end
love.window.setMode = function(width, height, flags)
  return {}
end
love.window.requestAttention = function(continuous)
  return {}
end
love.window.setFullscreen = function(fullscreen)
  return {}
end
love.window.isOpen = function()
  return {}
end
love["keyboard"] = {}
love.keyboard.isScancodeDown = function(scancode, ...)
  return {}
end
love.keyboard.getScancodeFromKey = function(key)
  return {}
end
love.keyboard.hasScreenKeyboard = function()
  return {}
end
love.keyboard.setTextInput = function(enable)
  return {}
end
love.keyboard.hasTextInput = function()
  return {}
end
love.keyboard.hasKeyRepeat = function()
  return {}
end
love.keyboard.setKeyRepeat = function(enable)
  return {}
end
love.keyboard.getKeyFromScancode = function(scancode)
  return {}
end
love.keyboard.isDown = function(key)
  return {}
end
love["audio"] = {}
love.audio.newSource = function(filename, type)
  return {}
end
love.audio.getEffect = function(name)
  return {}
end
love.audio.getVelocity = function()
  return {}
end
love.audio.getRecordingDevices = function()
  return {}
end
love.audio.getActiveSourceCount = function()
  return {}
end
love.audio.getDopplerScale = function()
  return {}
end
love.audio.getActiveEffects = function()
  return {}
end
love.audio.setVelocity = function(x, y, z)
  return {}
end
love.audio.setVolume = function(volume)
  return {}
end
love.audio.newQueueableSource = function(samplerate, bitdepth, channels, buffercount)
  return {}
end
love.audio.setPosition = function(x, y, z)
  return {}
end
love.audio.setEffect = function(name, settings)
  return {}
end
love.audio.getPosition = function()
  return {}
end
love.audio.setOrientation = function(fx, fy, fz, ux, uy, uz)
  return {}
end
love.audio.getMaxSceneEffects = function()
  return {}
end
love.audio.setDopplerScale = function(scale)
  return {}
end
love.audio.getSourceCount = function()
  return {}
end
love.audio.getOrientation = function()
  return {}
end
love.audio.isEffectsSupported = function()
  return {}
end
love.audio.getDistanceModel = function()
  return {}
end
love.audio.getVolume = function()
  return {}
end
love.audio.pause = function()
  return {}
end
love.audio.getMaxSourceEffects = function()
  return {}
end
love.audio.stop = function()
  return {}
end
love.audio.setMixWithSystem = function(mix)
  return {}
end
love.audio.play = function(source)
  return {}
end
love.audio.setDistanceModel = function(model)
  return {}
end
love["touch"] = {}
love.touch.getPressure = function(id)
  return {}
end
love.touch.getTouches = function()
  return {}
end
love.touch.getPosition = function(id)
  return {}
end

if (nil ~= _G.love) then
  return _G.love
else
  return love
end
