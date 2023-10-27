using System.Runtime.CompilerServices;
using BenMakesGames.PlayPlayMini.Services;
using Microsoft.Xna.Framework;

namespace MiniPlayground.Entities;

class SimpleCamera(
    GraphicsManager _graphics
)
{
    public Vector2 position = new(_graphics.Width / 2, _graphics.Height / 2);
    public float rotation = 0.0f;
    public float zoom = 1.0f;

    private Vector2 _lastPosition = Vector2.Zero;
    private float _lastRotation = 0.0f;
    private float _lastZoom = 1.0f;

    /// <summary
    /// This matrix will point to the center of the screen, and then translate
    /// to the position of the camera (the pivot is the center of the screen)
    /// </summary>
    /// <returns>A Matrix that represents the transformation.</returns>
    public Matrix GetTransformMatrix() =>
         Matrix.CreateTranslation(new Vector3(-position.X, -position.Y, 0)) *
            Matrix.CreateRotationZ(rotation) *
            Matrix.CreateScale(zoom) *
            Matrix.CreateTranslation(new Vector3(_graphics.Width * 0.5f, _graphics.Height * 0.5f, 0));


    public void ResetTransform()
    {
        position = new(_graphics.Width / 2, _graphics.Height / 2);
        rotation = 0.0f;
        zoom = 1.0f;
    }

    public void SetTransformMatrix()
    {
        // only set if the transform has changed
        if (position != _lastPosition || rotation != _lastRotation || zoom != _lastZoom)
        {
            _graphics.SetTransformMatrix(GetTransformMatrix());
            _lastPosition = position;
            _lastRotation = rotation;
            _lastZoom = zoom;
        }
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public void UnsetTransform()
    {
        _graphics.SetTransformMatrix(null);
    }
}