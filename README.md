# saviynt-bash-cli
Bash functions that interacts with Saviynt APIs


These are the scripts in any language with proper steps to be run for ad hoc changes that are not part of the regular code changes.
Mainly these scripts are used to query data from different systems.

# Installation
Source these scripts into your bash profile (Ideally working with MacOS, if you are using ubuntu, you might need to adjust some command's arguments)

# Use Cases

## Obtain Saviynt Token
To use the script fucntions you need to obtain Saviynt token from Admin -> Settings -> webserviceAuthentication, then Generate token and copy the refresh_token value without " then pass the value to `sav.p.set.refresh.token` function

Example:
```sav.p.set.refresh.token eyJhbGciOiJXVCJ9.eyJzdWIiOiIxMjM0NTYM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c```

# Query Data
## Query User from Saviynt
There are three types of data you can get 
- comma separated
- json
- attribute

based on function name, you can direct the script to the type of data you need.
### user.by
`sav.p.get.user.by.email someone@example.com`
it will print `firstname,lastname,username,email,systemUserName,statuskey,savUpdateDate` for the user

### user.json
`sav.p.get.user.json.by.email someone@example.com`
it will print the full json response from Saviynt for the user

### user.attribute
`sav.p.get.user.orgunitid.by.email someone@example.com`
it will print only the orgunitid as `00000000`

# POST Operations
## sav.p.post.discontinue.PendingAccessGrantingTasksForInactiveUsers
### If saviynt can automatically discontinue tasks for inactive user, this function shall not be used
this function discontinues access-granting tasks for inactive saviynt users; the default max is 50 tasks, So you need to run the function 3 times if we have the number of tasks > 100 and <= 150

Example:

```
sav.p.post.discontinue.PendingAccessGrantingTasksForInactiveUsers
{"result":{"9078101":"Discontinued"},"msg":"Success","errorcode":"0"}{"result":{"9078112":"Discontinued"},"msg":"Success","errorcode":"0"}
```

