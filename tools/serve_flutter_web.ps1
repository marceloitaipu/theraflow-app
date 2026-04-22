param(
    [int]$Port = 9090,
    [string]$Root = "build/web"
)

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$webRoot = [System.IO.Path]::GetFullPath((Join-Path $workspaceRoot $Root))

if (-not (Test-Path $webRoot)) {
    throw "Diretorio nao encontrado: $webRoot"
}

$listener = [System.Net.HttpListener]::new()
$prefix = "http://localhost:$Port/"
$listener.Prefixes.Add($prefix)
$listener.Start()

Write-Host "Serving $webRoot at $prefix"

$contentTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".js" = "application/javascript; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".css" = "text/css; charset=utf-8"
    ".png" = "image/png"
    ".jpg" = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".svg" = "image/svg+xml"
    ".ico" = "image/x-icon"
    ".wasm" = "application/wasm"
    ".ttf" = "font/ttf"
    ".otf" = "font/otf"
    ".frag" = "text/plain; charset=utf-8"
    ".bin" = "application/octet-stream"
    ".txt" = "text/plain; charset=utf-8"
}

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        try {
            $relativePath = [System.Uri]::UnescapeDataString($request.Url.AbsolutePath.TrimStart('/'))
            if ([string]::IsNullOrWhiteSpace($relativePath)) {
                $relativePath = "index.html"
            }

            $candidatePath = Join-Path $webRoot $relativePath.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
            $extension = [System.IO.Path]::GetExtension($relativePath)
            $isRouteLike = [string]::IsNullOrEmpty($extension)

            if (-not (Test-Path $candidatePath -PathType Leaf)) {
                if ($isRouteLike) {
                    $candidatePath = Join-Path $webRoot "index.html"
                } else {
                    Write-Host "404 $($request.Url.AbsolutePath)"
                    $response.StatusCode = 404
                    $response.Close()
                    continue
                }
            }

            $resolvedExtension = [System.IO.Path]::GetExtension($candidatePath).ToLowerInvariant()
            $contentType = $contentTypes[$resolvedExtension]
            if (-not $contentType) {
                $contentType = "application/octet-stream"
            }

            Write-Host "200 $($request.Url.AbsolutePath) -> $candidatePath"
            $bytes = [System.IO.File]::ReadAllBytes($candidatePath)
            $response.StatusCode = 200
            $response.ContentType = $contentType
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.OutputStream.Close()
        } catch {
            Write-Host "500 $($request.Url.AbsolutePath) $_"
            $response.StatusCode = 500
            $response.Close()
        }
    }
} finally {
    $listener.Stop()
    $listener.Close()
}