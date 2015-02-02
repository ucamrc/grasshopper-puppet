class grasshopper::setup (
    $ensure_tenant_admin_created = "true",
    $tenant_test_url,
    $tenant_login_url
    ) {


# TODO make sure all prereqs ready before trying to run start grasshopper !!

  if str2bool($ensure_tenant_admin_created) {
  exec { 'temporarily-start-grasshopper':
          unless  => "curl --fail ${tenant_test_url}",
          command => 'start grasshopper && sleep 5'
  } ->

  file { '/tmp/setup-via-api.sh':
# FIXME move this source file when we refactor this whole end block out
    source => 'puppet:///modules/grasshopper/setup-via-api.sh'
  } ->
# FIXME is web_domain necessarily right beyond dev server?
  exec { 'initial-config-via-REST':
         unless  => "curl --fail ${$tenant_login_url} -e / -X POST -d 'username=admin@test.local&password=admin'",
         command => "/tmp/setup-via-api.sh ${admin_domain} ${web_domain}"
  } -> Exec['temporarily-stop-grasshopper']

  }

  exec { 'temporarily-stop-grasshopper':
          onlyif  => "test -f /tmp/timetabledata.json && curl --fail ${tenant_test_url}",
          creates => "/opt/timetabledata.json.imported",
          command => 'stop grasshopper && sleep 5',
  } ->
# NOTE app-id currently hardcoded 1 to match script
  exec { 'import':
     onlyif  => "test -f /tmp/timetabledata.json",
     creates => "/opt/timetabledata.json.imported",
     command => "${app_root_dir}/etc/scripts/data/timetable-import.js -f /tmp/timetabledata.json -a 1 && mv -i /tmp/timetabledata.json /opt/timetabledata.json.imported",
  }


}
