TENANTHOSTNAME=$1

if [[ X"" = X"$TENANTHOSTNAME" ]]; then
echo "ERROR: Please supply tenant hostname"
  exit 0;
fi

##### Setup Tenant using local-only admin.grasshopper.com #####

# LOGIN
curl -b /tmp/curlcookiejar -c /tmp/curlcookiejar -w '\nHTTP STATUS: %{http_code}\nTIME: %{time_total}\n' -e / admin.grasshopper.com/api/auth/login -X POST -d 'password=administrator&username=administrator'

# TODO: change the password when it is implemented(!)

# LIST TENANTS (CHECK LOGGED IN OK)
curl -b /tmp/curlcookiejar -c /tmp/curlcookiejar -w '\nHTTP STATUS: %{http_code}\nTIME: %{time_total}\n' -e / admin.grasshopper.com/api/tenants

# CREATE TENANT
curl -b /tmp/curlcookiejar -c /tmp/curlcookiejar -w '\nHTTP STATUS: %{http_code}\nTIME: %{time_total}\n' -e / admin.grasshopper.com/api/tenants -X POST -d 'displayName=mytenant'
### assume returns "id":1

# CREATE APP (needs tenantId from above, change host param to match)
curl -b /tmp/curlcookiejar -c /tmp/curlcookiejar -w '\nHTTP STATUS: %{http_code}\nTIME: %{time_total}\n' -e / admin.grasshopper.com/api/apps -X POST -d 'displayName=myapp&tenantId=1&host='$TENANTHOSTNAME'&type=timetable'
### assume returns "id":1

# CREATE APP USER (needs appId from above)
curl -b /tmp/curlcookiejar -c /tmp/curlcookiejar -w '\nHTTP STATUS: %{http_code}\nTIME: %{time_total}\n' -e / admin.grasshopper.com/api/users -X POST -d 'appId=1&displayName=TestUser&email=test&password=test'

