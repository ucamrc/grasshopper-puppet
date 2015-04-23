class ghservice::shibboleth (
  # Default to IdP settings for TestShib
  $idp_entityid = "https://idp.testshib.org/idp/shibboleth",
  $idp_metadata_uri = "http://www.testshib.org/metadata/testshib-providers.xml",
  $idp_metadata_localfile = "testshib-two-idp-metadata.xml",
  ) {

  $shibsp_hostname = hiera('shibsp_hostname')

  # Reduce this in production!
  $clock_skew = 1800

  ## POSSIBLY OVERRIDE THIS??
  $sp_entityid = "https://${shibsp_hostname}/shibboleth"

  # May want to review this in production
  $session_handler_show_attribute_values = "true"

  exec { "shib-keygen -h ${shibsp_hostname}":
    # This also creates /etc/shibboleth/sp-cert.pem
    creates => "/etc/shibboleth/sp-key.pem",
    notify  => Service['shibd'],
    require => Class['::apache::mod::shib'],
  } ->

  file { '/etc/shibboleth/attribute-map.xml':
    source => 'puppet:///modules/ghservice/shibboleth/attribute-map.xml',
  } ->

  file { '/etc/shibboleth/shibboleth2.xml':
    content => template('ghservice/shibboleth/shibboleth2.xml.erb'),
  }

  service { 'shibd':
    subscribe => File['/etc/shibboleth/shibboleth2.xml','/etc/shibboleth/attribute-map.xml'],
    ensure    => running,
    provider  => 'upstart',
    notify    => Service['apache2'],
  }

}
