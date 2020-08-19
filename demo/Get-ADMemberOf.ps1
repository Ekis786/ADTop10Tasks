#requires -version 5.1
#requires -module ActiveDirectory

Function Get-ADMemberOf {
    [cmdletBinding()]

    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            HelpMessage = "Enter a user's SAMAccountname or distinguishedname",
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullorEmpty()]
        [string]$Identity
    )

    Begin {
        Write-Verbose "Starting $($myinvocation.mycommand)"
        #define a function used for getting all the nested group information
        Function Get-GroupMemberOf {
            Param([string]$identity)

            #get each group and see what it belongs to
            $group = Get-ADGroup -Identity $Identity -Properties MemberOf
            #write the group to the pipeline
            $group

            #if there is MemberOf property, recursively call this function
            if ($group.MemberOf) {
                $group | Select-Object -expandProperty MemberOf |
                ForEach-Object {
                    Get-GroupMemberOf -identity $_
                }
            }
        } #end function
    } #close Begin

    Process {
        Write-Verbose "Getting all groups for $identity"
        Get-ADUser -identity $identity -Properties memberof |
        Select-Object -ExpandProperty MemberOf |
        ForEach-Object {
            Get-GroupMemberOf -identity $_
        } #foreach
    } #close process

    End {
        Write-Verbose "Ending $($myinvocation.mycommand)"
    }
} #end function

