# This class adds SIMP dashboards to the Kibana web directory
#
# @author Ralph Wright <rwright@onyxpoint.com>
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
class kibana::dashboards {
  file {'/var/www/html/kibana/app/dashboards':
    ensure  => file,
    owner   => 'root',
    group   => 'apache',
    mode    => '0644',
    recurse => true,
    source  => 'puppet:///modules/kibana/dashboards',
  }
}
