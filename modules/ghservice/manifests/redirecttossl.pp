define ghservice::redirecttossl (
    $servername,
    $priority = 90,
    $docroot = '/var/www',
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
# FIXME put logging in since no actual template
        error_log       => false,
        access_log      => false,
        custom_fragment => "RedirectMatch Permanent (.*) https://${servername}\$1",
    }

}
