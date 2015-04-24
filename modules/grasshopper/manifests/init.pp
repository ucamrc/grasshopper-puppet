#
# Valid options for install_method and install_config are enumerated in ::grasshopper::install namespace documentation
#
class grasshopper (
    $app_root_dir,

    $install_method = 'git',
    $install_config = {
      'source' => 'https://github.com/CUL-DigitalServices/grasshopper',
      'revision' => 'master'
    },

    $os_user,
    $os_group,

    ############
    ## Config ##
    ############

    $config_cookie_secret,
    $config_servers_admin_host,

    # DB
    $config_db_name = hiera('ghservice::postgresql::db'),
    $config_db_user = hiera('ghservice::postgresql::user'),
    $config_db_pass = hiera('ghservice::postgresql::pass'),

    # Initialisation
    $ensure_tenant_admin_created = "true",

    # UI
    $config_ui_path = '/opt/grasshopper-ui'
  ) {


  ##################
  ## INSTALLATION ##
  ##################

  class { "::grasshopper::install::${install_method}":
    install_config  => $install_config,
    app_root_dir    => $app_root_dir,
  }

  # Upstart script
  Class["::grasshopper::install::${install_method}"] -> File["/etc/init/grasshopper.conf"]

  # Grasshopper config.js
  Class["::grasshopper::install::${install_method}"] -> File["${app_root_dir}/config.js"]

  # Grasshopper config file
  file { "${app_root_dir}/config.js":
    ensure  => present,
    mode    => "0644",
    owner   => $os_user,
    group   => $os_group,
    content => template('grasshopper/config.js.erb'),
    notify  => Service['grasshopper'],
  }


  ###################
  ## CONFIGURATION ##
  ###################

  file { "/etc/init/grasshopper.conf":
    ensure  => present,
    content => template('grasshopper/upstart_grasshopper.conf.erb'),
    notify  => Service['grasshopper'],
  }

  $admin_hostname = hiera('admin_hostname')
  $tenant_hostname = hiera('tenant_hostname')

  class { 'grasshopper::setup':
    app_root_dir     => $app_root_dir,
    admin_hostname   => $admin_hostname,
    tenant_hostname  => $tenant_hostname,
    admin_test_url   => "${admin_hostname}:2000/api/me",
    tenant_test_url  => "${tenant_hostname}:2001/api/me",
    tenant_login_url => "${tenant_hostname}:2001/api/auth/login",
    require          => [ File['/etc/init/grasshopper.conf', "${app_root_dir}/config.js"] , Class['ghservice::postgresql'] ]
  } ->

  service { 'grasshopper':
    ensure   => running,
    provider => 'upstart',
    require  => [ File['/etc/init/grasshopper.conf', "${app_root_dir}/config.js"] , Class['ghservice::postgresql'] ]
  }


}
