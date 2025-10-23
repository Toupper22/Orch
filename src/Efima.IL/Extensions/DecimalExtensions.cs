namespace Efima.IL.Extensions;
using System.Globalization;

public static class DecimalExtensions
{
    public static string ToStringNoSeparator(this decimal value, int decimalCount = 2)
    {
        var ci = CultureInfo.InvariantCulture;

        return value.ToString($"F{decimalCount}", ci)
            .Replace(ci.NumberFormat.NumberDecimalSeparator, string.Empty)
            .Replace(ci.NumberFormat.NumberGroupSeparator, string.Empty);
    }
}
