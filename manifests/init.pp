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
  String $service_name = 'noip2',
  Boolean $update_config = true,
  String $systemctl = '/usr/bin/systemctl',
  String $ps = '/usr/bin/ps',
  String $grep = '/usr/bin/grep',
  String $awk = '/usr/bin/awk',
  String $kill = '/usr/bin/kill',
  String $noip2 = '/usr/sbin/noip2',
) {

  package { $package: ensure => present, }

  if ($update_config == true) {
  # Remove configuration to force new config creation when $update_config is set to true.
  # This process will need to stop the service and kill any noip2 processes, as the config file will be locked. 
    exec { 'unconfigure':
      command => "${systemctl} stop ${service_name}; PID=`${ps} ax | ${grep} ${service_name} | ${grep} -v grep | ${awk} '{print \$1}'`; if [ \"\$PID\" != \"\" ]; then ${kill} \$PID; fi; rm -f ${conf_file}", #lint:ignore:140chars
      before  => Exec['configure'],
    }
  }

  exec { 'configure':
    creates => $conf_file,
    command => "${noip2} -C -U ${minutes} -u '${username}' -p '${password}' -I '${interface}'",
    require => Package[$package],
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
