class piwik::plugins::loginldap (
  $package_url = 'https://piwik-ldap.googlecode.com/files/LoginLdap-1.3.5.zip'
) {
  $user = $piwik::user
  $path = $piwik::path

  if !defined(Package['unzip']) {
    package { 'unzip': }
  }

  exec { "piwik-plugin-loginldap-download":
    path => "/bin:/usr/bin",
    creates => "/tmp/loginldap.zip",
    command => "bash -c 'wget --no-check-certificate -O/tmp/loginldap.zip ${package_url}'",
    user => $user,
    require => Class['piwik'],
  }

  exec { "piwik-plugin-loginldap-extract":
    path => "/bin:/usr/bin",
    creates => "${path}/plugins/LoginLdap",
    command => "bash -c 'unzip /tmp/loginldap.zip -d${path}/plugins/'",
    user => $user,
    require => [ Class['piwik'], Exec['piwik-plugin-loginldap-download'], Package['unzip'] ],
  }

  file { "/tmp/loginldap.zip":
    ensure => absent,
    require => Exec['piwik-plugin-loginldap-extract'],
  }
}
