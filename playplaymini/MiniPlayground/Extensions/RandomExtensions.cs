namespace MiniPlayground.Extensions;

static class RandomExtensions
{
    /// <summary>
    /// Returns a random element from the given enumerable.
    /// </summary>
    public static T Sample<T>(this Random random, IEnumerable<T> enumerable)
    {
        var list = enumerable as IList<T> ?? enumerable.ToList();
        return list[random.Next(list.Count)];
    }}