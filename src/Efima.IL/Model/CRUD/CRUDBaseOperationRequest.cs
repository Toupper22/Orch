namespace Efima.IL.Model.CRUD;

public class CRUDBaseOperationRequest
{
    /// <summary>
    /// rest of the URL after base path, which ends with slash
    /// </summary>
    public string RequestUri { get; set; }
}