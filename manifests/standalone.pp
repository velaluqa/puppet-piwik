# Opinionated Standalone installation with nginx, php7.0 and mysql.
# requires modules puppet-nginx and puppetlabs-mysql
# on first access you need to configure the database:
#   Database Server: 127.0.0.1
#   Login:           piwik
#   Password:        <$piwik::standalone::db_password>
#   Database Name:   piwik
class piwik::standalone(
  $piwik               = true,
  $php7                = true,
  $nginx               = true,
  $mysql               = true,
  $mysql_root_password = undef,
  $db_password         = undef,
  $piwik_archive_time  = '/15 * * * *',
  $piwik_php_path      = '/usr/bin/php7.0',
  $mysql_memory        = '2G',
){
  if $piwik {
    class{ 'piwik':
      auto_archive => true,
      archive_time => $piwik_archive_time,
      php_path     => $piwik_php_path,
    }
  }
  if $php7 {
    #php7 fpm
    $php_packages = [
      'php7.0-common',
      'php7.0-mbstring',
      'php7.0-mysql',
      'php7.0-zip',
      'php7.0-xml',
      'php7.0-gd',
      'php7.0-fpm',
      'php-curl',
    ]
    package{$php_packages:
      ensure => installed,
      before => Service['nginx'];
    }
    file_line { 'php-disable-cgi.fix_pathinfo':
      ensure => present,
      path   => '/etc/php/7.0/fpm/php.ini',
      line   => 'cgi.fix_pathinfo=0',
      match  => '^cgi\.fix_pathinfo\=';
    } ~>
    service{'php7.0-fpm':
      ensure    => running,
      enable    => true,
      subscribe => Package[$php_packages];
    }
  }
  if $nginx{
    # nginx
    include nginx
    file {
      '/etc/nginx/conf.d/forwarded_https.conf':
        source => 'puppet:///modules/piwik/nginx_map_forwarded_proto.conf',
        owner  => 'root',
        group  => 0,
        mode   => '0640';
    } ~> Service['nginx']
    nginx::resource::server{ 'default':
      listen_options       => default_server,
      server_name          => ['default'],
      www_root             => '/srv/piwik',
      ipv6_enable          => true,
      use_default_location => false,
      try_files            => ['$uri $uri/ /index.php?$args'],
      locations            => {
        'root'   => {
          location  => '/',
          try_files => ['$uri $uri/ /index.php?$args'],
        },
        'php'    => {
          location            => '~ \.php$',
          try_files           => ['$uri =404'],
          fastcgi             => 'unix:/run/php/php7.0-fpm.sock',
          fastcgi_param       => {
            'SCRIPT_FILENAME' => '$document_root$fastcgi_script_name',
            'HTTPS'           => '$forwarded_https',
          },
          location_cfg_append => {
            fastcgi_connect_timeout => '3m',
            fastcgi_read_timeout    => '3m',
            fastcgi_send_timeout    => '3m',
          },
        },
        'hidden' => {
          location            => '~ /\.',
          location_cfg_append => {
            deny          => 'all',
            access_log    => 'off',
            log_not_found => 'off',
          }
        }
      }
    }
  }
  if $mysql {
    class { 'mysql::server':
      root_password    => $mysql_root_password,
      override_options => {
        mysqld => {
          bind-address                   => '127.0.0.1',
          key-buffer-size                => '32M',
          # SAFETY #
          max-allowed-packet             => '16M',
          max-connect-errors             => '1000000',
          # CACHES AND LIMITS #
          tmp-table-size                 => '32M',
          max-heap-table-size            => '32M',
          query-cache-type               => '0',
          query-cache-size               => '0',
          max-connections                => '500',
          thread-cache-size              => '50',
          open-files-limit               => '65535',
          table-definition-cache         => '4096',
          table-open-cache               => '4096',
          # INNODB #
          innodb-flush-method            => 'O_DIRECT',
          innodb-log-files-in-group      => '2',
          innodb-log-file-size           => '256M',
          innodb-flush-log-at-trx-commit => '2',
          innodb-file-per-table          => '1',
          innodb-buffer-pool-size        => $mysql_memory,
          # LOGGING #
          log-error                      => '/var/lib/mysql/mysql-error.log',
          log-queries-not-using-indexes  => '1',
          slow-query-log                 => '1',
          slow-query-log-file            => '/var/lib/mysql/mysql-slow.log',
        }
      }
    }
    unless $db_password { fail('piwik::standalone::db_password is not defined') }
    mysql::db{'piwik':
      user     => 'piwik',
      host     => '127.0.0.1',
      password => $db_password,
      grant    => 'ALL',
    }
  }
}
