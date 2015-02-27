class ghservice::shibboleth {

  $shibsp_hostname = hiera('shibsp_hostname')

  file { '/etc/shibboleth/shibboleth2.xml':
    content => template('ghservice/shibboleth/shibboleth2.xml.erb'),
    # TODO: notify => Service['shibd'] ? (need to create one of those first?)
  }

}
