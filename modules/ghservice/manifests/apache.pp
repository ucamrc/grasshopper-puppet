class ghservice::apache {

    class { '::apache': 
## REDO THIS FROM UBUNTU VERSION ??
## or is standard one good enough (with the two mod enables below)
##        conf_template => 'ghservice/apache/httpd.conf.erb'
    }

    class { '::apache::mod::proxy': }
    class { '::apache::mod::proxy_http': }
    class { '::apache::mod::rewrite': }

### CHECK IF THIS IS THE RIGHT WAY TO DO THIS?

    file { '/etc/apache2/sites-enabled/app_admin.conf':
        ensure  => file,
        content => template('ghservice/apache/app_admin.conf.erb')
    }

    file { '/etc/apache2/sites-enabled/app_timetable.conf':
        ensure  => file,
        content => template('ghservice/apache/app_timetable.conf.erb')
    }

}
