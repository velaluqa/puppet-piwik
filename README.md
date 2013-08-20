# Puppet-piwik

A puppet module to easily deploy piwik. Make sure you have a
correct php5 installation. This module only clones the latest
piwik repository state and creates the correct configuration
file.

You may have to install `php5-fpm` (via puppet-php) and configure your
web server (e.g. puppet-nginx)

## Usage

```
  class { 'piwik':
    path => "/srv/piwik",
    user => "www-data",
  }
```
## Contribute

Want to help - send a pull request.
