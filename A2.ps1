[CmdletBinding()]
param (
    [Parameter(Mandatory=$true,HelpMessage="Адрес системы")]
    [ValidateNotNullOrEmpty()]
    [string]$baseUri = $(throw "Аргумент 'baseUri' обязателен")
)
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

######################################################################
#                                                                    #
#             components/services/login.asmx                         #
#                                                                    #
######################################################################

function A2Authenticate ( 
    [Parameter(Position=1, HelpMessage="Логин пользователя системы")]
    [ValidateNotNullOrEmpty()]
    [string]$Login = $(throw "Аргумент 'Login' обязателен"),

    [Parameter(Position=2, HelpMessage="Пароль пользователя системы")]
    [ValidateNotNullOrEmpty()]
    [string]$Password = $(throw "Аргумент 'Password' обязателен")
) {    
    $LoginProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/login.asmx?WSDL"
	
    $session = $LoginProxy.Authenticate($Login, $Password)

    if ($session.ErrorMessage -ne '') {
        return $session.ErrorMessage 
    } else {
        return $session.ASPNETSessionId
    }
}

function AuthenticationCheck(
	[Parameter(Position=1)]
	[string]$ASPNetSessionID = $null
	,
	[Parameter(Position=2, Mandatory=$true)]
	[string]$login
	,
	[Parameter(Position=3, Mandatory=$true)]
	[string]$password
) {
	if ($ASPNetSessionID -eq $null -or $ASPNetSessionID -eq "") {
		#Write-Host "Новая авторизация"
		return A2Authenticate -Login $login -Password $password
	}

	try {
		if ((A2GetGroups -ASPNETSessionId $ASPNetSessionID).Name -eq 'Все пользователи') {
			#Write-Host "Сессия остается"
			return $ASPNetSessionID
		} else {
			#Write-Host "Авторизация закончилась"
			return A2Authenticate -Login $login -Password $password
		}
	} catch {
		#Write-Host "Авторизация закончилась"
		return A2Authenticate -Login $login -Password $password
	}
}

######################################################################
#                                                                    #
#            components/services/persons.asmx                        #
#                                                                    #
######################################################################

# Можно добавить:
# Регулярное выражение проверки почты
# Регулярное выражение проверки телефона
function A2CreatePerson (
    [Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),

    [Parameter(Position=2, HelpMessage="Имя создаваемого пользователя")]
    [ValidateNotNullOrEmpty()]
    [string]$firstName = $(throw "Аргумент 'firstName' обязателен"),

    [Parameter(Position=3, HelpMessage="Фамилия создаваемого пользователя")]
    [ValidateNotNullOrEmpty()]
    [string]$lastName = $(throw "Аргумент 'lastName' обязателен"),

    [Parameter(Position=4, HelpMessage="Наименование организации")]
    [string]$company = '',

    [Parameter(Position=5, HelpMessage="Должность")]
    [ValidateNotNullOrEmpty()]
    [string]$position = $(throw "Аргумент 'position' обязателен"),

    [Parameter(Position=6, HelpMessage="Заметки")]
    [string]$notes = '',

    [Parameter(Position=7, HelpMessage="Телефон")]
    [ValidateNotNullOrEmpty()]
    [string]$businessPhone = $(throw "Аргумент 'businessPhone' обязателен"),

    [Parameter(Position=8, HelpMessage="Мобильный телефон")]
    [string]$mobilePhone = '',

    [Parameter(Position=9, HelpMessage="Факс")]
    [string]$fax = '',

    [Parameter(Position=10, HelpMessage="Электронная почта")]
    [ValidateNotNullOrEmpty()]
    [string]$email = $(throw "Аргумент 'email' обязателен"),

    [Parameter(Position=11, HelpMessage="Фотография в формате Base64")]
    [string]$photoBase64 = ''
) {
    $PersonsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/persons.asmx?WSDL"

    $CreatePerson = $PersonsProxy.CreatePerson($ASPNETSessionId, $firstName, $lastName, $company, $position, $notes, $businessPhone, $mobilePhone, $fax, $email, $photoBase64)

    if ($CreatePerson.Errors -ne '') {
        return $CreatePerson.Errors
    } else {
        return $CreatePerson.Objects
    }
}

# Можно добавить:
# Регулярное выражение проверки почты
# Регулярное выражение проверки телефона
function A2EditPerson (
    [Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),

    [Parameter(Position=2, HelpMessage="Идентификатор изменяемого пользователя")]
    [ValidateNotNullOrEmpty()]
    [string]$uid = $(throw "Аргумент 'uid' обязателен"),

    [Parameter(Position=3, HelpMessage="Имя изменяемого пользователя")]
    [string]$firstName = '',

    [Parameter(Position=4, HelpMessage="Фамилия изменяемого пользователя")]
    [string]$lastName = '',

    [Parameter(Position=5, HelpMessage="Наименование организации")]
    [string]$company = '',

    [Parameter(Position=6, HelpMessage="Должность")]
    [string]$position = '',

    [Parameter(Position=7, HelpMessage="Заметки")]
    [string]$notes = '',

    [Parameter(Position=8, HelpMessage="Телефон")]
    [string]$businessPhone = '',

    [Parameter(Position=9, HelpMessage="Мобильный телефон")]
    [string]$mobilePhone = '',

    [Parameter(Position=10, HelpMessage="Факс")]
    [string]$fax = '',

    [Parameter(Position=11, HelpMessage="Электронная почта")]
    [string]$email = '',

    [Parameter(Position=12, HelpMessage="Фотография в формате Base64")]
    [string]$photoBase64 = '',

    [Parameter(Position=13, HelpMessage="Разрешение пользователю доступ в систему (true или false). По умолчанию true")]
    [ValidateSet("true", "false")]
    [string[]]$allowLogin = 'true'
) {
    $PersonsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/persons.asmx?WSDL"

    $EditPerson = $PersonsProxy.EditPerson($ASPNETSessionId, $uid, $firstName, $lastName, $company, $position, $notes, $businessPhone, $mobilePhone, $fax, $email, $photoBase64, $allowLogin)

    if ($EditPerson.Errors -ne '') {
        return $EditPerson.Errors
    } else {
        return $EditPerson.Objects
    }
}

function A2GetPerson (
    [Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),

    [Parameter(Position=2, HelpMessage="Идентификатор пользователя")]
    [ValidateNotNullOrEmpty()]
    [string]$uid = $(throw "Аргумент 'uid' обязателен") 
) {
    $PersonsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/persons.asmx?WSDL"

    $GetPerson = $PersonsProxy.GetPerson($ASPNETSessionId, $uid)

    if ($GetPerson.Errors -ne '') {
        return $GetPerson.Errors
    } else {
        return $GetPerson.Persons
    }
}

