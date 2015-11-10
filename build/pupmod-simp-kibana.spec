Summary: Kibana SIMP Puppet Module
Name: pupmod-simp-kibana
Version: 3.0.1
Release: 4
License: Apache License, Version 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: pupmod-apache >= 4.0-13
Requires: pupmod-common >= 4.0.0-1
Requires: pupmod-simplib >= 1.0.0-0
Requires: pupmod-iptables >= 4.0.0-0
Requires: puppet >= 3.3.0
Buildarch: noarch
Requires: simp-bootstrap >= 4.2.0
Obsoletes: pupmod-simp-kibana-test

Prefix: /etc/puppet/environments/simp/modules

%description
This module provides a SIMP compatible version of Kibana 3 ready for use with
the pupmod-simp-elasticsearch and pupmod-simp-logstash packages.

%prep
%setup -q

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/kibana

dirs='files lib manifests templates'
for dir in $dirs; do
  test -d $dir && cp -r $dir %{buildroot}/%{prefix}/kibana
done

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

%files
%defattr(0640,root,puppet,0750)
%{prefix}/kibana

%post
#!/bin/sh

if [ -d %{prefix}/kibana/plugins ]; then
  /bin/mv %{prefix}/kibana/plugins %{prefix}/kibana/plugins.bak
fi

%postun
# Post uninstall stuff

%changelog
* Mon Nov 09 2015 Chris Tessmer <chris.tessmer@onypoint.com> - 3.0.1-4
- migration to simplib and simpcat (lib/ only)

* Mon Mar 2 2015 Ralph Wright <rwright@onyxpoint.com> - 3.0.1-3
- Added Kibana dashboards to go along with the SIMP logstash filters

* Fri Jan 16 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 3.0.1-2
- Changed puppet-server requirement to puppet

* Mon Apr 21 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 3.0.1-1
- Updated global ldap* settings to use hiera settings instead.

* Mon Apr 14 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 3.0.1-1
- Fixed a misconfiguration in the Kibana Apache template that was
  preventing dashboards from being saved.

* Tue Mar 25 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 3.0.1-0
- Update to Kibana 3.0-1
- This requires an update to the latest Elasticsearch

* Wed Feb 12 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 3.0.0-2
- Converted all string booleans to booleans.

* Fri Oct 04 2013 Kendall Moore <kmoore@keywcorp.com> - 3.0.0-1
- Updated all erb templates to properly scope variables.

* Wed Sep 04 2013 Trevor Vaughan <tvaughan@onyxpoint.com> - 3.0.0-0
- First cut at a Kibana 3 module.
