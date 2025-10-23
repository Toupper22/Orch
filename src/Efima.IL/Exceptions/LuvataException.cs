namespace Efima.IL.Exceptions;
using System;

public class DemoException : Exception
{
    public DemoException()
    {
    }

    public DemoException(string message)
        : base(message)
    {
    }

    public DemoException(string message, Exception innerException)
        : base(message, innerException)
    {
    }
}
