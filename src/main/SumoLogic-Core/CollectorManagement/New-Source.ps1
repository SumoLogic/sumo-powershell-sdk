<#
.SYNOPSIS
Create a source in specific collector

.DESCRIPTION
Create a new source in specific collector with json string or PSObject with source definition

.PARAMETER Session
An instance of SumoAPISession which contains API endpoint and credential

.PARAMETER CollectorId
The id of collector in long

.PARAMETER Source
A PSObject contains source definition

.PARAMETER Json
A string contains source definition in json format

.PARAMETER Force
Do not confirm before running

.EXAMPLE
New-Source -CollectorId 12345 -Source $source
Create a source under collector 12345 with the definition in $source

.EXAMPLE
Get-Content source.json -Raw | New-Source -CollectorId 12345
Create a source under collector 12345 with the definition in source.json

.INPUTS
PSObject to present collector (for the new source created on)

.OUTPUTS
PSObject to present source

.NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter

.LINK
https://github.com/SumoLogic/sumo-powershell-sdk/blob/master/docs/New-Source.md

.LINK
https://help.sumologic.com/APIs/01Collector-Management-API/
#>

function New-Source {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
  param(
    [SumoAPISession]$Session = $sumoSession,
    [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [alias('id')]
    [long]$CollectorId,
    [parameter(ParameterSetName = "ByObject", Position = 1)]
    [psobject]$Source,
    [parameter(ParameterSetName = "ByJson", Position = 1)]
    [string]$Json,
    [switch]$Force
  )
  process {
    $collector = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$CollectorId").collector
    if (!$collector) {
      Write-Error "Cannot get collector with id $CollectorId"
    }
    switch ($PSCmdlet.ParameterSetName) {
      "ByObject" {
        $Json = convertSourceToJson($Source)
      }
      "ByJson" {
        $Source = (ConvertFrom-Json $Json).source
      }
    }
    if ($collector -and ($Force -or $PSCmdlet.ShouldProcess("Create $($Source.sourceType) source with name $($Source.name) in collector $(getFullName $collector)]. Continue?"))) {
      $res = invokeSumoRestMethod -session $Session -method Post -function "collectors/$collectorId/sources" -body $Json
    }
    if ($res) {
      $newSource = $res.source
      Add-Member -InputObject $newSource -MemberType NoteProperty -Name collectorId -Value $CollectorId -PassThru
    }
  }
}
