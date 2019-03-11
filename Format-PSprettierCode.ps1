function Format-PSprettierCode {
param (
    $FunctionName
    )
    #>
$command = Get-Command $FunctionName
$body = $command.ScriptBlock.Ast.Body
$tab = 0
$t1 = '    ' * $tab
  
'function {0} {{' -f $command.ScriptBlock.Ast.Name

if ($body.ParamBlock) {
<#
'Param ('
foreach ($attribute in $body.ParamBlock.Attributes) {
    $attribute.Extent.Text
    }
for ($iParameter = 0; $iParameter -lt $body.ParamBlock.Parameters.Count; $iParameter++) {
    $Parameter = $body.ParamBlock.Parameters[$iParameter]
    
    if ($iParameter -ne @($body.ParamBlock.Parameters).GetUpperBound(0) ) {
        $Parameter.Extent.Text + ','
        }
    else {
        $Parameter.Extent.Text
        }
    }
') # End of Param list'
''
#>
    $parameters = foreach ($thisParam in  $body.ParamBlock.Parameters) {
        [string]$att = foreach ($thisAttribute in $thisParam.Attributes) {
            switch ($thisAttribute.GetType().Name) {
                'AttributeAst' {
                    $namedString = @($thisAttribute.NamedArguments | % { $_.Extent.Text }) 
                    if ($namedString) {
                        '[{0}({1}{2}{1}    )]{1}' -f $thisAttribute.TypeName.Name,
                            [System.Environment]::NewLine, 
                            $( @($namedString | % {'    ' + $_}) -join ",$([System.Environment]::NewLine)" )
                        }
                
                    $positString = @($thisAttribute.PositionalArguments | % { $_.Extent.Text }) 
                    if ($positString) {
                
                        '[{0}({1})]{2}' -f $thisAttribute.TypeName.Name,($positString -Join ', '),[System.Environment]::NewLine
                        }
                    #attributes with no arguments, like [ValidateNotNull()]
                
                    $thisAttribute | ? {$_.NamedArguments.Count -eq 0} | ? {$_.PositionalArguments.Count -eq 0} | % { '{0}{1}' -f $_.Extent.Text,[System.Environment]::NewLine }
                
                    }
                default {
                
                    '{0}' -f $thisAttribute.Extent.Text,[System.Environment]::NewLine
                    }
                }#End switch
            }#End Attrib
            '{0}{1}' -f $att,$thisParam.Name.Extent.Text
        } 
    'Param ('
    $parameters -join ", $([System.Environment]::NewLine)$([System.Environment]::NewLine)"
    ') # End of Param list'
    ''

}



$blocks = 'StartBlock','ProcessBlock','EndBlock'
 
foreach ($thisBlock in $blocks) {
$block = $body.$thisBlock

if ($block.Statements) {
    '{0}{1} {{' -f $t1,$block.BlockKind
    Format-StatementsAst -Statement $block.Statements -tab ($tab + 1)
    '{0}}} # End of {1} block' -f $t1,$block.BlockKind
    ''
    } # end block statements
}
'}} # End of function {0}' -f $command.ScriptBlock.Ast.Name
}
