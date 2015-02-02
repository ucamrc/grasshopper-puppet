class grasshopper::setup (
    $ensure_tenant_admin_created = "true",
    $admin_domain,
    $web_domain,
    $app_root_dir,
    $admin_test_url,
    $tenant_test_url,
    $tenant_login_url
    ) {

  if str2bool($ensure_tenant_admin_created) {

      exec { 'temporarily-start-grasshopper-for-setup':
          # if server is not responding, start it
          unless  => "curl --fail ${admin_test_url}",
          command => 'start grasshopper && sleep 5'
      } ->
      file { '/tmp/setup-via-api.sh':
          source => 'puppet:///modules/grasshopper/setup-via-api.sh'
      } ->
      exec { 'initial-setup-via-REST-API':
          # Hardcoded user/pass to match setup-via-api.sh
          unless  => "curl --fail ${tenant_login_url} -e / -X POST -d 'username=admin@test.local&password=admin'",
          # FIXME is web_domain necessarily right beyond dev server?
          command => "/tmp/setup-via-api.sh ${admin_domain} ${web_domain}"
      } -> Exec['temporarily-stop-grasshopper-for-import']

  }

  exec { 'temporarily-stop-grasshopper-for-import':
      # if file for import exists and server is responding, stop the server
      onlyif  => "test -f /tmp/timetabledata.json && curl --fail ${admin_test_url}",
      creates => "/opt/timetabledata.json.imported",
      command => 'stop grasshopper && sleep 5',
  } ->
  exec { 'import-timetable-data':
      onlyif  => "test -f /tmp/timetabledata.json",
      creates => "/opt/timetabledata.json.imported",
      # NOTE app-id currently hardcoded 1 to match setup-via-api.sh
      command => "${app_root_dir}/etc/scripts/data/timetable-import.js --file /tmp/timetabledata.json --app 1 && mv -i /tmp/timetabledata.json /opt/timetabledata.json.imported",
  }

}
