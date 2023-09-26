#!/bin/bash

OPERATION_DATE () {
    echo $(date +%Y%m%d)
}
OPERATION_MINUTE () {
    echo $(date +%Y%m%d%H%M)
}
export SAV_HOSTNAME="https://saviyntcloud.com"
export SAV_URL="$SAV_HOSTNAME/ECM/api"
export EP_OAUTH="$SAV_HOSTNAME/ECM/oauth/access_token"
export EP_GETUSER="$SAV_URL/getUser"
export EP_UPDATEUSER="$SAV_URL/updateUser"
export EP_GETROLES="$SAV_URL/getRoles"
export EP_GETROLEDETAILSFORUSERS="$SAV_URL/v5/getRoleDetailsforUsers"
export EP_GETACCOUNTS="$SAV_URL/getAccounts"
export EP_UPDATEACCOUNTS="$SAV_URL/updateAccount"
export EP_GETENTITLEMENTS="$SAV_URL/getEntitlements"
export EP_ASSIGNACCOUNTTOUSER="$SAV_URL/assignAccountToUser"
export EP_ENDPOINTS="$SAV_URL/getEndpoints"
export EP_ORG="$SAV_URL/getOrganization"
export EP_CONNECTION="$SAV_URL/v5/getConnectionDetails"
export EP_FETCHTASK="$SAV_URL/fetchTasks"
export EP_DISCONTINUETASK="$SAV_URL/v5/discontinueTask"
export EP_CREATETASK="$SAV_URL/v5/createtask"
export EP_FETCHRUNTIMECONTROLSDATA="$SAV_URL/v5/fetchRuntimeControlsData"
export EP_FETCHRUNTIMECONTROLSDATAV2="$SAV_URL/v5/fetchRuntimeControlsDataV2"
export EP_FETCHJOBMETADATA="$SAV_URL/v5/fetchJobMetadata"
export EP_RUNJOBTRIGGER="$SAV_URL/v5/runJobTrigger"
export EP_CREATEREQUEST="$SAV_URL/v5/createrequest"
export EP_FETCHREQUESTHISTORYDETAILS="$SAV_URL/v5/fetchRequestHistoryDetails"
export EP_FETCHREQUESTAPPROVALDETAILS="$SAV_URL/v5/fetchRequestApprovalDetails"
export EP_FETCHREQUESTHISTORY="$SAV_URL/v5/fetchRequestHistory"
export EP_ARSLIST="$SAV_HOSTNAME/ECMv6/api/ars/requests/list"
export EP_ADDROLE="$SAV_URL/addrole"
export EP_REMOVEROLE="$SAV_URL/removerole"
export EP_GETSECURITYSYSTEMS="$SAV_URL/v5/getSecuritySystems"

sav.customproperty.list () { for i in $(seq 1 65); do echo -en customproperty$i" " ;done }

SAV_USER_ATTRIBUTES="accountExpired accountLocked city companyname costcenter country createdate departmentname displayname email employeeType employeeid enabled firstname jobDescription lastname localAuthEnabled manager orgunitid owner passwordExpired preferedFirstName regioncode savUpdateDate secondaryPhone siteid startdate state statuskey street systemUserName updatedate updateuser userKey userSource username $(sav.customproperty.list)"

MAIN_SAV_COMMENT () { echo "via API call using ($funcstack[2]), By:($(jwt.get.sub.from.savpAtoken)), At:($(OPERATION_MINUTE))" }

# cURL
SAVCURL         ()      { curl  -s --location -g --compressed --request $1 "$2" --header "Authorization: Bearer $savpAtoken" ${@:3} }
SAVCURLJSON     ()      { curl  -s --location -g --compressed --request $1 "$2" --header "Authorization: Bearer $savpAtoken"  --header 'Content-Type: application/json' --data-raw ${@:3} }
SAVCURLFORM     ()      { curl  -s --location -g --compressed --request $1 "$2" --header "Authorization: Bearer $savpAtoken"  --header 'Content-Type: application/x-www-form-urlencoded' ${@:3} }

# Auth
savptoken () {
	export SAVPVAL=$(curl --location --request POST "$EP_OAUTH" --data-urlencode 'grant_type=refresh_token' --data-urlencode "refresh_token=$savWebserviceAuthRefreshToken" 2> /dev/null | jq -Sr '"\(.access_token) \(.refresh_token)"')
	export savpAtoken=($(echo $SAVPVAL | awk '{print $1}'))
	export savWebserviceAuthRefreshToken=($(echo $SAVPVAL | awk '{print $2}'))
}
jwt.get.sub                     ()      { echo $1| jq -SrR 'split(".") | .[0],.[1] | @base64d | fromjson | "\(.sub)"' | grep -v null }
jwt.get.sub.from.savpAtoken     ()      { jwt.get.sub $savpAtoken }
sav.p.set.refresh.token         ()      { savWebserviceAuthRefreshToken=$1 ; savptoken }

## User GET Attribute

