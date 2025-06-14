using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();

var app = builder.Build();

// Add a simple endpoint
app.MapGet("/", () => "Hello from .NET Web API!");

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();