# ==============================================================================================
# Script to document MDT solution to Word document
#
# Todo: 
# - Document the Server
# - Document the task sequence steps
# - Word formatting
# - Table of contents word
# - Test documentation steps
# 
# _-_-_-_-_-_-_-_-_-_-_-_-_
# Author: Oddvar Håland Moe 
# www.MSITPROS.com
# _-_-_-_-_-_-_-_-_-_-_-_-_
#
# Version history: 
# 0.5 - Added last documentation steps, media, linked deployment shares, added write-host steps
# 0.6 - Input box for filename
#
# =============================================================================================

Add-PSSnapIn Microsoft.BDD.PSSnapIn -ErrorAction SilentlyContinue 
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')  
$Path = [Microsoft.VisualBasic.Interaction]::InputBox("Enter path to output file", "Filename", "c:\windows\temp\mdtdoc.doc")  
  
  if ($Path -eq "")
  {
  # Cancel was triggered, no value for required variable
  exit
  }

write-host "Getting Deployment shares"
$DeploymentShare = Get-MDTPersistentDrive | format-list | out-string

Write-host "Creating Word Document"

[ref]$SaveFormat = "microsoft.office.interop.word.WdSaveFormat" -as [type]
$word = New-Object -ComObject word.application
$word.visible = $true
# $Normal = ($word.selection.style = -1)
# $Heading1 = ($word.selection.style = -2)
# $Heading2 = ($word.selection.style = -3)
# $Heading3 = ($word.selection.style = -4)

$doc = $word.documents.add()

# I HATE SPACE BETWEEN LINES IN WORD
$word.selection.style.NoSpaceBetweenParagraphsOfSameStyle = $true

# WORD FUNCTIONS - I KNOW.... BAD PROGRAMMING
function Write-H1
{param ([string]$Text) 
 $word.selection.style = -2
 $word.selection.typeText($Text)
 $word.selection.TypeParagraph()
}

function Write-H2
{param ([string]$Text) 
 $word.selection.style = -3
 $word.selection.typeText($Text)
 $word.selection.TypeParagraph()
}

function Write-H3
{param ([string]$Text) 
 $word.selection.style = -4
 $word.selection.typeText($Text)
 $word.selection.TypeParagraph()
}

function Write-H4
{param ([string]$Text) 
 $word.selection.style = -5
 $word.selection.typeText($Text)
 $word.selection.TypeParagraph()
}

function Paragraph
{
 $word.selection.TypeParagraph()
}

function Write-Normal
{param ([string]$Text) 
 $word.selection.style = -1
 $word.selection.typeText($Text)
 $word.selection.TypeParagraph()
}

Write-host "Writing documentation to Word document"

#HEADING
Write-H1 -Text "DeploymentShares"

#NORMAL
Write-Normal -Text $DeploymentShare

#Create PSDDRIVE FOR DOCUMENTATION
get-mdtpersistentdrive | foreach{ New-PSDrive -Name $_.name -PSProvider MDTProvider -Root $_.path}

#Document detailed information on deploymentshare
Get-PSDrive -PSProvider MDTProvider | foreach{$psdrivevar = $_.name+':'
Paragraph
Write-H2 -Text $_.name

$value = get-itemproperty $psdrivevar | out-string
Write-Normal -Text $Value
}


