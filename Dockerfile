FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

COPY ./myapp ./myapp

ENTRYPOINT ["dotnet", "myapp.dll"]