using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

// Create a new web application builder
var builder = WebApplication.CreateBuilder(args);

// Build the application
var app = builder.Build();

// Define a simple endpoint that returns a greeting message
app.MapGet("/", () => "Hello from .NET Web API!");

// Start the application
app.Run();