class grasshopper::install::git ($install_config, $app_root_dir = '/opt/grasshopper') {
    require ::ghservice::deps::package::git

    $_install_config = merge({
        'source'    => 'https://github.com/CUL-DigitalServices/grasshopper',
        'revision'  => 'master'
    }, $install_config)

    # Clone the repository
    vcsrepo { $app_root_dir:
        ensure    => latest,
        provider  => git,
        source    => $_install_config['source'],
        revision  => $_install_config['revision'],
        notify    => Service['grasshopper'],
    } ->

    # We need to chmod the directory before we can do an npm install
    file { $app_root_dir:
        ensure  => directory,
        mode    => "0644",
        owner   => $os_user,
        group   => $os_group,
    } ->

    # Install node packages
    exec { "npm_install_dependencies":
        cwd         => $app_root_dir,
        command     => 'npm install --production',
        logoutput   => 'on_failure',
    } ->

    # chown the application root to the app user again
    exec { 'app_root_dir_chown':
        cwd         => $app_root_dir,
        command     => "chown -R $os_user:$os_group .",
        logoutput   => "on_failure",
    }
}
