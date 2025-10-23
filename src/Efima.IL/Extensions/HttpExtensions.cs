namespace Efima.IL.Extensions;

using Microsoft.AspNetCore.Http;

using Newtonsoft.Json;

using System;
using System.IO;
using System.Net.Http;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

public static class HttpExtensions
{
    public static async Task<dynamic> ReadBody(this HttpRequest req, string contentType = null, Encoding encoding = null)
    {
        var contentTypeProperties = req.GetContentTypeAndEncoding();

        dynamic reqContent = await req.ReadBodyAsJson(encoding ?? contentTypeProperties.Encoding);

        return reqContent;
    }

    public static async Task<T> ReadBodyAsJson<T>(this HttpRequest req)
    {
        var contentTypeProperties = req.GetContentTypeAndEncoding();
        using var sr = new StreamReader(req.Body, contentTypeProperties.Encoding);
        sr.DiscardBufferedData();
        sr.BaseStream.Position = 0;

        var reqContent = JsonConvert.DeserializeObject<T>(await sr.ReadToEndAsync());

        return reqContent;
    }

    public static async Task<T> ReadContentAsJson<T>(this HttpRequestMessage req, JsonSerializerSettings? settings = null)
    {
        var contentString = await req.Content?.ReadAsStringAsync()!;
        var reqContent = JsonConvert.DeserializeObject<T>(contentString, settings);
        return reqContent;
    }

    public static async Task<dynamic> ReadBodyAsJson(this HttpRequest req, Encoding encoding)
    {
        using var sr = new StreamReader(req.Body, encoding);
        sr.DiscardBufferedData();
        sr.BaseStream.Position = 0;

        dynamic reqContent = JsonConvert.DeserializeObject(await sr.ReadToEndAsync());

        return reqContent;
    }

    public static (string ContentType, Encoding Encoding) GetContentTypeAndEncoding(this HttpRequest req)
    {
        Encoding encoding = Encoding.UTF8;
        string contentType = req.ContentType;

        try
        {
            if (!string.IsNullOrEmpty(contentType) && contentType.Contains("charset"))
            {
                var match = new Regex(@"charset=([a-zA-Z0-9-]*)").Match(contentType);

                if (match.Success)
                    encoding = Encoding.GetEncoding(match.Groups[1].Value);
            }

            if (!string.IsNullOrEmpty(contentType))
            {
                var match = new Regex(@"\A([0-9a-zA-Z.+-/]*)(?:[;]?)").Match(contentType);

                if (match.Success)
                    contentType = match.Groups[1].Value.ToLowerInvariant();
            }
        }
        catch (Exception ex)
        {
            throw new Exception($"Failed to parse content type from Content-Type header value {contentType}", ex);
        }

        return (contentType, encoding);
    }
}
