# Shibboleth setup in grasshopper-puppet

## Background Info

* [Shibboleth](https://wiki.shibboleth.net/confluence/display/SHIB2/Home) Single Sign-On

## Pre-requisites

Please ensure that you have read the following documents first:

* [README.md](README.md) - General Grasshopper setup
* [README-ssl.md](README-ssl.md) - SSL (https) setup
  * N.B. Shibboleth support in Grasshopper currently mandates using https
* Grasshopper's Shibboleth [README.md](https://github.com/CUL-DigitalServices/grasshopper/blob/master/etc/apache/README.md)
  * As Grasshopper is a multi-tenant application, its support for Shibboleth is
    not entirely standard

## Configuration

To enable Shibboleth support in puppet scripts, include the following in your
`environments/[env name]/hiera/common.json` file:

`  "enable_shib": "true"`

