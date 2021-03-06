$mInfo = $MyInvocation.MyCommand.ScriptBlock.Module
$mInfo.OnRemove = {
     if ($Script:conn.state -eq 'open')
     {
        Write-Host -BackgroundColor Black -ForegroundColor Yellow "Connection $($Script:conn.database) closed"
        $Script:conn.Close()
     }
    
    Write-Host -BackgroundColor Black -ForegroundColor Yellow "$($MyInvocation.MyCommand.ScriptBlock.Module.name) removed on $(Get-Date)"
    Remove-IseMenu SQLIse
}

import-module ISECreamBasic
import-module SQLParser
import-module adolib
import-module WPK

. $psScriptRoot\Get-ConnectionInfo.ps1
. $psScriptRoot\Set-Options.ps1
. $psScriptRoot\Switch-CommentOrText.ps1
. $psScriptRoot\Switch-SelectedCommentOrText.ps1
. $psScriptRoot\Show-TableBrowser.ps1
. $psScriptRoot\Get-DbObjectList.ps1
. $psScriptRoot\Show-DbObjectList.ps1
. $psScriptRoot\Show-ConnectionManager.ps1
. $psScriptRoot\Get-TabObjectList.ps1
. $psScriptRoot\Invoke-Coalesce.ps1
. $psScriptRoot\Get-TableAlias.ps1
. $psScriptRoot\TabExpansion.ps1
. $psScriptRoot\ConvertTo-StringData.ps1
. $psScriptRoot\Library-UserStore.ps1
. $psScriptRoot\ConvertFrom-Xml.ps1
. $psScriptRoot\Library-StringCrypto.ps1

Set-Alias Expand-String $psScriptRoot\Expand-String.ps1

$env:SQLPsx_QueryOutputformat = "auto"              

$Script:conn=new-object System.Data.SqlClient.SQLConnection

#Load saved options into hashtable
Initialize-UserStore  -fileName "options.txt" -dirName "SQLIse" -defaultFile "$psScriptRoot\defaultopts.ps1"
$options = Read-UserStore -fileName "options.txt" -dirName "SQLIse" -typeName "Hashtable"

$Script:DatabaseList = New-Object System.Collections.ArrayList

$bitmap = new-object System.Windows.Media.Imaging.BitmapImage
$bitmap.BeginInit()
$bitmap.UriSource = "$psScriptRoot\SQLPSX.PNG"
$bitmap.EndInit()

#######################
function Invoke-ParseSql
{
    param()
    if (-not $psise.CurrentFile)
    {
        Write-Error 'You must have an open script file'
        return
    }
    
    $selectedRunspace = $psise.CurrentFile
    $selectedEditor=$selectedRunspace.Editor

    if (-not $selectedEditor.SelectedText)
    {
        $inputScript = $selectedEditor.Text
    }
    else
    {
        $inputScript = $selectedEditor.SelectedText
    }
    Test-SqlScript -InputScript $inputScript -QuotedIdentifierOff:$($options.QuotedIdentifierOff) -SqlVersion:$($options.SqlVersion)
 
} #Invoke-ParseSql

