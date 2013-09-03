# Puppet-piwik

A puppet module to easily deploy piwik. Make sure you have a
correct php5 installation. This module only clones the latest
piwik repository state and creates the correct configuration
file.

You may have to install `php5-fpm` (via puppet-php) and configure your
web server (e.g. puppet-nginx)

## Suggested Preparation

This module is as simple as possible. You should be able to choose
your own php installation. This is my own, which works quite find, as
I find:

1. First I install the
   [nodes/php](https://forge.puppetlabs.com/nodes/php) module.

```
puppet module install nodes/php
```

2. Using this module I install the necessary php packages. For serving
   php I use php-fpm with nginx.

```
class { 'php::extension::mysql': } # if you use mysql
class { 'php::extension::pgsql': } # if you use postgresql
class { 'php::extension::mcrypt': }
class { 'php::extension::gd': }
class { 'php::fpm::daemon':
  ensure => running
}
```

3. Then I install piwik. See [[Usage]].

4. At last you may set up your vhost. This is depending on the server
   module you are using.

## Usage

```
  class { 'piwik':
    path => "/srv/piwik",
    user => "www-data",
  }
```

*Please note:* After the first installation you have to initialize
 piwik by bootstrapping the database.

## Contribute

Want to help - send a pull request.
