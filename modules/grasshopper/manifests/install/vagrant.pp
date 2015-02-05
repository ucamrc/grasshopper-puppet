class grasshopper::install::vagrant ($install_config, $app_root_dir = '/opt/grasshopper') {
    require ::ghservice::deps::nodejs

    # Install node packages
    exec { "npm_install_dependencies":
        cwd         => $app_root_dir,
        command     => 'npm install --production',
        logoutput   => 'on_failure',
    }
}
