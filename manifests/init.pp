# @summary This module managed the NO-IP DUC installation
#
# @example
#   include noip_duc
class noip_duc (
  String $username,
  String $password,
  String $cwd = '/tmp',
  String $package_url = 'http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz',
  String $target_path = '/usr/local/src',
  String $download_path = '/tmp/noip-duc-linux.tar.gz',
  String $binary = '/usr/local/bin/noip2',
  String $tar = '/usr/bin/tar',
  String $wget = '/usr/bin/wget',
) {

  file { $target_path:
    ensure => directory,
  }

  exec { 'install':
    creates => $binary,
    command => "${wget} ${package_url} -O ${download_path}; ${tar} xvf ${download_path} -C ${target_path}",
    require => File[$target_path],
  }

  exec { 'config':
    creates => '/etc/noip.conf',
    command => "${binary} -C",
    require => Exec['install'],
  }
}
