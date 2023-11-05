using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

namespace MiniPlayground.Utils;

public static class ColorUtils
{
    public static Color FromHex(string hex)
    {
        hex = hex.Replace("_", "");

        if (hex.StartsWith('#'))
        {
            hex = hex[1..];
        }

        if (hex.Length == 6)
        {
            return new Color(
                r: byte.Parse(hex.Substring(0, 2), System.Globalization.NumberStyles.HexNumber),
                g: byte.Parse(hex.Substring(2, 2), System.Globalization.NumberStyles.HexNumber),
                b: byte.Parse(hex.Substring(4, 2), System.Globalization.NumberStyles.HexNumber)
            );
        }
        else if (hex.Length == 8)
        {
            return new Color(
                r: byte.Parse(hex.Substring(0, 2), System.Globalization.NumberStyles.HexNumber),
                g: byte.Parse(hex.Substring(2, 2), System.Globalization.NumberStyles.HexNumber),
                b: byte.Parse(hex.Substring(4, 2), System.Globalization.NumberStyles.HexNumber),
                alpha: byte.Parse(hex.Substring(6, 2), System.Globalization.NumberStyles.HexNumber)
            );
        }
        else
        {
            throw new ArgumentException("Hex string must be either 6 or 8 characters long.");
        }

    }
}
