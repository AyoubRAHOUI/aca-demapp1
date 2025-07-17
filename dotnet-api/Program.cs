using Extensions;

Console.WriteLine("Starting Application");

var builder = WebApplication.CreateBuilder(args);
var config = builder.GetConfiguration<Configuration>();
builder.Services.AddSingleton(config);
builder.ConfigureLogging(config);
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHttpClient();
builder.Services.AddApplicationInsightsTelemetry();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
app.MapGet("/api/data", Data.GetData);
app.MapGet("/api/headers", Data.GetHeaders);

app.Run();
