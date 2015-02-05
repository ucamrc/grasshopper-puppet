class grasshopper::setup (
    $ensure_tenant_admin_created = "true",
    $app_root_dir,
    $admin_hostname,
    $tenant_hostname,
    $tenant_appdisplayname_escaped = "My+Timetable+-+Experimental+Dev+Server",
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
          command => "/tmp/setup-via-api.sh ${admin_hostname} ${tenant_hostname} ${tenant_appdisplayname_escaped}"
      } -> Exec['temporarily-stop-grasshopper-for-import']

  }


  exec { 'temporarily-stop-grasshopper-for-import':
      # if file for import exists and server is responding, stop the server
      onlyif  => "test -f /tmp/timetabledata.json && curl --fail ${admin_test_url}",

      # "creates => foo" is confusing puppet-speak for:
      # "command will create file foo, so don't execute if foo already exists"
      #
      # In actual fact, the next exec below "creates" the file.
      # We replicate the conditional on this exec so that we don't stop
      # grasshopper unless we're actually planning to import anything.
      creates => "/opt/timetabledata.json.imported",

      command => 'stop grasshopper && sleep 5',
  } ->

  # If     /tmp/timetabledata.json exists
  #    and /opt/timetabledata.json.imported does not exist:
  #
  # Then import /tmp/timetabledata.json
  #
  # If successfully imported
  # Then move the file to /opt/timetabledata.json.imported
  #
  exec { 'import-timetable-data':
      onlyif  => "test -f /tmp/timetabledata.json",
      # The "mv" part of the command results in this file being "created":
      creates => "/opt/timetabledata.json.imported",
      # NOTE app-id currently hardcoded 1 to match setup-via-api.sh
      command => "node ${app_root_dir}/etc/scripts/data/timetable-import.js --file /tmp/timetabledata.json --app 1 && mv -i /tmp/timetabledata.json /opt/timetabledata.json.imported",
      timeout => 36000,
  }

}
