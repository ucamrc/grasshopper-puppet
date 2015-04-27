define ghservice::selfsignedcert (
    $certdir = $ghservice::apache::ssl_dir,
    $basename = "tmp",
    $cert_cn = $title,
    $expiredays = "90",
    ) {

    include ::ghservice::deps::package::openssl

    $keyfile = "${certdir}/${basename}.key"
    $csrfile = "${certdir}/${basename}.csr"
    $certfile = "${certdir}/${basename}.crt"

    $issuer_prefix = "/C=GB/ST=Cambridgeshire/L=Cambridge/O=TEMPORARY CERTIFICATE for TESTING only"

    # Generate Key
    # WARNING: deliberately not encrypted, so that Apache can (re)start without prompting for a pass-phrase
    exec { "openssl genrsa -out ${keyfile} 1024":
      require => [Package['openssl'], File[$certdir]],
      creates => "${certfile}",
    }
    ->
    # Create Certificate Signing Request
    exec { "openssl req -new -key ${keyfile} -subj \"${issuer_prefix}/CN=${cert_cn}/\" -out ${csrfile}":
      creates => "${certfile}",
    }
    ->
    # Create Certificate and Delete Certificate Signing Request
    exec { "openssl x509 -in ${csrfile} -out ${certfile} -req -signkey ${keyfile} -days ${expiredays} && rm ${csrfile}":
      creates => "${certfile}",
      notify  => Service['httpd'],
    }
    ->
    # Set appropriate file permissions and ownership
    file { "${keyfile}":
      owner  => "root",
      group  => "root",
      mode   => "0400",
      ensure => "file",
    }
    ->
    file { "${certfile}":
      owner  => "root",
      group  => "root",
      mode   => "0400",
      ensure => "file",
    }
}
