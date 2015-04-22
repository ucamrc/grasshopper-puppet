#!/usr/bin/env bash

ADMINHOSTNAME=$1
TENANTHOSTNAME=$2
TENANTAPPDISPLAYNAME=$3
SHIBIDPENTITYID=$4

TENANTAPPACADEMICYEAR=2014

if [[ X"" = X"$ADMINHOSTNAME" || X"" = X"$TENANTHOSTNAME" || X"" = X"$TENANTAPPDISPLAYNAME" ]]; then
  echo "Usage: $0 admin.domain.com tenant.domain.com Display+Name+Escaped [optional:shibIdpEntityId]"
  exit 0;
fi

ENABLESHIB=true
if [[ X"" = X"$SHIBIDPENTITYID" ]]; then
  ENABLESHIB=false
fi

# See https://wiki.cam.ac.uk/raven/Attributes_released_by_the_Raven_IdP
# Also note that the attributes currently come via HTTP headers that
# have been mapped to lower-case, hence displayname not displayName

# For Raven IdP, CRSid=uid
SHIBATTRMAPID=uid+eppn+persistent-id+targeted-id
SHIBATTRMAPDISPLAYNAME=displayname+cn
SHIBATTRMAPEMAIL=mail+email+eppn

# LOGIN
curl -b /tmp/curlcookiejar -c /tmp/curlcookiejar -w '\nHTTP STATUS: %{http_code}\nTIME: %{time_total}\n' -e / ${ADMINHOSTNAME}:2000/api/auth/login -X POST -d 'password=administrator&username=administrator' || exit 1;

# TODO: change the password when it is implemented(!)

# LIST TENANTS (CHECK LOGGED IN OK)
curl -b /tmp/curlcookiejar -c /tmp/curlcookiejar -w '\nHTTP STATUS: %{http_code}\nTIME: %{time_total}\n' -e / ${ADMINHOSTNAME}:2000/api/tenants || exit 1;

# CREATE TENANT
curl -b /tmp/curlcookiejar -c /tmp/curlcookiejar -w '\nHTTP STATUS: %{http_code}\nTIME: %{time_total}\n' -e / ${ADMINHOSTNAME}:2000/api/tenants -X POST -d 'displayName=DevTenant' || exit 1;
### assume returns "id":1

# CREATE APP (needs tenantId from above, change host param to match)
curl -b /tmp/curlcookiejar -c /tmp/curlcookiejar -w '\nHTTP STATUS: %{http_code}\nTIME: %{time_total}\n' -e / ${ADMINHOSTNAME}:2000/api/apps -X POST -d 'displayName='$TENANTAPPDISPLAYNAME'&tenantId=1&host='$TENANTHOSTNAME'&type=timetable' || exit 1;
### assume returns "id":1

# CONFIGURE APP
curl -b /tmp/curlcookiejar -c /tmp/curlcookiejar -w '\nHTTP STATUS: %{http_code}\nTIME: %{time_total}\n' -e / ${ADMINHOSTNAME}:2000/api/config -X POST -d 'app=1&academicYear='$TENANTAPPACADEMICYEAR'&enableShibbolethAuth='$ENABLESHIB'&shibIdpEntityId='$SHIBIDPENTITYID'&enableLocalAuth=true&shibExternalIdAttributes='$SHIBATTRMAPID'&shibMapDisplayname='$SHIBATTRMAPDISPLAYNAME'&shibMapEmail='$SHIBATTRMAPEMAIL'&allowUserEventCreation=true&allowUserSerieCreation=true&analyticsTrackingId=&statsd=&allowLocalAccountCreation=false&enableAnalytics=false' || exit 1;

if [[ X"false" = X"$ENABLESHIB" ]]; then
  # CREATE LOCAL APP USERS (needs appId from above)
  # Student
  curl -b /tmp/curlcookiejar -c /tmp/curlcookiejar -w '\nHTTP STATUS: %{http_code}\nTIME: %{time_total}\n' -e / ${ADMINHOSTNAME}:2000/api/users -X POST -d 'app=1&displayName=Test%20Student&email=student@test.local&password=student' || exit 1;
  # Admin
  curl -b /tmp/curlcookiejar -c /tmp/curlcookiejar -w '\nHTTP STATUS: %{http_code}\nTIME: %{time_total}\n' -e / ${ADMINHOSTNAME}:2000/api/users -X POST -d 'app=1&displayName=Test%20Admin&email=admin@test.local&password=admin1&isAdmin=true' || exit 1;
fi