#######################
function Format-Sql
{
    param()
    if (-not $psise.CurrentFile)
    {
        Write-Error 'You must have an open script file'
        return
    }
    
    $selectedRunspace = $psise.CurrentFile
    $selectedEditor=$selectedRunspace.Editor

    if (-not $selectedEditor.SelectedText)
    {
        $inputScript = $selectedEditor.Text
        $outputScript = Out-SqlScript -InputScript $inputScript -QuotedIdentifierOff:$($options.QuotedIdentifierOff) -SqlVersion:$($options.SqlVersion) -AlignClauseBodies:$($options.AlignClauseBodies) `
        -AlignColumnDefinitionFields:$($options.AlignColumnDefinitionFields) -AlignSetClauseItem:$($options.AlignSetClauseItem) -AsKeywordOnOwnLine:$($options.AsKeywordOnOwnLine) `
        -IncludeSemicolons:$($options.IncludeSemicolons) -IndentationSize:$($options.IndentationSize) -IndentSetClause:$($options.IndentSetClause) -IndentViewBody:$($options.IndentViewBody) `
        -KeywordCasing:$($options.KeywordCasing) -MultilineInsertSourcesList:$($options.MultilineInsertSourcesList) -MultilineInsertTargetsList:$($options.MultilineInsertTargetsList) `
        -MultilineSelectElementsList:$($options.MultilineSelectElementsList) -MultilineSetClauseItems:$($options.MultilineSetClauseItems) -MultilineViewColumnsList:$($options.MultilineViewColumnsList) `
        -MultilineWherePredicatesList:$($options.MultilineWherePredicatesList) -NewLineBeforeCloseParenthesisInMultilineList:$($options.NewLineBeforeCloseParenthesisInMultilineList) `
        -NewLineBeforeFromClause:$($options.NewLineBeforeFromClause) -NewLineBeforeGroupByClause:$($options.NewLineBeforeGroupByClause) -NewLineBeforeHavingClause:$($options.NewLineBeforeHavingClause) `
        -NewLineBeforeJoinClause:$($options.NewLineBeforeJoinClause) -NewLineBeforeOpenParenthesisInMultilineList:$($options.NewLineBeforeOpenParenthesisInMultilineList) `
        -NewLineBeforeOrderByClause:$($options.NewLineBeforeOrderByClause) -NewLineBeforeOutputClause:$($options.NewLineBeforeOutputClause) -NewLineBeforeWhereClause:$($options.NewLineBeforeWhereClause)

        if ($outputScript)
        { $selectedEditor.Text = $outputScript }
    }
    else
    {
        $inputScript = $selectedEditor.SelectedText
        $outputScript = Out-SqlScript -InputScript $inputScript -QuotedIdentifierOff:$($options.QuotedIdentifierOff) -SqlVersion:$($options.SqlVersion) -AlignClauseBodies:$($options.AlignClauseBodies) `
        -AlignColumnDefinitionFields:$($options.AlignColumnDefinitionFields) -AlignSetClauseItem:$($options.AlignSetClauseItem) -AsKeywordOnOwnLine:$($options.AsKeywordOnOwnLine) `
        -IncludeSemicolons:$($options.IncludeSemicolons) -IndentationSize:$($options.IndentationSize) -IndentSetClause:$($options.IndentSetClause) -IndentViewBody:$($options.IndentViewBody) `
        -KeywordCasing:$($options.KeywordCasing) -MultilineInsertSourcesList:$($options.MultilineInsertSourcesList) -MultilineInsertTargetsList:$($options.MultilineInsertTargetsList) `
        -MultilineSelectElementsList:$($options.MultilineSelectElementsList) -MultilineSetClauseItems:$($options.MultilineSetClauseItems) -MultilineViewColumnsList:$($options.MultilineViewColumnsList) `
        -MultilineWherePredicatesList:$($options.MultilineWherePredicatesList) -NewLineBeforeCloseParenthesisInMultilineList:$($options.NewLineBeforeCloseParenthesisInMultilineList) `
        -NewLineBeforeFromClause:$($options.NewLineBeforeFromClause) -NewLineBeforeGroupByClause:$($options.NewLineBeforeGroupByClause) -NewLineBeforeHavingClause:$($options.NewLineBeforeHavingClause) `
        -NewLineBeforeJoinClause:$($options.NewLineBeforeJoinClause) -NewLineBeforeOpenParenthesisInMultilineList:$($options.NewLineBeforeOpenParenthesisInMultilineList) `
        -NewLineBeforeOrderByClause:$($options.NewLineBeforeOrderByClause) -NewLineBeforeOutputClause:$($options.NewLineBeforeOutputClause) -NewLineBeforeWhereClause:$($options.NewLineBeforeWhereClause)

        if ($outputScript)
        { $selectedEditor.InsertText($outputScript) }
    }
 
} #Format-Sql

