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
        # We prefer to control the rest of the file ourselves
        # so stop the module from generating other stuff
        logroot         => "${logroot}",
        error_log       => true,
        error_log_file  => "logs${$title}-redirect_error.log",
        access_log      => true,
        access_log_file => "logs${$title}-redirect_custom.log",
        custom_fragment => "RedirectMatch Permanent (.*) https://${servername}\$1",
    }

}
