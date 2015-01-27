class ghservice::postgresql (
        $db = 'grasshopper',
        $user = 'grasshopper',
        $password = 'grasshopper',
    ) {

    class { 'postgresql::server': }

    class { 'postgresql::server::contrib': }

    postgresql::server::db { "$db":
        user     => "$user",
        password => postgresql_password("$user", "$password"),
    } ->
    exec { 'enable pg_trgm':
        # Not sure if postgres module supports this natively?
        # Perhaps this should be done in the code itself?
        command => "sudo -u postgres psql grasshopper -c 'CREATE EXTENSION IF NOT EXISTS pg_trgm'"
    }
}
