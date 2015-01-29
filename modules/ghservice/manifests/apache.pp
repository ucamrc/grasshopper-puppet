class ghservice::apache {

    class { '::apache': 
        default_vhost => false,

## REDO THIS FROM UBUNTU VERSION ??
## or is standard one good enough (with the two mod enables below)
##        conf_template => 'ghservice/apache/httpd.conf.erb'
    }

    class { '::apache::mod::proxy': }
    class { '::apache::mod::proxy_http': }
    class { '::apache::mod::rewrite': }

    apache::listen { '80': }

### CHECK IF THIS IS THE RIGHT WAY TO DO THIS?

    # FIXME this duplicates code in modules/ghservice/manifests/grasshopper.pp
    $web_domain = hiera('web_domain')
    $app_admin_tenant = hiera('app_admin_tenant', 'admin')
    $admin_domain = "${app_admin_tenant}.${web_domain}"

    $admin_servername = $admin_domain

    file { '/etc/apache2/sites-enabled/app_admin.conf':
        ensure  => file,
        content => template('ghservice/apache/app_admin.conf.erb')
    }

    file { '/etc/apache2/sites-enabled/app_timetable.conf':
        ensure  => file,
        content => template('ghservice/apache/app_timetable.conf.erb')
    }

}