#######################
function Connect-Sql
{
    param(
        $database,
        $server,
        $user,
        $password
    )
    if ($database)
    {
        if (!$server) {  $server = 'localhost'  }
    }
    else
    {
        $script:connInfo = Get-ConnectionInfo $bitmap
        if ($connInfo)
        { 
            $database = $connInfo.Database
            $server = $connInfo.Server
            $user = $connInfo.UserName
            $password = $connInfo.Password
        }
    }
    # Write-host "database $database"
    # Write-host "server $server"
     
    if ($database)
    { 
        $Script:conn = new-connection -server $server -database $database -user $user -password $password
        $handler    = [System.Data.SqlClient.SqlInfoMessageEventHandler] {
            if ($global:dm -eq 'inline')
            {
                #Write-Host '>>> inline mode <<<'
                $psise.CurrentFile.Editor.InsertText("$_`r`n")
            }
            elseif ($global:dm -eq 'File')
            {
                if ($global:filePath  -ne $null)
                {
                    $_.Message | Out-File -FilePath $global:filePath -append
                }
                else
                {
                    Write-Host "file not yet opened"
                }
            }
            else
            {
                Write-Host $_
                #Write-Host $error[0].InnerException
            }
        }
        $Script:conn.add_InfoMessage($handler)
        if ($Script:conn.State -eq 'Open')
        { 
            invoke-query -sql:'sp_databases' -connection:$Script:conn | foreach { [void]$Script:DatabaseList.Add($_.DATABASE_NAME) } 
            Get-TabObjectList
        }
    }
    
} #Connect-Sql

#######################
function Disconnect-Sql
{
    $Script:conn.Close()
    $Script:DatabaseList.Clear()
} #Disconnect-Sql

#######################
function USE-ReopenSql
{
    if (!! $Script:conn.ConnectionString )
    {
        $Script:conn.Open()
        if ($Script:conn.State -eq 'Open')
        { 
            invoke-query -sql:'sp_databases' -connection:$Script:conn | foreach { [void]$Script:DatabaseList.Add($_.DATABASE_NAME) } 
            Get-TabObjectList
        }
    }
} #USE-ReopenSql

#######################
function Prompt
{
    param()
    $basePrompt = $(if (test-path variable:/PSDebugContext) { '[DBG]: ' } else { '' }) + 'PS ' + $(Get-Location)
    $sqlPrompt = ' #[SQL]' + $(if ($conn.State -eq 'Open') { $($conn.DataSource) + '.' + $($conn.Database) } else { '---'})
    $oraclePrompt = ' #[Oracle]' + $(if ($oracle_conn.State -eq 'Open') { $($oracle_conn.DataSource) } else { '---'})
    $basePrompt + $sqlPrompt + $oraclePrompt +$(if ($nestedpromptlevel -ge 1) { ' >>' }) + ' > '

} #Prompt

#######################
function Get-FileName
{
    param($ext,$extDescription)
    $sfd = New-SaveFileDialog -AddExtension -DefaultExt "$ext" -Filter "$extDescription (.$ext)|*.$ext|All files(*.*)|*.*" -Title "Save Results" -InitialDirectory $pwd.path
    [void]$sfd.ShowDialog()
    return $sfd.FileName

} #Get-FileName

