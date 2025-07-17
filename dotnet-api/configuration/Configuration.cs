public class Configuration
{
    public bool DisableConsoleLog { get; set; }
    public EndpointConfiguration EndpointConfiguration { get; set; } = new();
}
