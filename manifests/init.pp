# == Class: piwik
#
# === Parameters
#
# [path] The path were piwik should be installed to (default: /srv/piwik)
# [user] The user who should be owner of that directory and as which piwik is run (default: www-data)
# [db_name] The database for piwik (default: piwikdb)
# [db_user] The database user for piwik (default: piwik)
# [db_host] The database host for piwik (default: localhost)
# [db_password] The database password for piwik (default: something weird. Make sure to change that.)
#
# === Examples
#
#  class { 'piwik':
#    path => "/srv/piwik",
#    user => "www-data",
#  }
#
# === Authors
#
# Arthur Leonard Andersen <leoc.git@gmail.com>
#
# === Copyright
#
# See LICENSE file, Arthur Leonard Andersen (c) 2013
#
# Class:: piwik
#
class piwik(
  $path        = "/srv/piwik",
  $user        = "www-data",
) {
  if !defined(Package['unzip']) {
    package { 'unzip': }
  }

  file { $path:
    ensure => "directory",
    owner => $user,
  }

  exec { "piwik-download":
    path => "/bin:/usr/bin",
    creates => "${path}/index.php",
    command => "bash -c 'cd /tmp; wget http://builds.piwik.org/latest.zip'",
    require => File[$path],
    user => $user,
  }

  exec { "piwik-unzip":
    path => "/bin:/usr/bin",
    creates => "${path}/index.php",
    command => "bash -c 'unzip -o /tmp/latest.zip \'piwik/*\''",
    require => [ Exec['piwik-download'], Package['unzip'] ],
    user => $user,
  }

  exec { "piwik-copy":
    path => "/bin:/usr/bin",
    creates => "${path}/index.php",
    command => "bash -c 'cp -rf /tmp/piwik/* ${path}/'",
    require => Exec['piwik-unzip'],
    user => $user,
  }

  file { "/tmp/latest.zip":
    ensure => absent,
    require => Exec['piwik-copy'],
  }

  file { '/tmp/piwik':
    ensure => absent,
    recurse => true,
    force => true,
    require => Exec['piwik-copy'],
  }
} # Class:: piwik
