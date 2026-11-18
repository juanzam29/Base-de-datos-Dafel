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
    return [System.Web.HttpUtility]::HtmlDecode(
        [regex]::Replace($Value, '<.*?>', '')
    ).Trim()
}

function Quote-SqlUnicode {
    param([string]$Value)
    return "N'" + $Value.Replace("'", "''") + "'"
}

$archive = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
try {
    $entry = $archive.GetEntry('06_Diccionario_Referencia.html')
    $reader = [System.IO.StreamReader]::new($entry.Open(),[System.Text.Encoding]::UTF8,$true)
    try { $html = $reader.ReadToEnd() } finally { $reader.Dispose() }
}
finally { $archive.Dispose() }

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("USE [$DatabaseName];")
$lines.Add('GO')
$lines.Add('SET NOCOUNT ON;')
$lines.Add('GO')

$sections = [regex]::Matches(
    $html,
    '(?s)<h2 id="(?<name>[^"]+)">.*?</h2>(?<body>.*?)(?=<h2(?: id=|>))'
)

foreach ($section in $sections) {
    $tableName = $section.Groups['name'].Value
    $body = $section.Groups['body'].Value
    $paragraph = [regex]::Match($body,'(?s)^<p>(?<description>.*?)</p>')
    $tableDescription = ConvertFrom-HtmlFragment $paragraph.Groups['description'].Value

    $lines.Add("EXEC sys.sp_addextendedproperty @name=N'MS_Description',@value=$(Quote-SqlUnicode $tableDescription),@level0type=N'SCHEMA',@level0name=N'dbo',@level1type=N'TABLE',@level1name=$(Quote-SqlUnicode $tableName);")

    $tableMatch = [regex]::Match($body,'(?s)<table>(?<table>.*?)</table>')
    $rows = [regex]::Matches($tableMatch.Groups['table'].Value,'(?s)<tr>(?<row>.*?)</tr>') | Select-Object -Skip 1
    foreach ($row in $rows) {
        $cells = [regex]::Matches($row.Groups['row'].Value,'(?s)<td>(?<cell>.*?)</td>')
        $columnName = ConvertFrom-HtmlFragment $cells[0].Groups['cell'].Value
        $description = ConvertFrom-HtmlFragment $cells[4].Groups['cell'].Value
        $lines.Add("EXEC sys.sp_addextendedproperty @name=N'MS_Description',@value=$(Quote-SqlUnicode $description),@level0type=N'SCHEMA',@level0name=N'dbo',@level1type=N'TABLE',@level1name=$(Quote-SqlUnicode $tableName),@level2type=N'COLUMN',@level2name=$(Quote-SqlUnicode $columnName);")
    }
}

$manual = @(
    @('ConceptoCotizacion','tipo_concepto','Clasificacion estructurada del concepto: transporte, montaje, desmontaje u otro.'),
    @('CargoAlquiler','tipo_cargo','Clasificacion estructurada del cargo: retraso, dano, faltante u otro.'),
    @('Pago','tipo_pago','Aplicacion economica del pago: anticipo, abono o saldo.'),
    @('Alquiler','porcentaje_anticipo_requerido','Porcentaje del valor inicial que debe estar pagado antes del primer despacho.'),
    @('Documento','hash_sha256','Huella SHA-256 opcional para comprobar la integridad del archivo externo.'),
    @('Documento','tamano_bytes','Tamano opcional del archivo externo expresado en bytes.')
)

foreach ($item in $manual) {
    $lines.Add("EXEC sys.sp_addextendedproperty @name=N'MS_Description',@value=$(Quote-SqlUnicode $item[2]),@level0type=N'SCHEMA',@level0name=N'dbo',@level1type=N'TABLE',@level1name=$(Quote-SqlUnicode $item[0]),@level2type=N'COLUMN',@level2name=$(Quote-SqlUnicode $item[1]);")
}

$lines.Add('GO')
$lines.Add("PRINT N'DESCRIPCIONES COMPLETADAS';")
$lines.Add('GO')

[System.IO.File]::WriteAllLines($OutputPath,$lines,[System.Text.UTF8Encoding]::new($true))
Write-Output "Descripciones generadas en $OutputPath"
