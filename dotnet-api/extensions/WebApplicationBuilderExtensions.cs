
namespace Extensions;

public static class WebApplicationBuilderExtensions
{
    public static WebApplicationBuilder ConfigureLogging(this WebApplicationBuilder builder, Configuration configuration)
    {
        builder.Logging.ClearProviders();
        if (System.Diagnostics.Debugger.IsAttached)
        {
            builder.Logging.AddDebug();
            Console.WriteLine("Debug logging enabled");
        }

        var applicationInsightsConnectionString =
            builder.Configuration.GetValue<string>("ApplicationInsights:ConnectionString");

        if (!string.IsNullOrWhiteSpace(applicationInsightsConnectionString))
        {
            builder.Services.AddApplicationInsightsTelemetry();
            Console.WriteLine("Application Insights logging enabled");
        }

        if (!configuration.DisableConsoleLog)
        {
            builder.Logging.AddConsole();
            Console.WriteLine("Console logging enabled");
        }

        return builder;
    }

    public static TConfig GetConfiguration<TConfig>(this WebApplicationBuilder builder) where TConfig : new()
    {
        var section = builder.Configuration.GetSection(typeof(TConfig).Name);

        if (section == null || !section.Exists())
        {
            throw new ApplicationException(
                $"Could not find configuration section. Please provide a '{typeof(TConfig).Name}' config section");
        }

        TConfig config = new TConfig();
        section.Bind(config);

        return config;
    }
}

