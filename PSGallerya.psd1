@{
    ExcludeRules = @('PSAvoidUsingWriteHost',
                     'PSAvoidUsingConvertToSecureStringWithPlainText',
                     'PSAvoidUsingComputerNameHardcoded',
                     'PSAvoidUsingPlainTextForPassword',
                     'PSAvoidUsingUserNameAndPassWordParams')

    Rules = @{
        PSPlaceOpenBrace  = @{
            Enable                  = $true
            OnSameLine              = $false
            NewLineAfter            = $true
            IgnoreOneLineBlock      = $true
        }

        PSPlaceCloseBrace = @{
            Enable                  = $true
            NoEmptyLineBefore       = $false
            IgnoreOneLineBlock      = $true
            NewLineAfter            = $true
        }

        PSProvideCommentHelp = @{
            Enable                  = $true
            ExportedOnly            = $false
            BlockComment            = $true
            VSCodeSnippetCorrection = $false
            Placement               = "before"
        }
    }
}