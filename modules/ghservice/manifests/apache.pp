class ghservice::apache (
    $enable_basic_auth = "false" 
    ) {

    class { '::apache': 
        default_vhost => false,
    }

    class { '::apache::mod::proxy': }
    class { '::apache::mod::proxy_http': }
    class { '::apache::mod::rewrite': }

    if str2bool($enable_basic_auth) {
      # This package provides the "htpasswd" command for setting passwords
      package { 'apache2-utils': }
    }

    apache::listen { '80': }

### CHECK IF THIS IS THE RIGHT WAY TO DO THIS?

    # FIXME this duplicates code in modules/ghservice/manifests/grasshopper.pp
    $web_domain = hiera('web_domain')
    $app_admin_tenant = hiera('app_admin_tenant', 'admin')
    $admin_domain = "${app_admin_tenant}.${web_domain}"

    $admin_servername = $admin_domain

    # VirtualHosts are loaded in alphabetical order
    # Requests that do not match a specified ServerName directive
    # get sent to the default VirtualHost, which is always the first one.
    # See https://httpd.apache.org/docs/2.4/vhosts/examples.html

    file { '/etc/apache2/sites-enabled/000-app_timetable.conf':
        ensure  => file,
        content => template('ghservice/apache/app_timetable.conf.erb')
    }

    file { '/etc/apache2/sites-enabled/100-app_admin.conf':
        ensure  => file,
        content => template('ghservice/apache/app_admin.conf.erb')
    }

}
