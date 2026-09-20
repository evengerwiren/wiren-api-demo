var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.WithOrigins("http://localhost:3000")
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.UseCors();

var apiKey = builder.Configuration["ApiKey"] ?? Environment.GetEnvironmentVariable("API_KEY") ?? "dev-local-key-change-me";

app.Use(async (context, next) =>
{
    if (context.Request.Path.StartsWithSegments("/swagger") ||
        context.Request.Path.StartsWithSegments("/api/health"))
    {
        await next();
        return;
    }

    if (!context.Request.Headers.TryGetValue("X-Api-Key", out var providedKey) || providedKey != apiKey)
    {
        context.Response.StatusCode = 401;
        await context.Response.WriteAsJsonAsync(new { error = "Unauthorized: Invalid or missing API key" });
        return;
    }

    await next();
});

app.MapGet("/api/health", () =>
{
    return Results.Ok(new
    {
        status = "ok",
        timeUtc = DateTime.UtcNow.ToString("o")
    });
})
.WithName("Health")
.WithOpenApi();

app.MapGet("/api/hello", (string? name) =>
{
    var greeting = string.IsNullOrWhiteSpace(name) ? "Hello, World!" : $"Hello, {name}!";
    return Results.Ok(new { message = greeting });
})
.WithName("Hello")
.WithOpenApi();

app.MapPost("/api/echo", (EchoRequest request) =>
{
    return Results.Ok(new
    {
        received = request,
        echoed = true,
        timestamp = DateTime.UtcNow.ToString("o")
    });
})
.WithName("Echo")
.WithOpenApi();

app.Run();

record EchoRequest(string? message, Dictionary<string, object>? data);
