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
