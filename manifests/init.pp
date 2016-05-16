# == Class: piwik
#
# === Parameters
#
# [path] The path were piwik should be installed to (default: /srv/piwik)
# [user] The piwik user (default: www-data)
# [version] The piwik version to install (default: latest)
# [auto_archive] Enable Cronjob to archive reports (default: false)
# [archive_time] Cronjob time parameter (default: '5 * * * *')
# [archive_url] Url of piwik instllation for archive job (default: 'http://localhost/')
# [archive_log] Archive Log file (default: /var/log/piwik-archive.log')
# [php_path] Path to php executable, (default: '/usr/bin/php5')
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
  $path         = '/srv/piwik',
  $user         = 'www-data',
  $version      = 'latest',
  $auto_archive = false,
  $archive_time = '5 * * * *', # hourly
  $archive_url  = 'http://localhost/',
  $archive_log  = '/var/log/piwik-archive.log',
  $php_path     = '/usr/bin/php5',
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

  if $auto_archive {
    file{
      '/etc/cron.d/piwik-archive':
        content => "${archive_time} ${user} ${php_path} ${path}/console core:archive --url=${archive_url} >> ${archive_log}\n",
        owner   => $user,
        group   => 0,
        mode    => '0644';
      $archive_log:
        ensure  => file,
        owner   => $user,
        group   => 0,
        mode    => '0640';
    }
  }
} # Class:: piwik
