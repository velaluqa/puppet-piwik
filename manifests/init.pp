# == Class: piwik
#
# === Parameters
#
# [path] The path were piwik should be installed to (default: /srv/piwik)
# [user] The piwik user (default: www-data)
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
class piwik (
  $path = '/srv/piwik',
  $user = 'www-data',
) {
  if !defined(Package['unzip']) {
    package { 'unzip': }
  }

  file { $path:
    ensure => 'directory',
    owner  => $user,
  }

  exec { 'piwik-download':
    path    => '/bin:/usr/bin',
    creates => "${path}/index.php",
    command => "bash -c 'cd /tmp; wget http://builds.piwik.org/latest.zip'",
    require => File[$path],
    user    => $user,
  }

  exec { 'piwik-unzip':
    path    => '/bin:/usr/bin',
    creates => "${path}/index.php",
    command => "bash -c 'unzip -o /tmp/latest.zip \'piwik/*\''",
    require => [ Exec['piwik-download'], Package['unzip'] ],
    user    => $user,
  }

  exec { 'piwik-copy':
    path    => '/bin:/usr/bin',
    creates => "${path}/index.php",
    command => "bash -c 'cp -rf /tmp/piwik/* ${path}/'",
    require => Exec['piwik-unzip'],
    user    => $user,
  }

  file { '/tmp/latest.zip':
    ensure  => absent,
    require => Exec['piwik-copy'],
  }

  file { '/tmp/piwik':
    ensure  => absent,
    recurse => true,
    force   => true,
    require => Exec['piwik-copy'],
  }
} # Class:: piwik
