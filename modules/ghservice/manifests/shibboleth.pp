class ghservice::shibboleth {

  $shibsp_hostname = hiera('shibsp_hostname')

  file { '/etc/shibboleth/shibboleth2.xml':
    content => template('ghservice/shibboleth/shibboleth2.xml.erb'),
  } ~>

  service { 'shibd':
    ensure   => running,
    provider => 'upstart',
    notify   => Service['apache2'],
  }

}
