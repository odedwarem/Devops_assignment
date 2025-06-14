# Build stage - uses SDK image to compile the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy the source code
COPY . .

# Publish the application in Release mode
RUN dotnet publish -c Release -o /app/publish

# Runtime stage - uses smaller runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# Copy the published application from build stage
COPY --from=build /app/publish .

# Expose port 80 for the application
EXPOSE 80

# Set the entry point to run the application
ENTRYPOINT ["dotnet", "myapp.dll"]