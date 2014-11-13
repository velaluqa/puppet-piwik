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
#    path    => "/srv/piwik",
#    user    => "www-data",
#    version => "2.9.0"
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
  $path    = '/srv/piwik',
  $user    = 'www-data',
  $version = 'latest'
) {
  if !defined(Package['unzip']) {
    package { 'unzip': }
  }

  if $version == 'latest' {
    $real_version = 'latest.zip'
  } else {
    $real_version = "piwik-${version}.zip"
  }

  file { $path:
    ensure => 'directory',
    owner  => $user,
  }

  exec { 'piwik-download':
    path    => '/bin:/usr/bin',
    creates => "${path}/index.php",
    command => "bash -c 'cd /tmp; wget http://builds.piwik.org/${real_version}'",
    require => File[$path],
    user    => $user,
  }

  exec { 'piwik-unzip':
    path    => '/bin:/usr/bin',
    creates => "${path}/index.php",
    cwd     => '/tmp',
    command => "bash -c 'unzip -o /tmp/${real_version} \'piwik/*\''",
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

  file { "/tmp/${real_version}":
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
