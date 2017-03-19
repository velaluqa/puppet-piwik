# piwik

fork of unmaintained [velaluqa-piwik](https://github.com/velaluqa/puppet-piwik)

A puppet module to easily deploy piwik.

For the main class piwik you have to manage your webserver, db and php separately

For a standalone setup with nginx, php7.0 and mysql use the php::standalone class
or use it as a reference.

## Standalone Setup

1. install puppet modules:
  * [puppet-nginx](https://forge.puppet.com/puppet/nginx)
  * [puppetlabs-mysql](https://forge.puppet.com/puppetlabs/mysql)

2. Include piwik::standalone

```
  class { piwik::standalone:
    db_password => 'somethingsecure',
  }
```

3. Configure Piwik

*Please note:* After the first installation you have to initialize
 piwik by bootstrapping the database. For this use the setup gui in
 your browser according to the piwik installation manual.

```
   Database Server: 127.0.0.1
   Login:           piwik
   Password:        <$piwik::standalone::db_password>
   Database Name:   piwik
```

4. Configure Geolocation

  * Log in to piwik,
  * Go to the Admin Section > Geolocation
  * Setup automatic updates of GeoIP databases (bottom of page)
  * Use the suggested URL
    http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
  * Reload the Geolocation Section
  * Select GeoIP (Php)
  * Save

## Install only piwik

Make sure you have a correct php5 or php7 installation.
This module only downloads the latest piwik archive and extracts it to a
given path.

```
  class { 'piwik':
    path => "/srv/piwik",
    user => "www-data",
  }
```

*Please note:* After the first installation you have to initialize
 piwik by bootstrapping the database. For this use the setup gui in
 your browser according to the piwik installation manual.

## Plugins

### LoginLdap

LoginLdap is a plugin to enable ldap authentication.

Just make sure you have `php-ldap` installed. Either via a puppet
module like `nodes/php` or via the package resource.

Then use:

```
  class { 'piwik::plugins::loginldap': }
```

## Contribute

Want to help - send a pull request.
