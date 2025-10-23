namespace Efima.IL.Utils;

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

public class CsvData
{
    public readonly List<string[]> Records;
    public readonly IEnumerable<(string fieldName, int index)> Columns;

    public CsvData(string csv, string separator = ";")
    {

        // determine header from first line
        using var stringReader = new StringReader(csv);
        var line = stringReader.ReadLine();
        Columns = line.Split(separator)
            .Select((fieldName, index) => (fieldName, index));

        var separators = new string[] { ";", "\r\n" };
        var records = csv.Replace("\0", "")
            .Split(separators, StringSplitOptions.None)
            .Chunk(Columns.Count())
            .Skip(1);
        // skip last record if there is less than 2 fields
        Records = new List<string[]>();
        Records.AddRange(records.TakeLast(1).Count() > 1 ? records : records.SkipLast(1));
    }

    public string GetFieldValue(string[] record, string columnName)
    {
        var column = Columns.FirstOrDefault(x => x.fieldName == columnName);
        if (column == default)
        {
            throw new Exception($"Column {columnName} not defined");
        }
        return record[column.index];
    }
}
