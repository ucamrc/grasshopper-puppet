class ghservice::ui {

    # Apply the UI class.
    class { '::ui':
        ui_root_dir     => hiera('ui_root_dir'),
        install_method  => hiera('ui_install_method', 'git'),
        install_config  => hiera('ui_install_config', {
            'source' => 'https://github.com/CUL-DigitalServices/grasshoppper-ui',
            'revision' => 'master'
        })
    }
}
