class ghservice::postgresql (
        $db = 'grasshopper',
        $user = 'grasshopper',
        $password = 'grasshopper',
    ) {

    class { 'postgresql::server': }

    postgresql::server::db { "$db":
        user     => "$user",
        password => postgresql_password("$user", "$password"),
    }
}
