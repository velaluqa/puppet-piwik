# Puppet-phppgadmin

A puppet module to easily deploy phppgadmin. Make sure you have a
correct php5 installation. This module only clones the latest
phppgadmin repository state and creates the correct configuration
file.

You may have to install `php5-fpm` (via puppet-php) and configure your
web server (e.g. puppet-nginx)

## Usage

```
  class { 'phppgadmin':
    path => "/srv/phppgadmin",
    user => "www-data",
    servers => [
      {
        desc => "local",
        host => "127.0.0.1",
      },
      {
        desc => "other",
        host => "192.168.1.30",
      }
    ]
  }
```
## Contribute

Want to help - send a pull request.
