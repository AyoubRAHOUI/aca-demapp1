##################################################
# Multi-stage build for .NET 9.0 API
##################################################

FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS base
WORKDIR /app
EXPOSE 80

# Create non-root user for security
RUN addgroup -g 1001 -S dotnet && \
    adduser -S -D -H -u 1001 -h /app -s /sbin/nologin -G dotnet -g dotnet dotnet

# Set environment variables
ENV ASPNETCORE_URLS=http://+:80 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

##################################################
# Build stage
##################################################

FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build
WORKDIR /src

# Install curl for health check in final image
RUN apk add --no-cache curl

# Copy project file first for better caching
COPY ["dotnet-api.csproj", "./"]

# Restore dependencies
RUN dotnet restore "dotnet-api.csproj" --use-current-runtime

# Copy source code
COPY . .

# Build the application
RUN dotnet build "dotnet-api.csproj" -c Release -o /app/build --no-restore

##################################################
# Publish stage
##################################################

FROM build AS publish
RUN dotnet publish "dotnet-api.csproj" -c Release -o /app/publish \
    --no-restore \
    /p:UseAppHost=false \
    /p:PublishTrimmed=true \
    /p:PublishSingleFile=false

##################################################
# Final stage
##################################################

FROM base AS final
WORKDIR /app

# Install curl for health check
RUN apk add --no-cache curl

# Copy published application
COPY --from=publish /app/publish .

# Set proper permissions
RUN chown -R dotnet:dotnet /app

# Switch to non-root user
USER dotnet

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Start the application
ENTRYPOINT ["dotnet", "dotnet-api.dll"]
