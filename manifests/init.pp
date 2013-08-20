# == Class: piwik
#
# === Parameters
#
# TODO: Add parameters
#
# === Examples
#
# TODO: Add examples
#
# === Authors
#
# Arthur Leonard Andersen <leoc.git@gmail.com>
#
# === Copyright
#
# See LICENSE file, Arthur Leonard Andersen (c) 2013

# Class:: piwik
#
#
class piwik (
  $path = "/srv/piwik",
  $user = "www-data",
  $db_name = 'piwikdb',
  $db_user = 'piwik',
  $db_host = 'localhost',
  $db_password = '1/&DF/V2g)(?%§'
) {
  file { $path:
    ensure => "directory",
    owner => $user,
  }

  mysql::db { $db_name:
    user => $db_user,
    password => $db_password,
    host => $db_host,
  }

  exec { "piwik-download":
    path => "/bin:/usr/bin",
    creates => "$path/.git",
    command => "bash -c 'cd /tmp; wget http://builds.piwik.org/latest.zip; unzip -o /tmp/latest.zip \'piwik/*\'; cp -rf /tmp/piwik/* ${path}/'",
    require => File[$path],
    user => $user,
  }

  # file { "piwik-conf":
  #   path => "$path/conf/config.inc.php",
  #   content => template("piwik/config.inc.php.erb"),
  #   owner => $user,
  #   require => Exec["piwik-upgrade"],
  # }
} # Class:: piwik