sav.p.get.user () {
        export IFS=$'\n'
	savptoken &> /dev/null
        local CALL_KIND=$(echo $2 | awk -F'.' '{print $5}')
        local ACTIVE_USER=$(echo $2 | awk -F'.' '{print $4}')
        local ACTIVE_USER_BY=$(echo $2 | awk -F'.' '{print $6}')
        if [ "${CALL_KIND}" = "by" ] ; then
                FILTERCRITERIA=$(echo $2 | awk -F'.' '{print $6}')
                echo -e "\e[1;33m firstname,lastname,username,email,systemUserName,statuskey,createdate,startdate \e[0m"
                SAVCURLJSON POST $EP_GETUSER '{"advsearchcriteria":{"'$FILTERCRITERIA'":"'"$1"'"},
                        "responsefields":["firstname","lastname","username","email","systemUserName","statuskey","createdate","startdate"]
                        }' | jq -Sr '.userdetails[] | "\(.firstname),\(.lastname),\(.username),\(.email),\(.systemUserName),\(.statuskey),\(.createdate),\(.startdate)"' 
        elif [ "${CALL_KIND}" = "user" ] ; then
                if [ "${ACTIVE_USER}" = "active" ] ; then
                        if [ "${ACTIVE_USER_BY}" = "by" ] ; then
                                RESPONSEFIELDS=$(echo $2 | awk -F'.' '{print $6}')
                                FILTERCRITERIA=$(echo $2 | awk -F'.' '{print $8}')
                                echo -e "\e[1;33m firstname,lastname,username,email,systemUserName,statuskey,createdate,startdate \e[0m"
                                SAVCURLJSON POST $EP_GETUSER '{"advsearchcriteria":{"'$FILTERCRITERIA'":"'"$1"'","statuskey":"1"},"responsefields":["firstname","lastname","username","email","systemUserName","statuskey","createdate","startdate"]}' | jq -Sr '.userdetails[] | "\(.firstname),\(.lastname),\(.username),\(.email),\(.systemUserName),\(.statuskey),\(.createdate),\(.startdate)"' 
                        else
                        RESPONSEFIELDS=$(echo $2 | awk -F'.' '{print $6}')
                        FILTERCRITERIA=$(echo $2 | awk -F'.' '{print $8}')
                        SAVCURLJSON POST $EP_GETUSER  '{"advsearchcriteria":{"'$FILTERCRITERIA'":"'"$1"'","statuskey":"1"},"responsefields":["'$RESPONSEFIELDS'"]}' | jq -Sr '.userdetails | .[].'$RESPONSEFIELDS''
                        fi
                fi
        elif [ "${CALL_KIND}" = "json" ] ; then
                FILTERCRITERIA=$(echo $2 | awk -F'.' '{print $7}')
                SAVCURLJSON POST $EP_GETUSER '{"advsearchcriteria":{"'$FILTERCRITERIA'":"'"$1"'"}}' | jq -Sr '.userdetails[]'
        else
                RESPONSEFIELDS=$(echo $2 | awk -F'.' '{print $5}')
                FILTERCRITERIA=$(echo $2 | awk -F'.' '{print $7}')
	        SAVCURLJSON POST $EP_GETUSER  '{"advsearchcriteria":{"'$FILTERCRITERIA'":"'"$1"'"},"responsefields":["'$RESPONSEFIELDS'"]}' | jq -Sr '.userdetails | .[].'$RESPONSEFIELDS'' 
        fi
        unset RESPONSEFIELDS FILTERCRITERIA
}
# Child Functions Constructor
export IFS=$' '
for CHILD_FUNCTION_ATTR in $(echo $SAV_USER_ATTRIBUTES)
    do 
        set sav.p.get.user.by.$CHILD_FUNCTION_ATTR              () { sav.p.get.user $1 $0 };
        set sav.p.get.active.user.by.$CHILD_FUNCTION_ATTR       () { sav.p.get.user $1 $0 };
        set sav.p.get.user.json.by.$CHILD_FUNCTION_ATTR         () { sav.p.get.user $1 $0 };
    for CHILD_FUNCTION_GET_ATTR in $(echo $SAV_USER_ATTRIBUTES)
        do
                set sav.p.get.user.$CHILD_FUNCTION_ATTR.by.$CHILD_FUNCTION_GET_ATTR () { sav.p.get.user $1 $0 };
                set sav.p.get.active.user.$CHILD_FUNCTION_ATTR.by.$CHILD_FUNCTION_GET_ATTR () { sav.p.get.user $1 $0 };
        done
    done
export IFS=$'\n'

sav.p.get.active.user.by.email () { sav.p.get.user.by.email $1 | grep ',1,'}
sav.p.get.active.user.username.by.email () { sav.p.get.user.by.email $1 | grep ',1,' | awk -F, '{print $3}' }
sav.p.get.active.user.email.by.email () { sav.p.get.user.by.email $1 | grep ',1,' | awk -F, '{print $4}' }
sav.p.get.active.user.systemUserName.by.email () { sav.p.get.user.by.email $1 | grep ',1,' | awk -F, '{print $5}' }
sav.p.get.active.user.username.by.systemUserName () { sav.p.get.user.by.systemUserName $1 | grep ',1,' | awk -F, '{print $3}' }
