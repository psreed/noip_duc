# @summary This module managed the NO-IP DUC installation
#
# @example
#   include noip_duc
class noip_duc (
  String $username,
  String $password,
  String $minutes = '30',
  String $interface = 'ens192',
  String $package = 'noip',
  String $conf_file = '/etc/no-ip2.conf',
  String $service_file = '/etc/systemd/system/noip2.service',
  Boolean $update_config = true,
) {

  package { $package: ensure => present, }

#  exec { 'unconfigure':
#TODO: remove configurate to force new config creation when $update_config is set to true.
# This process will need to stop the service and kill any noip2 processes, as the config file will be locked. 
#    command => "rm ${conf_file}"
#     before => Exec['configure'],
#  }

  exec { 'configure':
    creates  => $conf_file,
    command  => "noip2 -C -U ${minutes} -u '${username}' -p '${password}' -I '${interface}'",
    requires => Package[$package],
  }

  file { $service_file:
    ensure  => present,
    content => '# Simple No-ip.com Dynamic DNS Updater
[Unit]
Description=No-ip.com dynamic IP address updater
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target
Alias=noip.service

[Service]
# Start main service
ExecStart=/usr/local/bin/noip2
Restart=always
Type=forking',
    require => Package[$package],
  }

  service { 'noip2':
    ensure  => running,
    enable  => true,
    require => File[$service_file],
  }

}
