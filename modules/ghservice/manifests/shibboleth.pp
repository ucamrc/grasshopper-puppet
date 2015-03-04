class ghservice::shibboleth {

  $shibsp_hostname = hiera('shibsp_hostname')


  # Reduce this in production!
  $clock_skew = 1800

  ## POSSIBLY OVERRIDE THIS??
  $sp_entityid = "https://${shibsp_hostname}/shibboleth"


  # May want to review this in production
  $session_handler_show_attribute_values = "true"

  # IdP settings
  $idp_entityid = "https://idp.testshib.org/idp/shibboleth"
  $idp_metadata_uri = "http://www.testshib.org/metadata/testshib-providers.xml"
  $idp_metadata_localfile = "testshib-two-idp-metadata.xml"

  file { '/etc/shibboleth/shibboleth2.xml':
    content => template('ghservice/shibboleth/shibboleth2.xml.erb'),
  } ~>

  service { 'shibd':
    ensure   => running,
    provider => 'upstart',
    notify   => Service['apache2'],
  }

}
