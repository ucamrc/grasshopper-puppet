class ghservice::shibboleth (
  ## Identity Provider (IdP) Settings
  # Default to IdP settings for TestShib
  $idp_entityid = "https://idp.testshib.org/idp/shibboleth",
  $idp_metadata_uri = "http://www.testshib.org/metadata/testshib-providers.xml",
  $idp_metadata_localfile = "testshib-two-idp-metadata.xml",
  ## Service Provider (SP) Settings
  $clock_skew = 180,
  # https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPSessions
  # You should use secure cookies if at all possible
  $sessions_handlerssl = "true",
  $sessions_cookieprops = "https",
  # https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPHandler#NativeSPHandler-SessionHandler
  # You may wish to hide attribute values if you are paranoid
  # although in practice only the given user should be able to see this
  $sessions_handler_show_attribute_values = "true",
  ) {

  # This setting is used elsewhere (e.g. to configure Apache)
  $shibsp_hostname = hiera('shibsp_hostname')

  # This ID is important for uniquely identifying ourselves to the IdP
  $sp_entityid = "https://${shibsp_hostname}/shibboleth"

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
