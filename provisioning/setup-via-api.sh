#!/usr/bin/env bash

ADMINHOSTNAME=$1
TENANTHOSTNAME=$2

if [[ X"" = X"$ADMINHOSTNAME" || X"" = X"$TENANTHOSTNAME" ]]; then
echo "Usage: $0 admin.domain.com tenant.domain.com"
  exit 0;
fi

# LOGIN
curl -b /tmp/curlcookiejar -c /tmp/curlcookiejar -w '\nHTTP STATUS: %{http_code}\nTIME: %{time_total}\n' -e / ${ADMINHOSTNAME}:2000/api/auth/login -X POST -d 'password=administrator&username=administrator' || exit 1;

# TODO: change the password when it is implemented(!)

# LIST TENANTS (CHECK LOGGED IN OK)
curl -b /tmp/curlcookiejar -c /tmp/curlcookiejar -w '\nHTTP STATUS: %{http_code}\nTIME: %{time_total}\n' -e / ${ADMINHOSTNAME}:2000/api/tenants || exit 1;

# CREATE TENANT
curl -b /tmp/curlcookiejar -c /tmp/curlcookiejar -w '\nHTTP STATUS: %{http_code}\nTIME: %{time_total}\n' -e / ${ADMINHOSTNAME}:2000/api/tenants -X POST -d 'displayName=mytenant' || exit 1;
### assume returns "id":1

# CREATE APP (needs tenantId from above, change host param to match)
curl -b /tmp/curlcookiejar -c /tmp/curlcookiejar -w '\nHTTP STATUS: %{http_code}\nTIME: %{time_total}\n' -e / ${ADMINHOSTNAME}:2000/api/apps -X POST -d 'displayName=myapp&tenantId=1&host='$TENANTHOSTNAME'&type=timetable' || exit 1;
### assume returns "id":1

# CREATE APP USER (needs appId from above)
curl -b /tmp/curlcookiejar -c /tmp/curlcookiejar -w '\nHTTP STATUS: %{http_code}\nTIME: %{time_total}\n' -e / ${ADMINHOSTNAME}:2000/api/users -X POST -d 'appId=1&displayName=TestUser&email=test&password=test' || exit 1;

