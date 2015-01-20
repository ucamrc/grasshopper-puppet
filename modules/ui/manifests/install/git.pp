class ui::install::git ($install_config, $ui_root_dir = '/opt/grasshopper-ui') {
    require ::ghservice::deps::package::git

    $_install_config = merge({
        'source'    => 'https://github.com/CUL-DigitalServices/grasshopper-ui',
        'revision'  => 'master'
    }, $install_config)

    vcsrepo { $ui_root_dir:
        ensure    => latest,
        provider  => git,
        source    => $_install_config['source'],
        revision  => $_install_config['revision'],
    }
}
