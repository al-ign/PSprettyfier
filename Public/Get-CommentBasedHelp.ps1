function Get-CommentBasedHelp {
    param (
        $Command
    ) # End of param block

    process {
        $c = Get-Command $Command
        $b = $c.ScriptBlock.ast.Body | select * -ExcludeProperty parent
        $fulltext = $b.Extent.Text
        if ($b.ParamBlock -ne $null) {
    $code = $b.ParamBlock.Extent.Text
    $fulltext = $fulltext -replace ([regex]::Escape($code))
    }
        if ($b.BeginBlock -ne $null) {
    $code = $b.BeginBlock.Extent.Text
    $fulltext = $fulltext -replace ([regex]::Escape($code))
    }
        if ($b.ProcessBlock -ne $null) {
    $code = $b.ProcessBlock.Extent.Text
    $fulltext = $fulltext -replace ([regex]::Escape($code))
    }
        if ($b.EndBlock -ne $null) {
    $code = $b.EndBlock.Extent.Text
    $fulltext = $fulltext -replace ([regex]::Escape($code))
    }
        if ( $fulltext  -match '<#[\s\S]+\.SYNOPSIS[\s\S]+#>') {
    $Matches[0]
    }
    } # End of end block

} # end of function Get-CommentBasedHelp
