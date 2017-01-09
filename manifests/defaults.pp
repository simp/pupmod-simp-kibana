# This class exists to provide some default settings that can be merged into
# other hashes within the kibana class.
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
class kibana::defaults {
  $_ldap_base_dn = hiera('simp_options::ldap::base_dn')

  $method_acl = {
    'method' => {
      'file' => {
        'enable'    => false,
        'user_file' => '/etc/httpd/conf.d/elasticsearch/.htdigest'
      },
      'ldap'    => {
        'enable'    => false,
        'url'         => hiera('simp_options::ldap::uri'),
        'security'    => 'STARTTLS',
        'binddn'      => hiera('simp_options::ldap::bind_dn'),
        'bindpw'      => hiera('simp_options::ldap::bind_pw'),
        'search'      => "ou=People,${_ldap_base_dn}",
        'posix_group' => true
      }
    },
    'limits'  => {
      'defaults'  => [ 'GET', 'POST', 'PUT' ],
      'hosts'  => {
        '127.0.0.1' => 'defaults',
        "${facts['fqdn']}" => 'defaults'
      }
    }
  }
}
