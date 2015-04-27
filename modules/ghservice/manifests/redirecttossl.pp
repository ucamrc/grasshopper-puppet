define ghservice::redirecttossl (
    $servername,
    $priority = 90,
    $docroot = '/var/www',
    $logroot = '/var/log/apache2',
    ) {

    apache::vhost { $title:
        priority        => $priority,
        vhost_name      => '*',
        port            => 80,
        servername      => $servername,
        docroot         => $docroot,
        directories     => [
            { 'path'      => '/',
              'require'   => 'all denied',
            }
        ],
        # In this case we are happy to let the module generate the entire file
        # from the parameters here, so there is no need for our own template
        logroot         => "${logroot}",
        error_log       => true,
        error_log_file  => "logs${$title}_error.log",
        access_log      => true,
        access_log_file => "logs${$title}_custom.log",
        custom_fragment => "RedirectMatch Permanent (.*) https://${servername}\$1",
    }

}