function A2GetPersons (
    [Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен")
) {
    $PersonsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/persons.asmx?WSDL"

    $GetPersons = $PersonsProxy.GetPersons($ASPNETSessionId)

    if ($GetPersons.Errors -ne '') {
        return $GetPersons.Errors
    } else {
        return $GetPersons.Persons
    }
}

function A2GetGroups (
    [Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен")
) {
    $PersonsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/persons.asmx?WSDL"

    $GetGroups = $PersonsProxy.GetGroups($ASPNETSessionId)

    if ($GetGroups.Errors -ne '') {
        return $GetGroups.Errors
    } else {
        return $GetGroups.Objects
    }
}

function A2GetAllowedPersons (
    [Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен")
) {
    $PersonsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/persons.asmx?WSDL"

    $GetAllowedPersons = $PersonsProxy.GetAllowedPersons($ASPNETSessionId)

    if ($GetAllowedPersons.Errors -ne '') {
        return $GetAllowedPersons.Errors
    } else {
        return $GetAllowedPersons.Persons
    }
}

function A2GetPersonsXml (
    [Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен")
) {
    $PersonsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/persons.asmx?WSDL"
    
    $GetPersonsXml = $PersonsProxy.GetPersonsXml($ASPNETSessionId)

    return $GetPersonsXml.users
}

function A2LinkUserToAD (
    [Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),

    [Parameter(Position=2, HelpMessage="Идентификатор пользователя в системе")]
    [ValidateNotNullOrEmpty()]
    [string]$personId = $(throw "Аргумент 'personId' обязателен"),

    [Parameter(Position=3, HelpMessage="Идентификатор пользователя в Active Directory (objectSid)")]
    [ValidateNotNullOrEmpty()]
    [string]$ADid = $(throw "Аргумент 'ADid' обязателен")
) {
    $PersonsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/persons.asmx?WSDL"

    $LinkUserToAD = $PersonsProxy.LinkUserToAD($ASPNETSessionId, $personId, $ADid)

    if ($LinkUserToAD.Errors -ne '') {
        return $LinkUserToAD.Errors 
    } else {
        return $LinkUserToAD.Objects
    }
}

function A2DeleteLinkWithAD (
    [Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),

    [Parameter(Position=2, HelpMessage="Идентификатор пользователя в системе")]
    [ValidateNotNullOrEmpty()]
    [string]$personId = $(throw "Аргумент 'personId' обязателен")
) {
    $PersonsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/persons.asmx?WSDL"

    $DeleteLinkWithAD = $PersonsProxy.DeleteLinkWithAD($ASPNETSessionId, $personId)

    if ($DeleteLinkWithAD.Errors -ne '') {
        return $DeleteLinkWithAD.Errors
    } else {
        return $DeleteLinkWithAD.Objects
    }
}

function A2CheckUserPhoto (
    [Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),

    [Parameter(Position=2, HelpMessage="Идентификатор пользователя в системе")]
    [ValidateNotNullOrEmpty()]
    [string]$personId = $(throw "Аргумент 'personId' обязателен")
) {
    $PersonsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/persons.asmx?WSDL"
	
    $CheckUserPhoto = $PersonsProxy.CheckUserPhoto($ASPNETSessionId, $personId)

    if ($CheckUserPhoto.Errors -ne '') {
        return $CheckUserPhoto.Errors 
    } else {
        return $CheckUserPhoto.Objects
    }
}


######################################################################
#                                                                    #
#          components/services/APIProjects.asmx                      #
#                                                                    #
######################################################################
function A2CreateProjectByDiscussion (
    [Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
		
	[Parameter(Position=2, HelpMessage="Идентификатор дискуссии")]
	[ValidateNotNullOrEmpty()]
    [string]$DiscussionId = $(throw "Аргумент 'DiscussionId' обязателен"),

    [Parameter(Position=3, HelpMessage="Идентификатор родительского проекта")]
	[ValidateNotNullOrEmpty()]
    [string]$ParentProjectId = $(throw "Аргумент 'ParentProjectId' обязателен"),

    [Parameter(Position=4, HelpMessage="Идентификатор типа создаваемого проекта")]
    [ValidateNotNullOrEmpty()]
    [string]$ProjectTypeId = $(throw "Аргумент 'ProjectTypeId' обязателен"),

    [Parameter(Position=5, HelpMessage="Название проекта")]
    [ValidateNotNullOrEmpty()]
    [string]$ProjectName = $(throw "Аргумент 'ProjectName' обязателен"),

    [Parameter(Position=6, HelpMessage="Какой-то ордер")]
    [string]$Order = '',

    [Parameter(Position=7, HelpMessage="Идентификатор руководителя проекта")]
    [string]$ProjectOwnerId = '',

    [Parameter(Position=8, HelpMessage="Идентификатор исполнителя проекта")]
    [string]$ProjectResponsibleId = '',

    [Parameter(Position=9, HelpMessage="Плановая дата начала проекта")]
    [DateTime]$PlannedStartDate,

    [Parameter(Position=10, HelpMessage="Плановая дата окончания проекта")]
    [DateTime]$PlannedEndDate,

    [Parameter(Position=11, HelpMessage="Дополнительные поля проекта. Передавать нужно в виде таблицы хеширования: {FieldId=FieldVal}")]
    [hashtable]$Fields
) {
    $APIProjectsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/APIProjects.asmx?WSDL"
	$typePrefix = $APIProjectsProxy.GetType().Namespace

    $CreateProjectWithDiscussion = New-Object ($typePrefix + '.CreateProjectWithDiscussion')
	
	$CreateProjectWithDiscussion.ASPNETSessionId      = $ASPNETSessionId
	$CreateProjectWithDiscussion.DiscussionId         = $DiscussionId
    $CreateProjectWithDiscussion.ParentProjectId      = $ParentProjectId
    $CreateProjectWithDiscussion.ProjectTypeId        = $ProjectTypeId
    $CreateProjectWithDiscussion.ProjectName          = $ProjectName
    $CreateProjectWithDiscussion.Order                = $Order
    $CreateProjectWithDiscussion.ProjectOwnerId       = $ProjectOwnerId
    $CreateProjectWithDiscussion.ProjectResponsibleId = $ProjectResponsibleId
    if ( $PlannedStartDate -ne $null ) { $CreateProjectWithDiscussion.PlannedStartDate = $PlannedStartDate }
    if ( $PlannedEndDate   -ne $null ) { $CreateProjectWithDiscussion.PlannedEndDate   = $PlannedEndDate   }
    $CreateProjectWithDiscussion.Fields = @()
    	
    if ($Fields.Count -gt 0) {        
        foreach ($Field in $Fields.Keys) {
            $FieldWrapper = New-Object ($typePrefix + '.FieldWrapper')
            $FieldWrapper.FieldId  = $Field
            $FieldWrapper.FieldVal = $Fields.$Field

            $CreateProjectWithDiscussion.Fields += $FieldWrapper
        }
    }
	try {
    	$CreateProjectByDiscussion = $APIProjectsProxy.CreateProjectByDiscussion($CreateProjectWithDiscussion)
	} catch {
		$CreateProjectByDiscussion = ($_.Exception.Message).Split("`r`n")[0]
	}
	return $CreateProjectByDiscussion    
}

function A2GetProjectResourceAssignments(
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор проекта")]
	[ValidateNotNullOrEmpty()]
    [string]$ProjectId = $(throw "Аргумент 'ProjectId' обязателен")
) {
	$APIProjectsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/APIProjects.asmx?WSDL"
	
	$GetProjectResourceAssignments = $APIProjectsProxy.GetProjectResourceAssignments($ASPNETSessionId, $ProjectId)
	
	return $GetProjectResourceAssignments
}

function A2GetGroupsWithPersonsIdsAllowedToWriteDiscussion (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор проекта")]
	[ValidateNotNullOrEmpty()]
    [string]$ProjectId = $(throw "Аргумент 'ProjectId' обязателен")
){
	$APIProjectsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/APIProjects.asmx?WSDL"
	$typePrefix = $APIProjectsProxy.GetType().Namespace
	
	$GetGroupsWithPersonsIdsAllowedToWriteDiscussionDataContract = New-Object ($typePrefix + '.GetGroupsWithPersonsIdsAllowedToWriteDiscussionDataContract')
	$GetGroupsWithPersonsIdsAllowedToWriteDiscussionDataContract.ASPNETSessionId = $ASPNETSessionId
	$GetGroupsWithPersonsIdsAllowedToWriteDiscussionDataContract.ProjectId = $ProjectId
	try {
		$GetGroupsWithPersonsIdsAllowedToWriteDiscussion = $APIProjectsProxy.GetGroupsWithPersonsIdsAllowedToWriteDiscussion($GetGroupsWithPersonsIdsAllowedToWriteDiscussionDataContract)
	} catch {
		$GetGroupsWithPersonsIdsAllowedToWriteDiscussion = ($_.Exception.Message).Split("`r`n")[0]
	}
	return $GetGroupsWithPersonsIdsAllowedToWriteDiscussion
}

function A2GetProjects (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Массив фильтра выбора. Массив должен передаваться в виде объекта (New-Object psobject) со значениями внутри массива: `
		Field, Value, Operation, GroupOr")]
    [psobject]$filterWrappers,
	
	[Parameter(Position=3, HelpMessage="Массив сортировки значений. Массив должен передаваться в виде объекта (New-Object psobject) со значениями внутри массива: `
		Field и Descending")]
    [psobject]$sortWrappers
) {
	$APIProjectsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/APIProjects.asmx?WSDL"
	$typePrefix = $APIProjectsProxy.GetType().Namespace
	
	$FilterWrapper = @()
	$filterWrappers | % {
		$FilterWrapperObject = New-Object ($typePrefix + '.FilterWrapper')
		$FilterWrapperObject.Field = $_.Field
		$FilterWrapperObject.Value = $_.Value
		$FilterWrapperObject.Operation = $_.Operation
		$FilterWrapperObject.GroupOr = $_.GroupOr
		$FilterWrapper += $FilterWrapperObject
	}
	
	$sortWrapper = @()
    if ($sortWrappers) {
	    $sortWrappers | % {
		    $SortWrapperObject = New-Object ($typePrefix + '.SortWrapper')
		    $SortWrapperObject.Field = $_.Field
		    $SortWrapperObject.Descending = $_.Descending
		    $sortWrapper += $SortWrapperObject
	    }
    } else {
        $sortWrapper = $null
    }
    
	
    try {
	    $GetProjects = $APIProjectsProxy.GetProjects($ASPNETSessionId, $FilterWrapper, $SortWrapper)
    } catch {
        $GetProjects = ($_.Exception.Message).Split("`r`n")[0]
    }
	
	return $GetProjects
}

# Нужно добавить шаблон проверки правильности ввода дат
function A2CreateProject (
    [Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),

    [Parameter(Position=2, HelpMessage="Идентификатор родительского проекта")]
    [string]$ParentProjectId = $(throw "Аргумент 'ParentProjectId' обязателен"),

    [Parameter(Position=3, HelpMessage="Идентификатор типа создаваемого проекта")]
    [ValidateNotNullOrEmpty()]
    [string]$ProjectTypeId = $(throw "Аргумент 'ProjectTypeId' обязателен"),

    [Parameter(Position=4, HelpMessage="Название проекта")]
    [ValidateNotNullOrEmpty()]
    [string]$ProjectName = $(throw "Аргумент 'ProjectName' обязателен"),

    [Parameter(Position=5, HelpMessage="Какой-то ордер")]
    [string]$Order = '',

    [Parameter(Position=6, HelpMessage="Идентификатор руководителя проекта")]
    [string]$ProjectOwnerId = '',

    [Parameter(Position=7, HelpMessage="Идентификатор исполнителя проекта")]
    [string]$ProjectResponsibleId = '',

    [Parameter(Position=8, HelpMessage="Плановая дата начала проекта")]
    [DateTime]$PlannedStartDate,

    [Parameter(Position=9, HelpMessage="Плановая дата окончания проекта")]
    [DateTime]$PlannedEndDate,

    [Parameter(Position=10, HelpMessage="Дополнительные поля проекта. Передавать нужно в виде таблицы хеширования: {FieldId=FieldVal}")]
    [hashtable]$Fields
) {
    $APIProjectsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/APIProjects.asmx?WSDL"
	$typePrefix = $APIProjectsProxy.GetType().Namespace

    $CreateProjectDataContract = New-Object ($typePrefix + '.CreateProjectDataContract')

    $CreateProjectDataContract.ASPNETSessionId      = $ASPNETSessionId
    $CreateProjectDataContract.ParentProjectId      = $ParentProjectId
    $CreateProjectDataContract.ProjectTypeId        = $ProjectTypeId
    $CreateProjectDataContract.ProjectName          = $ProjectName
    $CreateProjectDataContract.Order                = $Order
    $CreateProjectDataContract.ProjectOwnerId       = $ProjectOwnerId
    $CreateProjectDataContract.ProjectResponsibleId = $ProjectResponsibleId
    if ( $PlannedStartDate -ne $null ) { $CreateProjectDataContract.PlannedStartDate = $PlannedStartDate }
    if ( $PlannedEndDate   -ne $null ) { $CreateProjectDataContract.PlannedEndDate   = $PlannedEndDate   }
    $CreateProjectDataContract.Fields = @()
    	
    if ($Fields.Count -gt 0) {        
        foreach ($Field in $Fields.Keys) {
            $FieldWrapper = New-Object ($typePrefix + '.FieldWrapper')
            $FieldWrapper.FieldId  = $Field
            $FieldWrapper.FieldVal = $Fields.$Field

            $CreateProjectDataContract.Fields += $FieldWrapper
        }
    }
	try {
    	$CreateProject = $APIProjectsProxy.CreateProject($CreateProjectDataContract)
	} catch {
		$CreateProject = ($_.Exception.Message).Split("`r`n")[0]
	}
    return $CreateProject
}

function A2GetProject (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор проекта")]
    [ValidateNotNullOrEmpty()]
    [string]$projectId  = $(throw "Аргумент 'projectId ' обязателен")
) {
    $APIProjectsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/APIProjects.asmx?WSDL"	
	$typePrefix = $APIProjectsProxy.GetType().Namespace	
	
	$ProjectIdDataContract = New-Object ($typePrefix + '.ProjectIdDataContract')
	$ProjectIdDataContract.ASPNETSessionId = $ASPNETSessionId
	$ProjectIdDataContract.ProjectId = $projectId
	try {
		$GetProject = $APIProjectsProxy.GetProject($ProjectIdDataContract)
	} catch {
		$GetProject = ($_.Exception.Message).Split("`r`n")[0]
	}	
	return $GetProject
}

function A2GetProjectChilds (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),

    [Parameter(Position=2, HelpMessage="Идентификатор родительского проекта")]
	[ValidateNotNullOrEmpty()]
    [string]$ParentProjectId = $(throw "Аргумент 'ParentProjectId' обязателен"),

    [Parameter(Position=3, HelpMessage="Идентификатор типа проекта")]
    [ValidateNotNullOrEmpty()]
    [string]$TypeId = $(throw "Аргумент 'TypeId' обязателен")
) {
    $APIProjectsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/APIProjects.asmx?WSDL"
	$typePrefix = $APIProjectsProxy.GetType().Namespace

	$GetProjectChildsDataContract = New-Object ($typePrefix + '.GetProjectChildsDataContract')
	$GetProjectChildsDataContract.ASPNETSessionId = $ASPNETSessionId
	$GetProjectChildsDataContract.ParentProjectId = $ParentProjectId
	$GetProjectChildsDataContract.TypeId          = $TypeId

	try {
		$GetProjectChilds = $APIProjectsProxy.GetProjectChilds($GetProjectChildsDataContract)
	} catch {
		$GetProjectChilds = ($_.Exception.Message).Split("`r`n")[0]
	}
	return $GetProjectChilds
}

function A2GetProjectFields (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),

    [Parameter(Position=2, HelpMessage="Идентификатор проекта")]
	[ValidateNotNullOrEmpty()]
    [string]$projectId = $(throw "Аргумент 'projectId' обязателен")
) {
	$APIProjectsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/APIProjects.asmx?WSDL"
    
	try {
		$GetProjectFields = $APIProjectsProxy.GetProjectFields($ASPNETSessionId, $projectId)
	} catch {
		$GetProjectFields = ($_.Exception.Message).Split("`r`n")[0]
	}
	return $GetProjectFields
}

function A2GetHorizontalRelationsProjects (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),

    [Parameter(Position=2, HelpMessage="Идентификатор проекта")]
	[ValidateNotNullOrEmpty()]
    [string]$projectId = $(throw "Аргумент 'projectId' обязателен")
) {	
    $APIProjectsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/APIProjects.asmx?WSDL"
   
	try {
		$GetHorizontalRelationsProjects = $APIProjectsProxy.GetHorizontalRelationsProjects($ASPNETSessionId, $projectId)
	} catch {
		$GetHorizontalRelationsProjects = ($_.Exception.Message).Split("`r`n")[0]
	}
	return $GetHorizontalRelationsProjects
}

# Надо сделать проверку на дату
function A2UpdateProject (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор проекта")]
	[ValidateNotNullOrEmpty()]
    [string]$UID = $(throw "Аргумент 'UID' обязателен"),
	
	[Parameter(Position=3, HelpMessage="Идентификатор родительского проекта")]
    [string]$ParentProjectId = '',	
	
	[Parameter(Position=4, HelpMessage="Название проекта")]
    [string]$Name = '',
	
	[Parameter(Position=5, HelpMessage="Статус проекта")]
    [string]$Status = '',
	
	[Parameter(Position=6, HelpMessage="Процент выполнения проекта")]
    [string]$PercentComplete = '',
	
	[Parameter(Position=7, HelpMessage="Планируемая дата начала проекта")]
    [System.Nullable[DateTime]]$PlannedStartDate = $null,
	
	[Parameter(Position=8, HelpMessage="Планируемая дата окончания проекта")]
    [System.Nullable[DateTime]]$PlannedEndDate = $null,
	
	[Parameter(Position=9, HelpMessage="Фактическая дата начала проекта")]
    [System.Nullable[DateTime]]$ActualStartDate = $null,
	
	[Parameter(Position=10, HelpMessage="Фактическая дата окончания проекта")]
    [System.Nullable[DateTime]]$ActualEndDate = $null,
	
	[Parameter(Position=11, HelpMessage="Идентификатор руководителя проекта")]
    [string]$OwnerId = '',
	
	[Parameter(Position=12, HelpMessage="Идентификатор исполнителя проекта")]
    [string]$ResponsibleId = '',
	
	[Parameter(Position=13, HelpMessage="Дополнительные поля проекта. Передавать нужно в виде таблицы хеширования: {PersonId=Value}")]
    [hashtable]$ResourceAssignments
) {	
    $APIProjectsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/APIProjects.asmx?WSDL"
	$typePrefix = $APIProjectsProxy.GetType().Namespace   
	
	$UpdateProjectDataContract = New-Object ($typePrefix + '.UpdateProjectDataContract')
	$UpdateProjectDataContract.ASPNETSessionId = $ASPNETSessionId
	
	$UpdateProjectDataContract.Project = New-Object ($typePrefix + '.ProjectWrapper')
	$UpdateProjectDataContract.Project.UID              = $UID
	$UpdateProjectDataContract.Project.ParentProjectId  = $ParentProjectId
	$UpdateProjectDataContract.Project.Name             = $Name
	$UpdateProjectDataContract.Project.Status           = $Status
	$UpdateProjectDataContract.Project.PercentComplete  = $PercentComplete
	$UpdateProjectDataContract.Project.OwnerId          = $OwnerId
	$UpdateProjectDataContract.Project.ResponsibleId    = $ResponsibleId
	$UpdateProjectDataContract.Project.ResourceAssignments = @()
	if ( $PlannedStartDate -ne $null ) { $UpdateProjectDataContract.Project.PlannedStartDate = $PlannedStartDate }
	if ( $PlannedEndDate   -ne $null ) { $UpdateProjectDataContract.Project.PlannedEndDate   = $PlannedEndDate   }
	if ( $ActualStartDate  -ne $null ) { $UpdateProjectDataContract.Project.ActualStartDate  = $ActualStartDate  }
	if ( $ActualEndDate    -ne $null ) { $UpdateProjectDataContract.Project.ActualEndDate    = $ActualEndDate    }
	
	if ($ResourceAssignments.Count -gt 0) {        
        foreach ($ResourceAssignment in $ResourceAssignments.Keys) {
            $ResourceAssignmentWrapper = New-Object ($typePrefix + '.ResourceAssignmentWrapper')
            $ResourceAssignmentWrapper.PersonId = $ResourceAssignment
            $ResourceAssignmentWrapper.Value = $ResourceAssignments.$ResourceAssignment
			
			$UpdateProjectDataContract.Project.ResourceAssignments += $ResourceAssignmentWrapper
        }
    }
	try {
		$UpdateProject = $APIProjectsProxy.UpdateProject($UpdateProjectDataContract)
	} catch {
		$UpdateProject = ($_.Exception.Message).Split("`r`n")[0]
	}	
	return $UpdateProject
}

function A2UpdateProjectFields (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор проекта")]
	[ValidateNotNullOrEmpty()]
    [string]$projectId = $(throw "Аргумент 'projectId' обязателен"),
	
	[Parameter(Position=3, HelpMessage="Дополнительные поля проекта. Передавать нужно в виде таблицы хеширования: lstParam =  @{ FieldId1=FieldVal1; FieldId2=FieldVal2 }")]
    [hashtable]$lstParams
) {
	$APIProjectsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/APIProjects.asmx?WSDL"
	$typePrefix = $APIProjectsProxy.GetType().Namespace
    
	$Fields = @()
	if ($lstParams.Count -gt 0) {        
        foreach ($lstParam in $lstParams.Keys) {
            $FieldWrapper = New-Object ($typePrefix + '.FieldWrapper')
            $FieldWrapper.FieldId = $lstParam
        	$FieldWrapper.FieldVal = $lstParams.$lstParam
			
			$Fields += $FieldWrapper
        }
    }
	
	try {
		$UpdateProjectFields = $APIProjectsProxy.UpdateProjectFields($ASPNETSessionId, $projectId, $Fields)
	} catch {
		$UpdateProjectFields = ($_.Exception.Message).Split("`r`n")[0]
	}
	
	return $UpdateProjectFields
}

function A2ChangeParent (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор проекта")]
	[ValidateNotNullOrEmpty()]
    [string]$projectId = $(throw "Аргумент 'projectId' обязателен"),
	
	[Parameter(Position=3, HelpMessage="Идентификатор нового родительского проекта")]
	[ValidateNotNullOrEmpty()]
    [string]$ParentProjectId = $(throw "Аргумент 'ParentProjectId' обязателен")
) {	
    $APIProjectsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/APIProjects.asmx?WSDL"
	$typePrefix = $APIProjectsProxy.GetType().Namespace
   
	$ChangeParentDataContract = New-Object ($typePrefix + '.ChangeParentDataContract')
	$ChangeParentDataContract.ASPNETSessionId = $ASPNETSessionId
	$ChangeParentDataContract.ProjectId       = $projectId
	$ChangeParentDataContract.ParentProjectId = $ParentProjectId
	
	$ChangeParent = $APIProjectsProxy.ChangeParent($ChangeParentDataContract)
	
	return $ChangeParent
}

function A2DelegateProject (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор проекта")]
	[ValidateNotNullOrEmpty()]
    [string]$projectId = $(throw "Аргумент 'projectId' обязателен"),
	
	[Parameter(Position=3, HelpMessage="Идентификатор пользователя, которому делигируется проект")]
	[ValidateNotNullOrEmpty()]
    [string]$DelegateUserId = $(throw "Аргумент 'DelegateUserId' обязателен")
) {	
    $APIProjectsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/APIProjects.asmx?WSDL"
	$typePrefix = $APIProjectsProxy.GetType().Namespace
   
	$DelegateProjectDataContract = New-Object ($typePrefix + '.DelegateProjectDataContract')
	$DelegateProjectDataContract.ASPNETSessionId = $ASPNETSessionId
	$DelegateProjectDataContract.ProjectId       = $projectId
	$DelegateProjectDataContract.DelegateUserId  = $DelegateUserId
	
	try {
		$APIProjectsProxy.DelegateProject($DelegateProjectDataContract)
		$DelegateProject = "Everything allright"
	} catch {
		$DelegateProject = ($_.Exception.Message).Split("`r`n")[0]
	}	
	return $DelegateProject
}

function A2DeleteProject (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор проекта")]
	[ValidateNotNullOrEmpty()]
    [string]$projectId = $(throw "Аргумент 'projectId' обязателен")
) {
	$APIProjectsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/APIProjects.asmx?WSDL"
	$typePrefix = $APIProjectsProxy.GetType().Namespace
    
	$ProjectIdDataContract = New-Object ($typePrefix + '.ProjectIdDataContract')
	$ProjectIdDataContract.ASPNETSessionId = $ASPNETSessionId
	$ProjectIdDataContract.ProjectId       = $projectId
	
    try {
	    $APIProjectsProxy.DeleteProject($ProjectIdDataContract)
        $DeleteProject = "Everything allright"
    } catch {
        $DeleteProject = ($_.Exception.Message).Split("`r`n")[0]
    }
    return $DeleteProject
}

function A2GetProjectsUidsByType (
    [Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),

    [Parameter(Position=2, HelpMessage="Идентификатор типа проекта")]
	[ValidateNotNullOrEmpty()]
    [string]$typeId = $(throw "Аргумент 'typeId' обязателен"),

    [Parameter(Position=3, HelpMessage="Статус проекта")]
    [string]$status = '',

    [Parameter(Position=4, HelpMessage="Идентификатор родительского проекта")]
    [ValidateNotNullOrEmpty()]
    [string]$parentProjectId = ''
) {
    $APIProjectsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/APIProjects.asmx?WSDL" 
    
    $GetProjectsUidsByType = $APIProjectsProxy.GetProjectsUidsByType($ASPNETSessionId, $TypeId, $Status, $ParentProjectId)
	if ($GetProjectsUidsByType.count -eq 0) {
		$GetProjectsUidsByType = $null
	}
	
	return $GetProjectsUidsByType
}

function A2GetSubprojectsDates (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор проекта")]
	[ValidateNotNullOrEmpty()]
    [string]$projectId = $(throw "Аргумент 'projectId' обязателен")
) {	
    $APIProjectsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/APIProjects.asmx?WSDL"
   
	try {
		$GetSubprojectsDates = $APIProjectsProxy.GetSubprojectsDates($ASPNETSessionId, $projectId)
	} catch {
		$GetSubprojectsDates = ($_.Exception.Message).Split("`r`n")[0]
	}
	return $GetSubprojectsDates
}

function A2GetProjectInfo (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор проекта")]
	[ValidateNotNullOrEmpty()]
    [string]$projectId = $(throw "Аргумент 'projectId' обязателен")
) {	
    $APIProjectsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/APIProjects.asmx?WSDL"
   
	try {
		$GetProjectInfo = $APIProjectsProxy.GetProjectInfo($ASPNETSessionId, $projectId)
	} catch {
		$GetProjectInfo = ($_.Exception.Message).Split("`r`n")[0]
	}
	return $GetProjectInfo
}

function A2UpdateProjectInfo (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор проекта")]
	[ValidateNotNullOrEmpty()]
    [string]$projectId = $(throw "Аргумент 'projectId' обязателен"),
	
	[Parameter(Position=3, HelpMessage="Наименование проекта")]
    [string]$name = '',
	
	[Parameter(Position=4, HelpMessage="Цель\описание")]
    [string]$description = '',
	
	[Parameter(Position=5, HelpMessage="Статус проекта")]
    [string]$status = ''
) {	
    $APIProjectsProxy = New-WebServiceProxy -Uri "$($baseUri)/components/services/APIProjects.asmx?WSDL"
   
	$UpdateProjectInfo = $APIProjectsProxy.UpdateProjectInfo($ASPNETSessionId, $projectId, $name, $description, $status)
	
	return $UpdateProjectInfo
}


######################################################################
#                                                                    #
#           components/Services/APIService.asmx                      #
#                                                                    #
######################################################################
function A2GetDirectoryInfo (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор справочника")]
	[ValidateNotNullOrEmpty()]
    [string]$directoryTemplateId = $(throw "Аргумент 'directoryTemplateId' обязателен")
) {	
    $APIServiceProxy = New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIService.asmx?WSDL"
   
	try {
		$GetDirectoryInfo = $APIServiceProxy.GetDirectoryInfo($ASPNETSessionId, $directoryTemplateId)
	} catch {
		$GetDirectoryInfo = ($_.Exception.Message).Split("`r`n")[0]
	}
	return $GetDirectoryInfo
}

function A2GetRecords (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор справочника")]
	[ValidateNotNullOrEmpty()]
    [string]$directoryId = $(throw "Аргумент 'directoryId' обязателен"),
	
	[Parameter(Position=3, HelpMessage="Идентификатор проекта")]
	[ValidateNotNullOrEmpty()]
    [string]$projectId = $(throw "Аргумент 'projectId' обязателен")
) {	
    $APIServiceProxy = New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIService.asmx?WSDL" -Namespace A2.APIService
   
	try {
		$GetRecords = $APIServiceProxy.GetRecords($ASPNETSessionId, $directoryId, $projectId).Records
	} catch {
		$GetRecords = ($_.Exception.Message).Split("`r`n")[0]
	}
	return $GetRecords
}

function A2GetDirectoriesList (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Тип получаемого списка справочников: NonClassifiers/Classifiers")]
    [ValidateNotNullOrEmpty()]
	[ValidateSet("NonClassifiers", "Classifiers")]
    [string]$type = $(throw "Аргумент 'type' обязателен")
) {	
    $APIServiceProxy = New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIService.asmx?WSDL"   
	
	$GetDirectoriesList = $APIServiceProxy.GetDirectoriesList($ASPNETSessionId, $type).Directories
	
	return $GetDirectoriesList
}

function A2InsertDirectoryRecord (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен")
    ,
	[Parameter(Position=2, HelpMessage="Идентификатор справочника")]
    [ValidateNotNullOrEmpty()]
    [string]$directoryTemplateId = $(throw "Аргумент 'directoryTemplateId' обязателен")
    ,
	[Parameter(Position=3, HelpMessage="Идентификатор проекта")]
    [ValidateNotNullOrEmpty()]
    [string]$projectId = $(throw "Аргумент 'projectId' обязателен")
    ,
	[Parameter(Position=4, HelpMessage="Дополнительные поля справочника. Передавать нужно в виде таблицы хеширования: {FieldId=FieldVal}")]
    [hashtable]$lstParams = @{}
    ,
	[Parameter(Position=5, HelpMessage="Системная дата. Передавать параметр только когда в настройках справочника стоит `"Ручной ввод`". В остальных случаях игнорируется")]
	[System.Nullable[DateTime]]$DateTime = $null
	,
    [Parameter(Position=6, HelpMessage="Контакт проекта")]
	[string]$RecordName = ''
) {	
    $APIServiceProxy = New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIService.asmx?WSDL"
	$typePrefix = $APIServiceProxy.GetType().Namespace
   
	$Fields = @()
	if ($lstParams.Count -gt 0) {        
        foreach ($lstParam in $lstParams.Keys) {
            $FieldWrapper = New-Object ($typePrefix + '.FieldWrapper')
            $FieldWrapper.FieldId = $lstParam
        	$FieldWrapper.FieldVal = $lstParams.$lstParam
			
			$Fields += $FieldWrapper
        }
    }
    $RecordWrapper = New-Object ($typePrefix + '.RecordWrapper')
    $RecordWrapper.RecordName = $RecordName
    $RecordWrapper.Date = $DateTime
	#try {
		$InsertDirectoryRecord = $APIServiceProxy.InsertDirectoryRecord($ASPNETSessionId, $directoryTemplateId, $projectId, $Fields, $RecordWrapper)
	#} catch {
	#	$InsertDirectoryRecord = ($_.Exception.Message).Split("`r`n")[0]
	#}
	
	return $InsertDirectoryRecord
}

function A2ChangeDirectoryRecord (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор справочника")]
    [ValidateNotNullOrEmpty()]
    [string]$directoryRecordId  = $(throw "Аргумент 'directoryRecordId' обязателен"),
	
	[Parameter(Position=3, HelpMessage="Дополнительные поля справочника. Передавать нужно в виде таблицы хеширования: {FieldId=FieldVal}")]
    [hashtable]$lstParams = @{},
	
	[Parameter(Position=4, HelpMessage="Системная дата. По умолчанию текущая дата")]
	[System.Nullable[DateTime]]$DateTime = $null
) {
	$APIServiceProxy = New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIService.asmx?WSDL"
	$typePrefix = $APIServiceProxy.GetType().Namespace
	
	$Fields = @()
	if ($lstParams.Count -gt 0) {        
        foreach ($lstParam in $lstParams.Keys) {
            $FieldWrapper = New-Object ($typePrefix + '.FieldWrapper')
            $FieldWrapper.FieldId = $lstParam
        	$FieldWrapper.FieldVal = $lstParams.$lstParam
			
			$Fields += $FieldWrapper
        }
    }
    
	$RecordWrapper = New-Object ($typePrefix + '.RecordWrapper')
	if ($DateTime -ne $null) {
   		$RecordWrapper.Date = $DateTime
	}
	$ChangeDirectoryRecord = $APIServiceProxy.ChangeDirectoryRecord($ASPNETSessionId, $directoryRecordId, $Fields, $RecordWrapper)
}

function A2DeleteDirectoryRecord (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор справочника")]
    [ValidateNotNullOrEmpty()]
    [string]$directoryRecordId  = $(throw "Аргумент 'directoryRecordId' обязателен")
) {
	$APIServiceProxy = New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIService.asmx?WSDL"
	
	$DeleteDirectoryRecord = $APIServiceProxy.DeleteDirectoryRecord($ASPNETSessionId, $directoryRecordId)
	
	return $DeleteDirectoryRecord
}

function A2GetClassifierRecords (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор классификатора")]
    [ValidateNotNullOrEmpty()]
    [string]$classifierId = $(throw "Аргумент 'classifierId' обязателен")
) {
	$APIServiceProxy = New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIService.asmx?WSDL"
	
	try {
		$GetClassifierRecords = $APIServiceProxy.GetClassifierRecords($ASPNETSessionId, $classifierId).Records
	} catch {
		$GetClassifierRecords = ($_.Exception.Message).Split("`r`n")[0]
	}
	
	return $GetClassifierRecords
}

# Нужно будет вернуться к нему и проверить. Пока не понятно как добавлять классификатор
function A2InsertClassifierRecord (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор классификатора")]
    [ValidateNotNullOrEmpty()]
    [string]$classifierId = $(throw "Аргумент 'classifierId' обязателен"),
	
	[Parameter(Position=3, HelpMessage="Наименование")]
    [string]$name = '',
	
	[Parameter(Position=4, HelpMessage="Идентификатор родительского проекта")]
    [ValidateNotNullOrEmpty()]
    [string]$parentId = $(throw "Аргумент 'parentId' обязателен"),
	
	[Parameter(Position=5, HelpMessage="Дополнительные поля классификатора. Передавать нужно в виде таблицы хеширования: @{FieldId=FieldVal}")]
    [hashtable]$lstParams = @{}
) {
	$APIServiceProxy = New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIService.asmx?WSDL"
	$typePrefix = $APIServiceProxy.GetType().Namespace
	
	$Fields = @()
	if ($lstParams.Count -gt 0) {        
        foreach ($lstParam in $lstParams.Keys) {
            $FieldWrapper = New-Object ($typePrefix + '.FieldWrapper')
            $FieldWrapper.FieldId = $lstParam
        	$FieldWrapper.FieldVal = $lstParams.$lstParam
			
			$Fields += $FieldWrapper
        }
    }
	
	$InsertClassifierRecord = $APIServiceProxy.InsertClassifierRecord($ASPNETSessionId, $classifierId, $name, $parentId, $Fields)

	return $InsertClassifierRecord
}

# К этой функции надо тоже вернуться и проверить, как она работает
function A2SearchDirectoryRecordValues (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор справочника")]
    [ValidateNotNullOrEmpty()]
    [string]$directoryId = $(throw "Аргумент 'directoryId' обязателен"),
	
	[Parameter(Position=3, HelpMessage="Идентификатор поля")]
    [string]$fieldId = '',
	
	[Parameter(Position=4, HelpMessage="Значение поля")]
    [string]$fieldValue = ''
) {
	$APIServiceProxy = New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIService.asmx?WSDL"

	$SearchDirectoryRecordValues = $APIServiceProxy.SearchDirectoryRecordValues($ASPNETSessionId, $directoryId, $fieldId, $fieldValue)
	
	return $SearchDirectoryRecordValues
}

function A2GetDocumentVersions (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор документа")]
    [ValidateNotNullOrEmpty()]
    [string]$documentId = $(throw "Аргумент 'documentId' обязателен")

) {
	$APIServiceProxy = New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIService.asmx?WSDL"
	
	$GetDocumentVersions = $APIServiceProxy.GetDocumentVersions($ASPNETSessionId, $documentId)
	
	return $GetDocumentVersions
}

# С версии 3-06
function A2GetRelationObjects (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен")
    ,
	[Parameter(Position=2, HelpMessage="Идентификатор шаблона объектного справочника")]
    [ValidateNotNullOrEmpty()]
    [string]$DirectoryID = $(throw "Аргумент 'DirectoryID' обязателен")
) {
    $APIServiceProxy = New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIService.asmx?WSDL"

    $GetRelationObjects = $APIServiceProxy.GetRelationObjects($ASPNETSessionId, $DirectoryID)

    return $GetRelationObjects
}

# С версии 3-06
function A2InsertObjectToProjectRelation (
    [Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен")
    ,
	[Parameter(Position=2, HelpMessage="Идентификатор записи объектного справочника для связывания( InsertDirectoryRecord его возвращает )")]
    [ValidateNotNullOrEmpty()]
    [string]$directoryRecordObjectID  = $(throw "Аргумент 'directoryRecordObjectID' обязателен")
    ,
    [Parameter(Position=3, HelpMessage="Идентификатор проекта с которым производится связывание")]
    [ValidateNotNullOrEmpty()]
    [string]$projectId  = $(throw "Аргумент 'projectId' обязателен")
    ,
    [Parameter(Position=4, HelpMessage="Идентификатор связи которую надо создать")]
    [ValidateNotNullOrEmpty()]
    [string]$relationTemplateID  = $(throw "Аргумент 'relationTemplateID' обязателен")    
) {
    $APIServiceProxy = New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIService.asmx?WSDL"
    
    $InsertObjectToProjectRelation = $APIServiceProxy.InsertObjectToProjectRelation($ASPNETSessionId, $directoryRecordObjectID, $projectId, $relationTemplateID) 
    
    return $InsertObjectToProjectRelation  
}

# С версии 3-07
function A2GetChildRecords (
    [Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен")
    ,
    [Parameter(Position=2, HelpMessage="Идентификатор группы справочников")]
    [ValidateNotNullOrEmpty()]
    [string]$directoryGroupId = $(throw "Аргумент 'directoryGroupId' обязателен")
    ,
    [Parameter(Position=3, HelpMessage="Ещё что-то")]
    [ValidateNotNullOrEmpty()]
    [string]$parentdirectoryRecordId = $(throw "Аргумент 'parentdirectoryRecordId' обязателен")
    ,
    [Parameter(Position=4, HelpMessage="И ещё что-то")]
    [ValidateNotNullOrEmpty()]
    [string]$childDirectoryId = $(throw "Аргумент 'childDirectoryId' обязателен")
    ,
    [Parameter(Position=5, HelpMessage="Иденитификатор проекта")]
    [ValidateNotNullOrEmpty()]
    [string]$projectId = $(throw "Аргумент 'projectId' обязателен")
) {
    $APIServiceProxy = New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIService.asmx?WSDL"
    
    $GetChildRecords = $APIServiceProxy.GetChildRecords($ASPNETSessionId, $directoryGroupId, $parentdirectoryRecordId, $childDirectoryId, $projectId) 
    
    return $GetChildRecords  
}

######################################################################
#                                                                    #
#          components/Services/APIDiscussions.asmx                   #
#                                                                    #
######################################################################
function A2GetTopicsInfoByProject (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор дискуссии")]
    [ValidateNotNullOrEmpty()]
    [string]$projectId = $(throw "Аргумент 'projectId' обязателен"),
	
	[Parameter(Position=3, HelpMessage="Получить дискуссии подпроектов")]
	[bool]$allowChilds,
	
	[Parameter(Position=4, HelpMessage="Получить по типу дискуссии. Открытые = 0, Закрытые = 1, все = 2. По умолчанию 0 (открытые)")]
	[ValidateSet("0", "1", "2")]
	[string]$discussionStatus = 0,
	
	[Parameter(Position=5, HelpMessage="Автор дискуссии")]
	[string]$authorId 
) {
	$APIDiscussions = New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIDiscussions.asmx?WSDL"
	
	try {
		$GetTopicsInfoByProject = $APIDiscussions.GetTopicsInfoByProject($ASPNETSessionId, $projectId, $allowChilds, $discussionStatus, $authorId)
	} catch {
		$GetTopicsInfoByProject = ($_.Exception.Message).Split("`r`n")[0]
	}
	
	return $GetTopicsInfoByProject
}

function A2GetTopicInfo (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор дискуссии")]
    [ValidateNotNullOrEmpty()]
    [string]$topicId = $(throw "Аргумент 'topicId' обязателен")
) {
	$APIDiscussions =  New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIDiscussions.asmx?WSDL"
	
	try {
		$GetTopicInfo = $APIDiscussions.GetTopicInfo($ASPNETSessionId, $topicId)
	} catch {
		$GetTopicInfo = ($_.Exception.Message).Split("`r`n")[0]
	}
	
	return $GetTopicInfo
}

function A2CreateTopic (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор проекта")]
    [ValidateNotNullOrEmpty()]
    [string]$projectId = $(throw "Аргумент 'projectId' обязателен"),
	
	[Parameter(Position=3, HelpMessage="Тема дискуссии")]
	[string]$title = '',
	
	[Parameter(Position=4, HelpMessage="Содержание дискуссии")]
	[string]$content = '',
	
	[Parameter(Position=5, HelpMessage="Массив идентификаторов адрессатов. Передается в виде простого строкового массива @(address1, address2)")]
	[string[]]$addressees = @()
) {
	$APIDiscussions =  New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIDiscussions.asmx?WSDL"
	try {
		$CreateTopic = $APIDiscussions.CreateTopic($ASPNETSessionId, $projectId, $title, $content, $addressees)
	} catch {
		$CreateTopic = ($_.Exception.Message).Split("`r`n")[0]
	}	
	return $CreateTopic
}

function A2CreateTopicReply (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор дискуссии")]
    [ValidateNotNullOrEmpty()]
    [string]$topicId = $(throw "Аргумент 'topicId' обязателен"),
	
	[Parameter(Position=3, HelpMessage="Ответ на дискуссию")]
	[string]$reply = ''
) {
	$APIDiscussions =  New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIDiscussions.asmx?WSDL"
		
	$CreateTopicReply = $APIDiscussions.CreateTopicReply($ASPNETSessionId, $topicId, $reply)
	
	return $CreateTopicReply
}

function A2GetTopicStatus (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор дискуссии")]
    [ValidateNotNullOrEmpty()]
    [string]$topicId = $(throw "Аргумент 'topicId' обязателен")
) {
	$APIDiscussions =  New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIDiscussions.asmx?WSDL"
	
	try {
		$GetTopicStatus = $APIDiscussions.GetTopicStatus($ASPNETSessionId, $topicId)
	} catch {
		$GetTopicStatus = ($_.Exception.Message).Split("`r`n")[0]
	}
	
	return $GetTopicStatus
}

function A2AskUsersToTopic (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор дискуссии")]
    [ValidateNotNullOrEmpty()]
    [string]$topicId = $(throw "Аргумент 'topicId' обязателен"),
	
	[Parameter(Position=3, HelpMessage="Массив идентификаторов адрессатов. Передается в виде простого строкового массива @(address1, address2)")]
	[string[]]$addressees = @()
) {
	$APIDiscussions =  New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIDiscussions.asmx?WSDL"
	
	$AskUsersToTopic = $APIDiscussions.AskUsersToTopic($ASPNETSessionId, $topicId, $addressees)
	
	return $AskUsersToTopic
}

function A2CreateTopicWithFields (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор проекта")]
    [ValidateNotNullOrEmpty()]
    [string]$projectId = $(throw "Аргумент 'projectId' обязателен"),
	
	[Parameter(Position=3, HelpMessage="Тема дискуссии")]
	[string]$title = '',
	
	[Parameter(Position=4, HelpMessage="Содержание дискуссии")]
	[string]$content = '',
	
	[Parameter(Position=5, HelpMessage="Массив идентификаторов адрессатов. Передается в виде простого строкового массива @(address1, address2)")]
	[string[]]$addressees = @(),
	
	[Parameter(Position=5, HelpMessage="Дополнительные поля классификатора. Передавать нужно в виде таблицы хеширования: @{FieldId1=FieldVal1; FieldId2=FieldVal2}")]
    [hashtable]$Fields = @{}
) {
	$APIDiscussions =  New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIDiscussions.asmx?WSDL"
	$typePrefix = $APIDiscussions.GetType().Namespace
	
	$DiscussionFields = @()
	if ($Fields.Count -gt 0) {        
        foreach ($Field in $Fields.Keys) {
            $FieldWrapper = New-Object ($typePrefix + '.FieldWrapper')
            $FieldWrapper.FieldId = $Field
        	$FieldWrapper.FieldVal = $Fields.$Field
			
			$DiscussionFields += $FieldWrapper
        }
    }
	
	try {
		$CreateTopicWithFields = $APIDiscussions.CreateTopicWithFields($ASPNETSessionId, $projectId, $title, $content, $addressees, $DiscussionFields)
	} catch {
		$CreateTopicWithFields = ($_.Exception.Message).Split("`r`n")[0]
	}
	return $CreateTopicWithFields 
}

function A2OpenExistingTopic (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор дискуссии")]
    [ValidateNotNullOrEmpty()]
    [string]$topicId = $(throw "Аргумент 'topicId' обязателен")
) {
	$APIDiscussions =  New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIDiscussions.asmx?WSDL"
	
	$OpenExistingTopic = $APIDiscussions.OpenExistingTopic($ASPNETSessionId, $topicId)
	
	return $OpenExistingTopic
}

function A2ReAskUsersToTopic (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор дискуссии")]
    [ValidateNotNullOrEmpty()]
    [string]$topicId = $(throw "Аргумент 'topicId' обязателен"),
	
	[Parameter(Position=3, HelpMessage="Запрос ответа и у автора дискуссии. По умолчанию False, если параметр не выбран")]
	[switch]$authorToo
) {
	$APIDiscussions =  New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIDiscussions.asmx?WSDL"
	try {
		$ReAskUsersToTopic = $APIDiscussions.ReAskUsersToTopic($ASPNETSessionId, $topicId, $authorToo)
	} catch {
		$ReAskUsersToTopic = ($_.Exception.Message).Split("`r`n")[0]
	}
	return $ReAskUsersToTopic
}

######################################################################
#                                                                    #
#             components/Services/APIPlans.asmx                      #
#                                                                    #
######################################################################
function A2GetBaselinePlanProject (
	[Parameter(Position=1, HelpMessage="Идентификатор сессии")]
    [ValidateNotNullOrEmpty()]
    [string]$ASPNETSessionId = $(throw "Аргумент 'ASPNETSessionId' обязателен"),
	
	[Parameter(Position=2, HelpMessage="Идентификатор проекта")]
    [ValidateNotNullOrEmpty()]
    [string]$ProjectId = $(throw "Аргумент 'ProjectId' обязателен"),
	
	[Parameter(Position=3, HelpMessage="Не знаю что такое")]
	[string]$IsGetSubProjects = $false
) {
	$APIPlans =  New-WebServiceProxy -Uri "$($baseUri)/components/Services/APIPlans.asmx?WSDL"
	$typePrefix = $APIPlans.GetType().Namespace
	
	$GetBaselinePlanProjectDataContract = New-Object ($typePrefix + ".GetBaselinePlanProjectDataContract")
	
	$GetBaselinePlanProjectDataContract.ASPNETSessionId = $ASPNETSessionId
	$GetBaselinePlanProjectDataContract.ProjectId = $ProjectId
	$GetBaselinePlanProjectDataContract.IsGetSubProjects = $IsGetSubProjects
	
	try {
		$GetBaselinePlanProject = $APIPlans.GetBaselinePlanProject($GetBaselinePlanProjectDataContract)
	} catch {
		$GetBaselinePlanProject = ($_.Exception.Message).Split("`r`n")[0]
	}	
	
	return $GetBaselinePlanProject
}