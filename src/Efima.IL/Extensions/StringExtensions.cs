namespace Efima.IL.Extensions;

public static class StringExtensions
{
    public static string EscapeHyphens(this string value)
    {
        return value.Replace("-", "\\-");
    }
}