#######################
function Invoke-ExecuteSql
{
    param(
        $inputScript,
        $displaymode = $null,
        $OutputVariable = $null
        )
    
    if ($inputScript -eq $null)
    {
        if (-not $psise.CurrentFile)
        {
            Write-Error 'You must have an open script file'
            return
        }
        
        $editor = $psise.CurrentFile.Editor

        if ($editor.SelectedText)
        {
            $inputScript = $editor.SelectedText
            $hasSelection = $True
        }
        else
        {
            $inputScript = $editor.Text 
            $hasSelection = $False
        }
    }

    if ($conn.State -eq 'Closed')  {  Connect-Sql  }
    
    if ( $displaymode -eq $null)
    {
        if ($env:SQLPsx_QueryOutputformat)
        {
            $displaymode = $env:SQLPsx_QueryOutputformat
        }
        else
        {
            $displaymode = 'inline'
        }
    }
    $global:dm = $displaymode
    $displaymode_x = $displaymode
    if (('isetab', 'inline') -contains $displaymode_x ) { $displaymode_x = 'wide' }
    
    # determine insertposition for inline mode
    if ( $displaymode -eq 'inline')
    {
        if ($hasselection)
        {
            $editor.InsertText('')
            $editor.InsertText($inputScript)
            $EndLine =  $editor.CaretLine
            $EndColumn = $editor.CaretColumn
        }
        else
        {
            $EndLine =  $editor.LineCount 
            $EndColumn = $editor.GetLineLength($EndLine) + 1
        }
        #"EndLine   $EndLine"
        #"EndColumn $EndColumn"
        $LineCount  = $editor.LineCount
        if (  $EndLine -lt  $LineCount)
        {
            if ($EndColumn -eq 1)
            {        
                $editor.SetCaretPosition($EndLine, 1)
            }
            else
            {
                $editor.SetCaretPosition(($EndLine + 1), 1)
            }
        }
        else
        {
            if ($EndColumn -ne 1)
            {
                $EndColumn =  $editor.GetLineLength($LineCount) + 1
                $editor.SetCaretPosition($EndLine, $EndColumn)
                $editor.InsertText("`r`n")
            }
            else
            {
                $editor.SetCaretPosition($EndLine, $EndColumn)
            }
        }
        
    }
        
    # fix CR not followed by NL and NL not preceded by CR
    $inputScript = $inputScript  -replace  "`r(?!`n)","`r`n" -replace "`(?<!`r)`n", "`r`n"
     
    $blocks = $inputScript -split  "\r?\n[ \t]*go[ \t]*(?=\r?\n)"
    $blocknr = 0
    $linenr = 1
    $sql_errors = @()
    $global:filepath = $null
    if ($displaymode -eq 'file')
    {
        $global:filePath = Get-FileName 'txt' 'Text'
        '' |  Out-File -FilePath $global:filePath -Force
    }
    
    foreach ($inputScript in $blocks)
    { 
        $linecount = ($inputScript -split [System.Environment]::NewLine).count
        #$linecount = ($inputScript -split "\r?\n").count
        $begline = $linenr
        $endline = $linenr + $linecount -1 
        if ($blocknr++ -ge 1)
        {        
            $begline = $linenr + 1
#             #"----------------------------"
#             #$inputScript
            if ($global:filepath -eq $null)
            {
                Write-Host "---------- Blocknr: $blocknr ---  Line: $begline - $endline ---------- $linecount"
            }
        }
        $linenr += $linecount #+ 1

    if ($options.PoshMode)
    {
        Invoke-PoshCode $inputScript
        $inputScript = Remove-PoshCode $inputScript
        $inputScript = Expand-String $inputScript
    }

    if ($inputScript -and $inputScript -ne "")
    {
        try {
                $res = invoke-query -sql $inputScript -connection $Script:conn -asResult 'DataSet'
         }
         catch {
            $e = $_
            $error_msg = "Blocknr $blocknr $begline $endline $e"
            $sql_errors += $error_msg
            Write-Host $e -ForegroundColor Red -BackgroundColor White
            $res = $null
         }   
         
        switch($displaymode_x)
        {
            'grid'  {   $res.tables | %{ $_ | Out-GridView -Title $psise.CurrentFile.DisplayName}   }
            'table' {   $res.tables | %{ $_ | ft -auto }                                            }
            'list'  {   $res.tables | %{ $_ | fl }                                                  }
            'auto'  {    
                        $res.tables | %{
                             if ($_.Rows.Count -eq 1 )
                             {  #"this result has one row "
                                if ($_.Columns.count -eq 1)
                                {   # "result: 1 row / 1 column"
                                    $columnname = $_.Columns[0].ColumnName
                                    $columnname
                                    '-' * ($columnname.length)
                                    $_.Rows[0].item(0)
                                    ''
                                }
                                else
                                {   #"result: 1 row / multiple columns"
                                    $_ | fl
                                }
                             }
                             else
                             {  #"-- other"
                                $_ | Out-Host
                             }
                           }  
                   }
            'file' {
                        if ($filePath)
                        {
                            $res.tables | %{ $_ | ft -auto | Out-File -FilePath $filePath -append }
                        }
                      }
            'csv' {
                      $filePath = Get-FileName 'csv' 'CSV'
                      if ($filePath)
                      # what todo with multi resultset 
                      {$res | Export-Csv -Path $filepath -NoTypeInformation -Force
                       Write-Host ""}
                     }
            'variable' {
                        if (! $OutputVariable)
                        {
                            $OutputVariable = Read-Host 'Variable (no "$" needed)'
                        }
                    	if ($res.tables.count -eq 1){
                    		$retval= $res.Tables[0]
                    	}
                        else
                        {
                            $retval = $res
                        }
                        
                        Set-Variable -Name $OutputVariable -Value $retval -Scope Global
                    }
            'wide'   {  # combined code for inline and isetab
                            $text = ''                        
                            $res.tables | %{
                                #$_.gettype()
                                $col_cnt = $_.columns.count
                                $row_cnt = $_.rows.count
                                $columns = ''
                                $col1name = $_.Columns[0].ColumnName
                                foreach ($i in 0.. ($col_cnt - 1))
                                {
                                    if ($columns) { $columns +=  ', '+ $_.Columns[$i].ColumnName }
                                    else { $columns = $_.Columns[$i].ColumnName}
                                }
                                if ($row_cnt -gt 1)
                                {   # "result has multiple rows -- use ft"
                                    $text += ($_ | Select * -exclude RowError,RowState,Table,ItemArray,HasErrors | ft -Property * -auto | Out-string -width 10000 -stream ) -join "`r`n"
                                }
                                else
                                {
                                    $_ | %{
                                        if ( $row_cnt -eq 1 )
                                        {   
                                            if ($col_cnt -eq 1)
                                            {   # "result: 1 row / 1 column -- add column header"
                                                $text += "`r`n" + $col1name
                                                $text += "`r`n" + ('-' * ($col1name.length))
                                                $text += "`r`n" + $_.item(0)
                                            }
                                            else
                                            {   # "result: 1 row / multiple columns -- use fl"
                                                $text += ($_ | fl| Out-string -width 10000)
                                            }
                                        }
                                    }
                                }
                        }    
                        # ---------------------------------------------------------------------------------
                        
                        if (  $displaymode -eq 'inline')
                        {
                            $timestamp = "{0:d} {1:T}" -f (get-date), (get-date)
                            $info = $($Script:conn.DataSource) + '.' + $($Script:conn.Database) + '  ' + $timestamp + "`r`n"

                            $editor.InsertText( $info) 

                            $editor.InsertText($text)
                        }
                        else
                        { # isetab
                             $count = $psise.CurrentPowerShellTab.Files.count
                             $psIse.CurrentPowerShellTab.Files.Add()
                             $Newfile = $psIse.CurrentPowerShellTab.Files[$count]
                             $Newfile.Editor.Text = $text
                        }
                    }        
        }
    }
#         if ($blocknr++ -ge 0)
#         {        
#             #"----------------------------"
#             #$inputScript
#             Write-Host "---------- Blocknr: $blocknr ---  Line: $begline - $endline ---------- $linecount"
#         }
    }
    $sql_errors
        
} #Invoke-ExecuteSql

