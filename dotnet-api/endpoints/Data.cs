using System.Text.Json;

public static class Data
{
    public static async Task<IResult> GetData(IConfiguration config, IHttpClientFactory httpClientFactory, HttpRequest request, ILoggerFactory loggerFactory)
    {
        var logger = loggerFactory.CreateLogger("Data");
        logger.LogInformation($"LocalIpAddress: {request.HttpContext.Connection.LocalIpAddress}");
        logger.LogInformation($"RemoteIpAddress: {request.HttpContext.Connection.RemoteIpAddress}");
        var client = httpClientFactory.CreateClient();
        var endpoint = config.GetValue<string>("Configuration:EndpointConfiguration:DataEndpoint");
        var result = await client.GetFromJsonAsync<JsonDocument>(endpoint);
        return Results.Ok(result ?? JsonDocument.Parse(string.Empty));
    }

    public static IResult GetHeaders(IConfiguration config, IHttpClientFactory httpClientFactory, HttpRequest request, ILoggerFactory loggerFactory)
    {
        var logger = loggerFactory.CreateLogger("Headers");
        var result = request.Headers.ToDictionary(x => x.Key, x => x.Value);
        return Results.Ok(result);
    }
}