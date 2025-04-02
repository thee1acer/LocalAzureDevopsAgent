#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER app
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Local Azure Devops Agent/Local Azure Devops Agent.csproj", "Local Azure Devops Agent/"]
RUN dotnet restore "./Local Azure Devops Agent/Local Azure Devops Agent.csproj"
COPY . .
WORKDIR "/src/Local Azure Devops Agent"
RUN dotnet build "./Local Azure Devops Agent.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./Local Azure Devops Agent.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Local Azure Devops Agent.dll"]