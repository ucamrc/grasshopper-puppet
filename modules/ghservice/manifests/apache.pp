class ghservice::apache (
    $enable_basic_auth = "false",
    $enable_ssl = "false",
    $enable_shib = hiera('enable_shib', 'false'),
    $self_signed_ssl = "false",
    $ssl_dir = "/etc/apache2/ssl",
    ) {

    if $enable_basic_auth == 'true' {
      # This package provides the "htpasswd" command for setting passwords
      package { 'apache2-utils': }
    }

    class { '::apache': 
        default_vhost => false,
    }

    class { '::apache::mod::proxy': }
    class { '::apache::mod::proxy_http': }
    class { '::apache::mod::rewrite': }
    if $enable_shib == 'true' {
      class { '::apache::mod::shib': }
      include ::ghservice::shibboleth
    }

    $admin_servername = hiera('admin_hostname')
    $tenant_servername = hiera('tenant_hostname')
    if $enable_shib == 'true' {
      $shibsp_servername = hiera('shibsp_hostname')
    }

    if $enable_ssl == 'true' {
## FIXME sort out sensible permissions
      file { $ssl_dir:
        ensure => "directory"
      }
      $path_ssl_tenant_base = "${ssl_dir}/tenant"
      $path_ssl_admin_base = "${ssl_dir}/admin"
      if $enable_shib == 'true' {
        $path_ssl_shibsp_base = "${ssl_dir}/shibsp"
      }
    }

    if $self_signed_ssl == 'true' {
      class { '::apache::mod::ssl': }

      ghservice::selfsignedcert { $tenant_servername:
        basename => "tenant",
      }
      ghservice::selfsignedcert { $admin_servername:
        basename => "admin",
      }

      if $enable_shib == 'true' {
        ghservice::selfsignedcert { $shibsp_servername:
          basename => "shibsp",
        }
      }

    }
    $main_port = $enable_ssl ? {
      'true'  => '443',
      default => '80',
    }

    $path_ui_root = hiera('ui_root_dir')

    $path_shared            = "${path_ui_root}/shared"
    $path_docs              = "${path_ui_root}/docs"
    $path_apps              = "${path_ui_root}/apps"
    $path_admin_docroot     = "${path_ui_root}/apps/admin/ui"
    $path_timetable_docroot = "${path_ui_root}/apps/timetable/ui"
    $path_timetable_admin   = "${path_ui_root}/apps/timetable/admin"

    $apache_dir_require = $enable_basic_auth ? {
        'true'  => 'valid-user',
        default => 'all granted',
    }

    $path_robotstxt         = '/var/www/robots.txt'

    file { $path_robotstxt:
        source => 'puppet:///modules/ghservice/robots.txt.disallowall'
    }

    # VirtualHosts are loaded in alphabetical order;
    #
    # Requests that do not match a specified ServerName directive
    # get sent to the default VirtualHost, which is always the first one.
    # See https://httpd.apache.org/docs/2.4/vhosts/examples.html
    #
    # We assume that requests that do not match are new tenants.
    # (In production we would probably want the default VirtualHost
    # to show an error message instead).

    apache::vhost { 'app_timetable':
        priority        => 10,
        vhost_name      => '*',
        port            => $main_port,
        servername      => $tenant_servername,
        docroot         => $path_timetable_docroot,
        directories     => [
            { 'path'      => $path_timetable_docroot,
              'require'   => $apache_dir_require,
            }
        ],
        # We prefer to control the rest of the file ourselves
        # so stop the module from generating other stuff
        error_log       => false,
        access_log      => false,
        custom_fragment => template('ghservice/apache/app_timetable.conf.erb'),
    }

    if $enable_shib == 'true' {

      apache::vhost { 'app_shibsp':
          priority        => 50,
          vhost_name      => '*',
          port            => $main_port,
          servername      => $shibsp_servername,
          docroot         => $path_timetable_docroot,
          directories     => [
              { 'path'      => $path_timetable_docroot,
                'require'   => 'all denied',
              }
          ],
          # We prefer to control the rest of the file ourselves
          # so stop the module from generating other stuff
          error_log       => false,
          access_log      => false,
          custom_fragment => template('ghservice/apache/app_shibsp.conf.erb'),
      }
    }

    apache::vhost { 'app_admin':
        priority        => 99,
        vhost_name      => '*',
        port            => $main_port,
        servername      => $admin_servername,
        docroot         => $path_admin_docroot,
        directories     => [
            { 'path'      => $path_admin_docroot,
              'require'   => $apache_dir_require,
            }
        ],
        # We prefer to control the rest of the file ourselves
        # so stop the module from generating other stuff
        error_log       => false,
        access_log      => false,
        custom_fragment => template('ghservice/apache/app_admin.conf.erb'),
    }

}
