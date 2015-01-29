class localconfig::hostnames {

    # FIXME this duplicates code in modules/ghservice/manifests/grasshopper.pp
    $web_domain = hiera('web_domain')
    $app_admin_tenant = hiera('app_admin_tenant', 'admin')
    $admin_domain = "${app_admin_tenant}.${web_domain}"

    # This won't be in DNS so define it locally
    host { $admin_domain: ip => '127.0.0.1' }
}