#######################
function Write-Options
{
    param()
    Write-UserStore -fileName "options.txt" -dirName "SQLIse" -object $options

} #Write-Options

#######################
function Switch-Database
{
    param()

    $Action = {
        $this.Parent.Tag = $this.SelectedItem
        $window.Close() }
                
    $database = New-ComboBox -Name Database -Width 200 -Height 20 {$DatabaseList} -SelectedItem $conn.Database -On_SelectionChanged $Action -Show

    if ($database)
    { 
        $Script:conn.ChangeDatabase($database) 
        $connInfo.Database = $database
        Get-TabObjectList
    } 

} #Switch-Database

#######################
function Edit-Uppercase
{
    param()
    if (-not $psise.CurrentFile)
    {
        Write-Error 'You must have an open script file'
        return
    }
    
    $selectedRunspace = $psise.CurrentFile
    $selectedEditor=$selectedRunspace.Editor

    if (-not $selectedEditor.SelectedText)
    {
        $output = $($selectedEditor.Text).ToUpper()
        if ($output)
        { $selectedEditor.Text = $output }

    }
    else
    {
        $output = $($selectedEditor.SelectedText).ToUpper()
        if ($output)
        { $selectedEditor.InsertText($output) }

    }

} #Edit-Uppercase

#######################
function Edit-Lowercase
{
    param()
    if (-not $psise.CurrentFile)
    {
        Write-Error 'You must have an open script file'
        return
    }
    
    $selectedRunspace = $psise.CurrentFile
    $selectedEditor=$selectedRunspace.Editor

    if (-not $selectedEditor.SelectedText)
    {
        $output = $($selectedEditor.Text).ToLower()
        if ($output)
        { $selectedEditor.Text = $output }

    }
    else
    {
        $output = $($selectedEditor.SelectedText).ToLower()
        if ($output)
        { $selectedEditor.InsertText($output) }

    }

} #Edit-Lowercase

