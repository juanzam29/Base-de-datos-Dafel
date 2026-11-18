param(
    [Parameter(Mandatory = $true)]
    [string]$ZipPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputDirectory,

    [string]$DatabaseName = 'DafelDB_Validacion'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Web

$archive = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
try {
    $entry = $archive.GetEntry('06_Diccionario_Referencia.html')
    if ($null -eq $entry) {
        throw 'El ZIP no contiene 06_Diccionario_Referencia.html.'
    }

    $reader = [System.IO.StreamReader]::new(
        $entry.Open(),
        [System.Text.Encoding]::UTF8,
        $true
    )
    try {
        $html = $reader.ReadToEnd()
    }
    finally {
        $reader.Dispose()
    }
}
finally {
    $archive.Dispose()
}

$preMatches = [regex]::Matches($html, '(?s)<pre[^>]*>(?<sql>.*?)</pre>')
if ($preMatches.Count -ne 99) {
    throw "Se esperaban 99 bloques SQL y se encontraron $($preMatches.Count)."
}

$blocks = foreach ($match in $preMatches) {
    [System.Web.HttpUtility]::HtmlDecode(
        [regex]::Replace($match.Groups['sql'].Value, '<.*?>', '')
    ).Trim()
}

$utf8Bom = [System.Text.UTF8Encoding]::new($true)

$domains = $blocks[0] -replace 'USE\s+DaferDB_Revision;', "USE [$DatabaseName];"
[System.IO.File]::WriteAllText(
    (Join-Path $OutputDirectory '002_Dominios_Estados.sql'),
    $domains + [Environment]::NewLine,
    $utf8Bom
)

$indexLines = [System.Collections.Generic.List[string]]::new()
$indexLines.Add("USE [$DatabaseName];")
$indexLines.Add('GO')
$indexLines.Add('SET XACT_ABORT ON;')
$indexLines.Add('BEGIN TRY')
$indexLines.Add('    BEGIN TRANSACTION;')
$indexLines.Add($blocks[97])
$indexLines.Add('    COMMIT TRANSACTION;')
$indexLines.Add("    PRINT N'INDICES COMPLETADOS';")
$indexLines.Add('END TRY')
$indexLines.Add('BEGIN CATCH')
$indexLines.Add('    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;')
$indexLines.Add('    THROW;')
$indexLines.Add('END CATCH;')
$indexLines.Add('GO')
[System.IO.File]::WriteAllLines(
    (Join-Path $OutputDirectory '003_Indices.sql'),
    $indexLines,
    $utf8Bom
)

$programmableLines = [System.Collections.Generic.List[string]]::new()
$programmableLines.Add("USE [$DatabaseName];")
$programmableLines.Add('GO')
$programmableLines.Add("IF SCHEMA_ID(N'operacion') IS NULL EXEC(N'CREATE SCHEMA operacion AUTHORIZATION dbo;');")
$programmableLines.Add("IF SCHEMA_ID(N'reporte') IS NULL EXEC(N'CREATE SCHEMA reporte AUTHORIZATION dbo;');")
$programmableLines.Add('GO')

for ($index = 1; $index -le 96; $index++) {
    $block = $blocks[$index]
    $block = [regex]::Replace(
        $block,
        '^(\s*)CREATE\s+TRIGGER',
        '$1CREATE OR ALTER TRIGGER',
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )
    $block = $block -replace '\bDaferDB\b', 'DafelDB'
    $block = $block -replace '\bDAFER\b', 'DAFEL'
    $block = $block -replace '\bDafer\b', 'Dafel'
    $block = $block -replace '\bdafer\b', 'dafel'
    $programmableLines.Add($block)
    $programmableLines.Add('GO')
}

[System.IO.File]::WriteAllLines(
    (Join-Path $OutputDirectory '004_Objetos_Programables.sql'),
    $programmableLines,
    $utf8Bom
)

Write-Output "Objetos de referencia generados en $OutputDirectory"
