# == Class: kibana::defaults::method_acl
#
# This class exists to provide some default settings that can be merged into
# other hashes within the kibana class.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class kibana::defaults {
  $_ldap_base_dn = hiera('ldap::base_dn')

  $method_acl = {
    'method' => {
      'file' => {
        'enable'    => false,
        'user_file' => '/etc/httpd/conf.d/elasticsearch/.htdigest'
      },
      'ldap'    => {
        'enable'    => false,
        'url'         => hiera('ldap::uri'),
        'security'    => 'STARTTLS',
        'binddn'      => hiera('ldap::bind_dn'),
        'bindpw'      => hiera('ldap::bind_pw'),
        'search'      => "ou=People,${_ldap_base_dn}",
        'posix_group' => true
      }
    },
    'limits'  => {
      'defaults'  => [ 'GET', 'POST', 'PUT' ],
      'hosts'  => {
        '127.0.0.1' => 'defaults',
        "${::fqdn}" => 'defaults'
      }
    }
  }
}
