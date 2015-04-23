# SSL (https) setup for Grasshopper

For the sake of simplicity, by default the puppet scripts will provision a
server without SSL support, i.e. only plain HTTP.

## Configuration

To enable SSL, add the following to your `environments/[env name]/hiera/common.json`
file:

`"ghservice::apache::enable_ssl": "true",`

By default, the location for SSL keys and certificates is assumed to be
`/etc/apache2/ssl`. You can override this using `ghservice::apache::ssl_dir`.

Private key files are assumed to have an extension of `.key` and certificates
of `.crt`.

These scripts assume that there will be two or three hosts, each with its own
key and certificate files:

* Tenant - `tenant.*`
* Global Admin - `admin.*`
* Shibboleth SP (optional) - `shibsp.*`

So for instance, the default for the Tenant SSL certificate file is:
`/etc/apache2/ssl/tenant.crt`.

The scripts can autogenerate self-signed SSL certificates for testing purposes,
to enable this, use:

`"ghservice::apache::self_signed_ssl": "true",`

## Usage

Once you provision the server with `enable_ssl` = `true`, the server will
be configured to listen on BOTH http (port 80) and https (port 443); this applies
to all the hosts. For convenience, the Apache configuration for the http server
simply redirects to the equivalent URL on https. Note that in a multi-tenant
situation, this will not work out-of-the-box, since these scripts only provide
partial support for more than one tenant; the redirect will go to the tenant
hostname specified in the configuration file.

