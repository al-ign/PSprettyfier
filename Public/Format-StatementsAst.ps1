filter Format-AssignmentStatementAst {
param (
[Parameter(ValueFromPipeline=$true)]$Statement,$tab = 0
)
$t1 = '    ' * $tab
    $thisOperator = $Statement.Operator
    switch ($Statement.Operator) {
        'Equals' {$Operator = '='}
        'PlusEquals' {$Operator = '+='}
        'MinusEquals' {$Operator = '-='}
        'MultiplyEquals' {$Operator = '*='}
        'DivideEquals' {$Operator = '/='}
        'RemainderEquals' {$Operator = '%='}

        default {
        'write-error "unknown Operator {0} in Format-AssignmentStatementAst; break; ###ERRORFORMAT###' -f $thisOperator }
        }#ENd switch
    '{0}{1} {2} {3}' -f $t1, $Statement.Left, $Operator, $Statement.Right 
    }

filter Format-ForEachStatementAst {[CmdletBinding()]
param (
[Parameter(ValueFromPipeline=$true)]$Statement,$tab = 0)
$t1 = '    ' * $tab
    '{0}foreach   (  {1}   in    {2}  ) {{' -f $t1,$Statement.Variable, $Statement.Condition
    Format-StatementsAst -Statement $Statement.Body.Statements -tab ($tab + 1)
    '    {0}}} # End of foreach {1} in {2} #' -f $t1,$Statement.Variable, $Statement.Condition
    }

filter Format-IfStatementAst {[CmdletBinding()]
param ([Parameter(ValueFromPipeline=$true)]$Statement,$tab = 0)
$t1 = '    ' * $tab
    for ($iClause = 0; $iClause -lt $Statement.Clauses.Count;$iClause++) {
    
        if ($iClause -eq 0) {
        '{0}if ({1}) {{' -f $t1,$Statement.Clauses[$iClause].Item1
        }
        else {
        '{0}elseif ({1}) {{' -f $t1,$Statement.Clauses[$iClause].Item1
        }
        Format-StatementsAst -Statement $Statement.Clauses[$iClause].Item2.Statements -tab $($tab + 1)
        if ($iClause -eq 0) {
        '    {0}}} #End of if ({1})' -f $t1,$Statement.Clauses[$iClause].Item1
                }
        else {
        '    {0}}} #End of elseif ({1})' -f $t1,$Statement.Clauses[$iClause].Item1
        }
        }

    foreach ($elseClause in $Statement.ElseClause) {
        '{0}else {{' -f $t1
        Format-StatementsAst -Statement $ElseClause.Statements -tab $($tab + 1)
        '    {0}}} # End of else clause '  -f $t1
        }
    ''
    }

filter Format-PipelineAst {[CmdletBinding()]
param ([Parameter(ValueFromPipeline=$true)]$Statement,$tab = 0)
$t1 = '    ' * $tab
foreach ($pipeline in $Statement.PipelineElements)  {
    '{0}{1}' -f $t1, $pipeline.Extent.Text
    }
}

filter Format-ForStatementAst {[CmdletBinding()]
param ([Parameter(ValueFromPipeline=$true)]$Statement,$tab = 0)
$t1 = '    ' * $tab
'{0} for ({1}; {2}; {3}) {{' -f $t1,$Statement.Initializer, $Statement.Condition, $Statement.Iterator
Format-StatementsAst -Statement $Statement.Body.Statements -tab ($tab + 1)
'    {0}}} # End of for ({1}...' -f $t1,$Statement.Initializer
''
}


function Format-StatementsAst {
param ($Statement,$tab = 0)
$t1 = '    ' * $tab
 for ($iStatement = 0 ; $iStatement -lt $Statement.Count; $iStatement++) {
        #''+ $iStatement + ' ' + $Statement[$iStatement].Extent.Text
        switch ($Statement[$iStatement].GetType().Name) {
            'ForEachStatementAst' {
                $Statement[$iStatement] | Format-ForEachStatementAst -tab ($tab + 1 )
                }
            'AssignmentStatementAst' {
                $Statement[$iStatement] | Format-AssignmentStatementAst -tab ($tab + 1 )
                }
            'IfStatementAst' {
                $Statement[$iStatement] | Format-IfStatementAst -tab ($tab + 1 ) 
                }
            'PipelineAst' {
                $Statement[$iStatement] | Format-PipelineAst -tab ($tab + 1 ) 
                }
            'ForStatementAst' {
                $Statement[$iStatement] | Format-ForStatementAst -tab ($tab + 1 ) 
                }
            default {
                if ($ParsingComments) {
                    '{0}#[{1}] Ast Statement: {2}'-f $t1,$iStatement, $Statement[$iStatement].GetType().Name
                    }
                if ($Statement.Body.Statements) {
                    Format-StatementsAst -Statement $Statement.Body.Statements -tab ($tab + 1)
                    }
                else {
                    $t1 + '#Plain Extent'
                    $t1 + $Statement[$iStatement].Extent.Text 
                    }
                }
            }#End switch
        }
 }#End 