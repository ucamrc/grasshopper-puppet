class localconfig::hostnames {

    # Add a couple of hostnames that can be used as tenants
    host { 'admin.timetable.vagrant.com': ip => '127.0.0.1' }
    host { '2014.timetable.vagrant.com': ip => '127.0.0.2' }
    host { '2013.timetable.vagrant.com': ip => '127.0.0.2' }
}
