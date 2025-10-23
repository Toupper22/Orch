using Microsoft.AspNetCore.StaticFiles;

namespace Efima.IL.Services
{
    public interface IMimeMappingService
    {
        string Map(string fileName);
    }

    public class MimeMappingService : IMimeMappingService
    {
        private readonly FileExtensionContentTypeProvider _contentTypeProvider;

        public MimeMappingService()
        {
            _contentTypeProvider = new FileExtensionContentTypeProvider();
        }

        public string Map(string fileName)
        {
            if (!_contentTypeProvider.TryGetContentType(fileName, out string contentType))
            {
                contentType = "application/octet-stream";
            }
            return contentType;
        }
    }
}