#######################
function Set-PoshVariable
{
    param($name,$value)

    Set-Variable -Name $name -Value $value -Scope Global

} #Set-PoshVariable

#######################
function Invoke-PoshCode
{
    param($text)

    foreach ( $line in $text -split [System.Environment]::NewLine )
    {
        if ( $line.length -gt 0) {
            if ( $line -match "^\s*!!" ) {
                $line = $line -replace "^\s*!!", ""
                invoke-expression $line
            }
        }
    }

} #Invoke-PoshCode

#######################
function Remove-PoshCode
{
    param($text)

    $returnedText = ""
    foreach ( $line in $text -split [System.Environment]::NewLine )
    {
        if ( $line.length -gt 0) {
            if ( $line -notmatch "^\s*!!" ) {
                $returnText += "{0}{1}" -f $line,[System.Environment]::NewLine
            }
        }
    }
    $returnText

} #Remove-PoshCode

#######################
Add-IseMenu -name SQLIse @{
    "Parse" = {Invoke-ParseSql} | Add-Member NoteProperty ShortcutKey "CTRL+SHIFT+F5" -PassThru
    "Format" = {Format-Sql} | Add-Member NoteProperty ShortcutKey "CTRL+ 4" -PassThru
    "Connection" =@{
                    "Connect..." = {Connect-Sql}
                    "Reconnect"  = {USE-ReopenSql}
                    "Disconnect" = {Disconnect-Sql}
    }
    "Execute" = {Invoke-ExecuteSql} | Add-Member NoteProperty ShortcutKey "CTRL+ALT+F5" -PassThru
    "Change Database..." = {Switch-Database}
    "Options..." = {Set-Options; Write-Options}
    "Edit" =@{
                    "Make Uppercase         CTRL+SHIFT+U" = {Edit-Uppercase}
                    "Make Lowercase         CTRL+U" = {Edit-Lowercase}
                    "Toggle Comments" = {Switch-SelectedCommentOrText} | Add-Member NoteProperty ShortcutKey "CTRL+ALT+K" -PassThru
            }
    "Table Browser" = {Show-TableBrowser -resource @{conn = $conn} | Out-Null}
    "Object Browser" = {Show-DbObjectList -ds (Get-DbObjectList)}
    "Manage Connections" = { Show-ConnectionManager }
	"Tab Expansion" = @{
                        "Refresh Alias Cache" = {Get-TableAlias} | Add-Member NoteProperty ShortcutKey "CTRL+ALT+T" -PassThru
                        "Refresh Object Cache" = {Get-TabObjectList} | Add-Member NoteProperty ShortcutKey "CTRL+ALT+R" -PassThru
                       }
     "Output Format" = {Set-Outputformat}
} # -module SQLIse

New-Alias -name setvar -value Set-PoshVariable -Description "SqlIse Alias"
Export-ModuleMember -function * -Variable options, bitmap, conn, DatabaseList, SavedConnections, dsDbObjects -alias setvar
