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
        command => "sudo -u postgres psql grasshopper -c 'CREATE EXTENSION IF NOT EXISTS pg_trgm'"
    }
}
