class ghservice::deps::common {
    include ::apt
    Class['::apt::update'] -> Package <| title != "python-software-properties" and title != "software-properties-common" |>

    package { 'build-essential': ensure => installed }
    package { 'automake': ensure => installed }
    package { 'libssl-dev': ensure => installed }

    include ::ghservice::deps::package::git
}