#Document inside deploymentshare -assuming folder name is applications
Get-PSDrive -PSProvider MDTProvider | foreach{$psdrivevar = $_.name+':'

#Write to Word
Paragraph
write-H1 -text $_.name

Paragraph
Write-H2 -Text "Applications"


#Document Applications
cd $psdrivevar\Applications
foreach($item in get-childitem -recurse -force)
{if ($item.nodetype -eq "ApplicationFolder")
    {
    Paragraph
    write-h3 -Text ($item.nodetype+': '+$item.name)
    }
    elseif ($item.nodetype -eq "Application")
    {
    write-H4 -Text $item.name
    Write-Normal -Text ("Application name:   "+$item.name)
    Write-Normal -Text ("Application Shortname:   "+$item.ShortName)
    Write-Normal -Text ("Display Name:   "+$item.DisplayName)
    Write-Normal -Text ("Install Command:   "+$item.CommandLine)
    Write-Normal -Text ("Source files:   "+$item.Source)
    Write-Normal -Text ("Working Directory:   "+$item.WorkingDirectory)
    Write-Normal -Text ("GUID:   "+$item.GUID)
    Write-Normal -Text ("Enabled:   "+$item.enable)
    Write-Normal -Text ("Hidden:   "+$item.hide)
    Write-Normal -Text ("Requires boot:   "+$item.reboot)
    Write-Normal -Text ("Uninstall command:   "+$item.Uninstallkey)
    Write-Normal -Text ("Version:   "+$item.Version)
    Write-Normal -Text ("Dependency:   "+$item.Dependency)
    Write-Normal -Text ("Supported platforms:   "+$item.SupportedPlatform)
    Write-Normal -Text ("Language:   "+$item.Language)
    Write-Normal -Text ("Publisher:   "+$item.Publisher)
    Write-Normal -Text ("Comments:   "+$item.Comments)
    Write-Normal -Text ("Created by:   "+$item.CreatedBy)
    Write-Normal -Text ("Created:   "+$item.Createdtime)
    Write-Normal -Text ("Last Modified by:   "+$item.LastModifiedBy)
    Write-Normal -Text ("Last Modified:   "+$item.LastModifiedTime)
    }
}

#Document Operating systems
Paragraph
Write-H2 -Text "Operating systems"

cd $psdrivevar"\Operating systems"
foreach($item in get-childitem -recurse -force)
{if ($item.nodetype -eq "OperatingSystemFolder")
    {
    Paragraph
    write-h3 -Text ($item.nodetype+': '+$item.name)
    }
    elseif ($item.nodetype -eq "OperatingSystem")
    {
    write-H4 -Text $item.Imagename
    Write-Normal -Text ("Name:   "+$item.name)
    Write-Normal -Text ("Image Name:   "+$item.Imagename)
    Write-Normal -Text ("Description:   "+$item.Description)
    Write-Normal -Text ("Platform:   "+$item.Platform)
    Write-Normal -Text ("Build:   "+$item.Build)
    Write-Normal -Text ("OSType:   "+$item.OSType)
    Write-Normal -Text ("Source:   "+$item.Source)
    Write-Normal -Text ("Includes Setup:   "+$item.IncludesSetup)
    Write-Normal -Text ("ImageFile:   "+$item.ImageFile)
    Write-Normal -Text ("ImageIndex:   "+$item.ImageIndex)
    Write-Normal -Text ("HAL:   "+$item.HAL)
    Write-Normal -Text ("Size:   "+$item.Size)
    Write-Normal -Text ("Enabled:   "+$item.enable)
    Write-Normal -Text ("Hidden:   "+$item.Hide)
    Write-Normal -Text ("guid:   "+$item.guid)
    Write-Normal -Text ("Flags:   "+$item.Flags)
    Write-Normal -Text ("WDSServer:   "+$item.WDSServer)
    Write-Normal -Text ("Image Group:   "+$item.ImageGroup)
    Write-Normal -Text ("SMSImage:   "+$item.SMSImage)
    Write-Normal -Text ("Comments:   "+$item.Comments)
    Write-Normal -Text ("Created:   "+$item.CreatedTime)
    Write-Normal -Text ("CreatedBy:   "+$item.CreatedBy)
    Write-Normal -Text ("Last Modified:   "+$item.LastModifiedTime)
    Write-Normal -Text ("Last Modified By:   "+$item.LastModifiedBy)
    Write-Normal -Text ("Language:   "+$item.Language)
    Write-Normal -Text ("AllowedClipboardFormats:   "+$item.AllowedClipboardFormats)
    Write-Normal -Text ("IsAdvanced:   "+$item.IsAdvanced)
    }
    }
    
    
#Document Drivers
Paragraph
Write-H2 -Text "Drivers"

cd $psdrivevar"\Out-Of-Box Drivers"
foreach($item in get-childitem -recurse -force)
{if ($item.nodetype -eq "DriverFolder")
    {
    Paragraph
    write-h3 -Text ($item.nodetype+': '+$item.name)
    }
    elseif ($item.nodetype -eq "Driver")
    {
    write-H4 -Text $item.Name
    Write-Normal -Text ("Name:   "+$item.name)
    Write-Normal -Text ("Class:   "+$item.Class)
    Write-Normal -Text ("WHQLSigned:   "+$item.WHQLSigned)
    Write-Normal -Text ("Enabled:   "+$item.Enable)
    Write-Normal -Text ("Version:   "+$item.Version)
    Write-Normal -Text ("Driver Date:   "+$item.Date)
    Write-Normal -Text ("GUID:   "+$item.GUID)
    Write-Normal -Text ("Manufacturer:   "+$item.Manufacturer)
    Write-Normal -Text ("PNPId:   "+$item.PNPId)
    }
    }    
    

#Document Packages - Not tested, not done!
Paragraph
Write-H2 -Text "Packages"

cd $psdrivevar"\Packages"
foreach($item in get-childitem -recurse -force)
{if ($item.nodetype -eq "PackageFolder")
    {
    Paragraph
    write-h3 -Text ($item.nodetype+': '+$item.name)
    }
    elseif ($item.nodetype -eq "Package")
    {
    write-H4 -Text $item.Name
    Write-Normal -Text ("Name:   "+$item.name)
    Write-Normal -Text ("Enabled:   "+$item.Enable)
    Write-Normal -Text ("GUID:   "+$item.GUID)
    }
    }    

#Document Task Sequences
Paragraph
Write-H2 -Text "Task Sequences"

cd $psdrivevar"\Task Sequences"
foreach($item in get-childitem -recurse -force)
{if ($item.nodetype -eq "TaskSequenceFolder")
    {
    Paragraph
    write-h3 -Text ($item.nodetype+': '+$item.name)
    }
    elseif ($item.nodetype -eq "TaskSequence")
    {
    write-H4 -Text $item.Name
    Write-Normal -Text ("Name:   "+$item.name)
    Write-Normal -Text ("Display Name:   "+$item.DisplayName)
    Write-Normal -Text ("Task sequence ID:   "+$item.ID)
    Write-Normal -Text ("Version:   "+$item.Version)
    Write-Normal -Text ("Enabled:   "+$item.Enable)
    Write-Normal -Text ("GUID:   "+$item.GUID)
    Write-Normal -Text ("Task Sequence Template:   "+$item.TaskSequenceTemplate)
    Write-Normal -Text ("Hidden:   "+$item.Hide)
    Write-Normal -Text ("Comments:   "+$item.Comments)
    Write-Normal -Text ("Created:   "+$item.CreatedTime)
    Write-Normal -Text ("CreatedBy:   "+$item.CreatedBy)
    Write-Normal -Text ("Last Modified:   "+$item.LastModifiedTime)
    Write-Normal -Text ("Last Modified By:   "+$item.LastModifiedBy)
    }
    }    
    
#Document Selection Profiles - Not tested, not done!
Paragraph
Write-H2 -Text "Selection Profiles"

cd $psdrivevar"\Selection Profiles"
foreach($item in get-childitem -recurse -force)
{if ($item.nodetype -eq "SelectionProfileFolder")
    {
    Paragraph
    write-h3 -Text ($item.nodetype+': '+$item.name)
    }
    elseif ($item.nodetype -eq "SelectionProfile")
    {
    write-H4 -Text $item.Name
    Write-Normal -Text ("Name:   "+$item.name)
    Write-Normal -Text ("GUID:   "+$item.GUID)
    Write-Normal -Text ("Enable:   "+$item.Enable)
    Write-Normal -Text ("Definition:   "+$item.definition)
    Write-Normal -Text ("Hidden:   "+$item.Hide)
    Write-Normal -Text ("Comments:   "+$item.Comments)
    Write-Normal -Text ("Created:   "+$item.CreatedTime)
    Write-Normal -Text ("CreatedBy:   "+$item.CreatedBy)
    Write-Normal -Text ("Last Modified:   "+$item.LastModifiedTime)
    Write-Normal -Text ("Last Modified By:   "+$item.LastModifiedBy)
    
    }
    }    

#Document Linked Deployment Shares - NOT TESTET - NOT DONE!
Paragraph
Write-H2 -Text "Linked Deployment Shares"

cd $psdrivevar"\Linked Deployment Shares"
foreach($item in get-childitem -recurse -force)
{if ($item.nodetype -eq "LinkedDeploymentShareFolder")
    {
    Paragraph
    write-h3 -Text ($item.nodetype+': '+$item.name)
    }
    elseif ($item.nodetype -eq "LinkedDeploymentShare")
    {
    write-H4 -Text $item.Name
    Write-Normal -Text ("Name:   "+$item.name)
    Write-Normal -Text ("GUID:   "+$item.GUID)
    }
    }    

#Document Media - NOT TESTET - NOT DONE!
Paragraph
Write-H2 -Text "Media"

cd $psdrivevar"\Media"
foreach($item in get-childitem -recurse -force)
{if ($item.nodetype -eq "MediaFolder")
    {
    Paragraph
    write-h3 -Text ($item.nodetype+': '+$item.name)
    }
    elseif ($item.nodetype -eq "Media")
    {
    write-H4 -Text $item.Name
    Write-Normal -Text ("Name:   "+$item.name)
    Write-Normal -Text ("GUID:   "+$item.GUID)
    }
    }    


}

Write-host "Saving Word document"
$doc.saveas([ref] $path, [ref]$saveFormat::wdFormatDocument)

Write-host "Done"
# $word.quit()