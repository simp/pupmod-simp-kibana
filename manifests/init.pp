# This class takes the usual Kibana 3 install and attempts to add some level of
# modular security to it.
#
# One thing that we cannot currently do is restrict Kibana (i.e. the user's web
# browser) to only GET operations. Kibana needs to use POST and, unfortunately,
# ElasticSearch allows for updates via post.
#
# You've been warned...keep your data restricted to only users/groups that you
# trust!
#
# The Kibana package is the one that ships with SIMP. We expect it to install
# into /var/www/html/kibana and be accessed via a kibana sub-url by default.
#
# @param manage_httpd
#     Whether or not to manage the httpd configuration on this system.
#       * true  => Manage the entire web stack.
#       * false => Manage nothing.
#       * conf  => Just drop the configuration file into /etc/httpd/conf.d
#     Set this to 'conf' if something else is manage Apache.
#     Be aware that you'll need to ensure that the system level SSLVerifyClient
#     is set to 'optional' or 'none' so that clients can negotiate higher as
#     necessary.
#
# @param redirect_web_root
#     Whether or not to redirect http://<host>/ to http://<host>/kibana
#
# @param allowroot
#     The hosts to allow into the unencrypted (port 80) Apache root. It is
#     recommended that you do not change this from 127.0.0.1.
#     This has no affect if manage_httpd != true.
#
# @param ssl_allowroot
#     The hosts to allow into the unencrypted (port 80) Apache root. It is
#     recommended that you do not change this from 127.0.0.1.
#     This has no affect if manage_httpd != true.
#
# @param ssl_verify_client
#     Whether or not Apache should verify the client.
#     * If manage_httpd == true this will set the global context to 'none'
#         and the local context to the passed value.
#     * If manage_httpd == 'conf' this will set the local context.
#     * If manage_httpd == false this has no effect.
#
# @param es_proxy
#     The URI to your ElasticSearch host to which Kibana should write.
#     * If manage_httpd == false then this will setup a direct connection to
#       the ES server from your client browser.
#
# @param es_uri
#     The URI that would be added to the config.js file in Kibana. This
#     requires a direct connection to ES if you are not proxying. If proxying,
#     you should highly consider leaving the default value.
#
# @param default_route
#   The default landing page when you don't specify a dashboard to
#   load. Files, scripts, or saved dashboards can be used.
#
#   Examples:
#     - File based dashboard => /dashboard/file/default.json
#     - ES based dashboard   => /dashboard/elasticsearch/MyDashboard
#     - Script               => /dashboard/script/test.js
#
# @param kibana_modules
#     Panel modules to load. In the future these will be inferred from your
#     initial dashboard, though if you share dashboards you will probably need
#     to list them all here
#
# @param method_acl
#     Hash: Users, Groups, and Hosts HTTP operation ACL management.
#
#     Due to the way Kibana 3 works, the DELETE command will be added to the
#     kibana-int space for all entities listed below. This will *not* be
#     present on the main kibana space. The main facility of DELETE is to be
#     able to remove saved Dashboards.
#
#     Keys are the relevant entry to allow and values are an array of
#     operations to allow the key to use.
#
#     These will be deep merged with the kibana::defaults::method_acl hash
#     contents.
#
#     NOTE: These are OR'd together (Satisfy any).
#
#     The example below provides all available options.
#
#     If no value is assigned to the associated key then ['GET','POST','PUT']
#     is assumed.
#
#     Values will be merged with those in elasticsearch::simp::apache::defaults
#     if defined.
#
#     @example Short Example:
#       # Use LDAP but just use the defaults and only allow localhost.
#       {
#         'method' => {
#           'ldap' => {
#             'enable' => true
#           }
#         }
#       }
#
#     @example Full Example:
#       {
#         # 'file' (htpasswd), and 'ldap' support are provided. You will need to
#         # set up target files if using 'file'. The SIMP apache module provides
#         # automated support for this if required.
#         'method' => {
#           # Htpasswd only supports 'file' at this time. If you need more, please
#           # use 'ldap'
#           'file' => {
#             # Don't turn this on.
#             'enable'    => false,
#             'user_file' => '/etc/httpd/conf.d/kibana/.htdigest'
#           }
#           'ldap'    => {
#             'enable'      => true,
#             'url'         => hiera('ldap::uri'),
#             'security'    => 'STARTTLS',
#             'binddn'      => hiera('ldap::bind_dn'),
#             'bindpw'      => hiera('ldap::bind_pw'),
#             'search'      => inline_template('ou=People,<%= scope.function_hiera(["ldap::base_dn"]) %>'),
#             # Whether or not your LDAP groups are POSIX groups.
#             'posix_group' => true
#           }
#         },
#         'limits' => {
#           # Set the defaults
#           # These defaults are what you need to read from kibana.
#           'defaults' => [ 'GET', 'POST', 'PUT' ],
#           'hosts'  => {
#             '1.2.3.4'     => 'defaults',
#             '3.4.5.6'     => 'defaults',
#             '10.1.2.0/24' => 'defaults'
#           },
#           # You can make a special user 'valid-user' that will translate to
#           # allowing all valid users.
#           'users'  => {
#             # Allow user bob to access kibana.
#             'bob'     => 'defaults',
#           },
#           'ldap_groups' => {
#             # Let the nice users access kibana.
#             "cn=nice_users,ou=Group,${::basedn}" => 'defaults'
#           }
#         }
#       }
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
class kibana (
  Variant[Boolean,Enum['conf']]     $manage_httpd      = true,
  Boolean                           $redirect_web_root = false,
  Simplib::Netlist                  $allowroot         = ['127.0.0.1'],
  Simplib::Netlist                  $ssl_allowroot     = simplib::lookup('simp_options::trusted_nets', {'default_value' => ['127.0.0.1/32'] }),
  Enum['none','optional','require'] $ssl_verify_client = 'none',
  Simplib::Uri                      $es_proxy          = 'http://127.0.0.1:9199',
  String                            $es_uri            = 'es',
  String                            $default_route     = '/dashboard/file/default.json',
  Array[String]                     $kibana_modules    = [
    'bettermap',
    'column',
    'dashcontrol',
    'derivequeries',
    'fields',
    'filtering',
    'histogram',
    'hits',
    'map',
    'pie',
    'query',
    'table',
    'terms',
    'text',
    'timepicker',
    'trends'
  ],
  Hash                              $method_acl        = {}
) {

  package { 'kibana': ensure => 'latest' }

  file { '/var/www/html/kibana/config.js':
    ensure  => 'file',
    owner   => 'root',
    group   => 'apache',
    mode    => '0640',
    content => template('kibana/var/www/html/kibana/config.js.erb'),
    require => Package['kibana']
  }

  if $manage_httpd and ( $manage_httpd != 'conf' ) {
    include '::simp_apache::conf'
    include '::simp_apache::ssl'
  }

  if ( $manage_httpd == 'conf' ) or $manage_httpd {
    include '::kibana::defaults'
    include '::simp_apache::validate'

    $l_method_acl = deep_merge($::kibana::defaults::method_acl, $method_acl)
    validate_deep_hash($::simp_apache::validate::method_acl, $l_method_acl)

    $httpd_includes = '/etc/httpd/conf.d/kibana'

    simp_apache::site { 'kibana':
      content => template('kibana/etc/httpd/conf.d/kibana.conf.erb')
    }

    file { $httpd_includes:
      ensure  => 'directory',
      owner   => 'root',
      group   => 'apache',
      mode    => '0640',
      require => Package['httpd']
    }

    # This is just so that we can wildcard.
    file { [
      "${httpd_includes}/auth",
      "${httpd_includes}/limit",
      "${httpd_includes}/limit_int",
    ]:
      ensure => 'directory',
      owner  => 'root',
      group  => 'apache',
      mode   => '0640'
    }

    $l_apache_auth = apache_auth($l_method_acl['method'])

    if $l_apache_auth != '' {
      file { "${httpd_includes}/auth/auth.conf":
        ensure  => 'file',
        owner   => 'root',
        group   => 'apache',
        mode    => '0640',
        content => "${l_apache_auth}\n",
        notify  => Service['httpd']
      }
    }

    # This is for the main limits (not the kibana-int space)
    $l_apache_limits = apache_limits($l_method_acl['limits'])

    $_limits_content = $l_apache_limits ? {
      # Set some sane defaults.
      ''      => "<Limit GET POST PUT>
          Order deny,allow
          Deny from all
          Allow from 127.0.0.1
          Allow from ${::fqdn}
        </Limit>",
      default => "${l_apache_limits}\n"
      }

    file { "${httpd_includes}/limit/limits.conf":
      ensure  => 'file',
      owner   => 'root',
      group   => 'apache',
      mode    => '0640',
      content => $_limits_content,
      notify  => Service['httpd']
    }

    # This is for kibana-int
    $l_apache_limits_int = apache_limits(deep_merge(
      $l_method_acl['limits'],
      {
        'defaults' => array_union($l_method_acl['limits']['defaults'],['DELETE'])
      }))

    $_limits_int_content = $l_apache_limits_int ? {
      # Set some sane defaults.
      ''      => "<Limit GET POST PUT DELETE>
          Order deny,allow
          Deny from all
          Allow from 127.0.0.1
          Allow from ${::fqdn}
        </Limit>",
      default => "${l_apache_limits_int}\n"
    }

    file { "${httpd_includes}/limit_int/limits.conf":
      ensure  => 'file',
      owner   => 'root',
      group   => 'apache',
      mode    => '0640',
      content => $_limits_int_content,
      notify  => Service['httpd']
    }
  }
}
