require 'spec_helper'

describe 'kibana' do

  let(:facts) {{
    :operatingsystem => 'RedHat',
    :lsbmajdistrelease => '7',
    :selinux_current_mode => 'enabled',
    :fqdn => 'test.host.net',
    :hardwaremodel => 'x86_64',
    :operatingsystem => 'RedHat',
    :apache_version => '2.4',
    :grub_version => '0.9',
    :uid_min => '500',
    :interfaces => 'lo',
    :ipaddress_lo => '127.0.0.1',
  }}
  it { should create_class('kibana') }
  it { should compile.with_all_deps }
end
