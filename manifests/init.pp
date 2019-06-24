# @summary This module managed the NO-IP DUC installation
#
# @example
#   include noip_duc
class noip_duc (
  String $username,
  String $password,
  String $package_rpm = 'noip',
) {

  package { $package_rpm: ensure => present, }

}
