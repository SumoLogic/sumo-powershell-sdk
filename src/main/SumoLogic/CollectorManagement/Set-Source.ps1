<#
.SYNOPSIS
    Source
.DESCRIPTION
    Edit sources.
.EXAMPLE
    Set-Source
#>

function Set-Source {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact="Medium")]
  param(
    $Session = $Script:sumoSession,
    [parameter(Mandatory = $true, ValueFromPipeline = $true)]
    $Source,
    [switch]$Passthru,
    [switch]$Force
  )
  process {
    $collectorId = $Source.collectorId
    $sourceId = $Source.id
    $org = invokeSumoWebRequest -session $Session -method Get -function "collectors/$collectorId/sources/$sourceId"
    $etag = $org.Headers.ETag
    $headers = @{
      "If-Match"     = $etag[0]
      'content-type' = 'application/json'
      'accept'       = 'application/json'
    }
    $target = ConvertFrom-Json $org.Content
    $target.source = $Source
    if ($Force -or $PSCmdlet.ShouldProcess("Will update the source $($target.source.name), continue?")) {
      $res = invokeSumoRestMethod -session $Session -headers $headers -method Put -function "collectors/$collectorId/sources/$sourceId" -content $target
    }
    if ($res -and $Passthru) {
      ($res.source)
    }
  }
}
