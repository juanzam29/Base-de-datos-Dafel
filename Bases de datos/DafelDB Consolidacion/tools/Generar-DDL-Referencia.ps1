param(
    [Parameter(Mandatory = $true)]
    [string]$ZipPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [string]$DatabaseName = 'DafelDB_Validacion'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Web

function ConvertFrom-HtmlFragment {
    param([string]$Value)

    $withoutTags = [regex]::Replace($Value, '<.*?>', '')
    return [System.Web.HttpUtility]::HtmlDecode($withoutTags).Trim()
}

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

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('/*')
$lines.Add('  DDL base generado desde el diccionario de referencia recibido.')
$lines.Add('  Revisado y ejecutado primero en una base de validacion.')
$lines.Add('*/')
$lines.Add("USE [$DatabaseName];")
$lines.Add('GO')
$lines.Add('SET NOCOUNT ON;')
$lines.Add('SET XACT_ABORT ON;')
$lines.Add('GO')
$lines.Add('BEGIN TRY')
$lines.Add('    BEGIN TRANSACTION;')
$lines.Add('')

$sectionPattern = '(?s)<h2 id="(?<name>[^"]+)">.*?</h2>(?<body>.*?)(?=<h2(?: id=|>))'
$sections = [regex]::Matches($html, $sectionPattern)
if ($sections.Count -ne 68) {
    throw "Se esperaban 68 tablas en el diccionario y se encontraron $($sections.Count)."
}

foreach ($section in $sections) {
    $tableName = $section.Groups['name'].Value
    $body = $section.Groups['body'].Value
    $tableMatch = [regex]::Match($body, '(?s)<table>(?<table>.*?)</table>')
    if (-not $tableMatch.Success) {
        throw "No se encontro la definicion de columnas de $tableName."
    }

    $definitions = [System.Collections.Generic.List[string]]::new()
    $rows = [regex]::Matches($tableMatch.Groups['table'].Value, '(?s)<tr>(?<row>.*?)</tr>')
    foreach ($row in ($rows | Select-Object -Skip 1)) {
        $cells = [regex]::Matches($row.Groups['row'].Value, '(?s)<td>(?<cell>.*?)</td>')
        if ($cells.Count -lt 6) {
            throw "Fila de columna incompleta en $tableName."
        }

        $columnName = ConvertFrom-HtmlFragment $cells[0].Groups['cell'].Value
        $sqlDefinition = ConvertFrom-HtmlFragment $cells[5].Groups['cell'].Value
        if ($tableName -eq 'Auditoria' -and $columnName -eq 'id_auditoria') {
            $sqlDefinition = 'BIGINT IDENTITY(1,1) NOT NULL'
        }
        elseif ($tableName -eq 'Auditoria' -and $columnName -eq 'fecha') {
            $sqlDefinition = 'DATETIME2(0) NOT NULL CONSTRAINT DF_Auditoria_fecha DEFAULT SYSDATETIME()'
        }
        elseif ($tableName -eq 'Auditoria' -and $columnName -eq 'usuario_sql') {
            $sqlDefinition = 'SYSNAME NOT NULL CONSTRAINT DF_Auditoria_usuario_sql DEFAULT ORIGINAL_LOGIN()'
        }
        $definitions.Add("        [$columnName] $sqlDefinition")
    }

    $constraintsMatch = [regex]::Match(
        $body,
        '(?s)<summary>Restricciones declaradas</summary><ul>(?<items>.*?)</ul>'
    )
    if ($constraintsMatch.Success) {
        $constraintMatches = [regex]::Matches(
            $constraintsMatch.Groups['items'].Value,
            '(?s)<li><code>(?<constraint>.*?)</code></li>'
        )
        foreach ($constraintMatch in $constraintMatches) {
            $constraint = ConvertFrom-HtmlFragment $constraintMatch.Groups['constraint'].Value
            switch -Regex ($constraint) {
                '^CONSTRAINT ' {
                    $definitions.Add("        $constraint")
                    break
                }
                '^CK_Incidencia_costo_estimado:' {
                    $definitions.Add('        CONSTRAINT CK_Incidencia_costo_estimado CHECK (costo_estimado IS NULL OR costo_estimado >= 0)')
                    break
                }
                '^CK_Evaluacion_decision_cliente:' {
                    $definitions.Add("        CONSTRAINT CK_Evaluacion_decision_cliente CHECK (decision_cliente IS NULL OR decision_cliente IN ('PENDIENTE','ACEPTA','RECHAZA','SIN_RESPUESTA'))")
                    break
                }
                '^PRIMARY KEY \(id_auditoria\)$' {
                    $definitions.Add('        CONSTRAINT PK_Auditoria PRIMARY KEY (id_auditoria)')
                    break
                }
                '^DEFAULT fecha = SYSDATETIME\(\)$' {
                    break
                }
                '^DEFAULT usuario_sql = ORIGINAL_LOGIN\(\)$' {
                    break
                }
                '^PK_DevolucionDocumento PRIMARY KEY' {
                    $definitions.Add("        CONSTRAINT $constraint")
                    break
                }
                default {
                    throw "Restriccion no reconocida en $tableName`: $constraint"
                }
            }
        }
    }

    $lines.Add("    PRINT N'Creando dbo.$tableName';")
    $lines.Add("    CREATE TABLE dbo.[$tableName]")
    $lines.Add('    (')
    for ($index = 0; $index -lt $definitions.Count; $index++) {
        $suffix = if ($index -lt $definitions.Count - 1) { ',' } else { '' }
        $lines.Add($definitions[$index] + $suffix)
    }
    $lines.Add('    );')
    $lines.Add('')
}

$relationshipsMatch = [regex]::Match(
    $html,
    '(?s)<h2>Relaciones completas</h2>.*?<table>(?<table>.*?)</table>'
)
if (-not $relationshipsMatch.Success) {
    throw 'No se encontro la tabla de relaciones completas.'
}

$relationshipRows = [regex]::Matches(
    $relationshipsMatch.Groups['table'].Value,
    '(?s)<tr>(?<row>.*?)</tr>'
) | Select-Object -Skip 1

if ($relationshipRows.Count -ne 129) {
    throw "Se esperaban 129 relaciones y se encontraron $($relationshipRows.Count)."
}

foreach ($row in $relationshipRows) {
    $cells = [regex]::Matches($row.Groups['row'].Value, '(?s)<td>(?<cell>.*?)</td>')
    if ($cells.Count -lt 3) {
        throw 'Fila de relacion incompleta.'
    }

    $constraintName = ConvertFrom-HtmlFragment $cells[0].Groups['cell'].Value
    $child = ConvertFrom-HtmlFragment $cells[1].Groups['cell'].Value
    $parent = ConvertFrom-HtmlFragment $cells[2].Groups['cell'].Value

    if ($child -notmatch '^(?<table>[^.]+)\.(?<column>.+)$') {
        throw "Referencia hija invalida: $child."
    }
    $childTable = $Matches['table']
    $childColumn = $Matches['column']

    if ($parent -notmatch '^(?<table>[^.]+)\.(?<column>.+)$') {
        throw "Referencia padre invalida: $parent."
    }
    $parentTable = $Matches['table']
    $parentColumn = $Matches['column']

    $lines.Add("    ALTER TABLE dbo.[$childTable] WITH CHECK")
    $lines.Add("        ADD CONSTRAINT [$constraintName]")
    $lines.Add("        FOREIGN KEY ([$childColumn])")
    $lines.Add("        REFERENCES dbo.[$parentTable] ([$parentColumn]);")
    $lines.Add('')
}

$lines.Add('    COMMIT TRANSACTION;')
$lines.Add("    PRINT N'DDL BASE COMPLETADO';")
$lines.Add('END TRY')
$lines.Add('BEGIN CATCH')
$lines.Add('    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;')
$lines.Add('    THROW;')
$lines.Add('END CATCH;')
$lines.Add('GO')

[System.IO.File]::WriteAllLines(
    $OutputPath,
    $lines,
    [System.Text.UTF8Encoding]::new($true)
)

Write-Output "DDL generado en $OutputPath"
