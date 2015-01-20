class ghservice::grasshopper {
    include ::ghservice::deps::common
    include ::ghservice::deps::nodejs
    include ::ghservice::ui

    Class['::ghservice::deps::common']  -> Class['::grasshopper']
    Class['::ghservice::deps::nodejs']  -> Class['::grasshopper']
    Class['::ui']                       -> Class['::grasshopper']

    $install_method = hiera('app_install_method', 'git')
    $install_config = hiera('app_install_config', {
        source => 'https://github.com/CUL-DigitalServices/grasshopper',
        revision => 'master'
    })

    $web_domain = hiera('web_domain')
    $app_admin_tenant = hiera('app_admin_tenant', 'admin')
    $admin_domain = "${app_admin_tenant}.${web_domain}"

    class { '::grasshopper':
        app_root_dir                  => hiera('app_root_dir'),

        install_method                => $install_method,
        install_config                => $install_config,

        os_user                       => hiera('app_os_user'),
        os_group                      => hiera('app_os_group'),

        config_cookie_secret          => hiera('app_cookie_secret'),
        config_servers_admin_host     => $admin_domain,
        config_ui_path                => hiera('app_ui_path', '/opt/grasshopper-ui')
    }
}
