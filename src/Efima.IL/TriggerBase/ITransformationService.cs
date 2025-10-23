namespace Efima.IL.TriggerBase;
using Microsoft.AspNetCore.Mvc;

using System.IO;
using System.Threading.Tasks;

public interface ITransformationService
{
    Task<IActionResult> Run(Stream input);
}
