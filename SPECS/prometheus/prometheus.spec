%global debug_package %{nil}
Summary:        The Prometheus monitoring system and time series database.
Name:           prometheus
Version:        2.37.0
Release:        1%{?dist}
License:        ASL 2.0
Vendor:         Microsoft Corporation
Distribution:   Mariner
URL:            https://prometheus.io
Source0:        https://github.com/%{name}/%{name}/archive/refs/tags/v%{version}.tar.gz#/%{name}-%{version}.tar.gz
Source1:        %{name}.service
Source2:        %{name}.default
Requires(pre):  shadow-utils
Provides:       prometheus
%{?systemd_requires}
%if 0%{?fedora} >= 19
BuildRequires:  systemd-rpm-macros
%endif

%description

Prometheus is a systems and service monitoring system. It collects metrics from
configured targets at given intervals, evaluates rule expressions, displays the
results, and can trigger alerts if some condition is observed to be true.

%prep
%setup -q

%build
/bin/true

%install
mkdir -vp %{buildroot}%{_sharedstatedir}/prometheus
install -D -m 755 prometheus %{buildroot}%{_bindir}/prometheus
install -D -m 755 promtool %{buildroot}%{_bindir}/promtool
for dir in console_libraries consoles; do
  for file in ${dir}/*; do
    install -D -m 644 ${file} %{buildroot}%{_datarootdir}/prometheus/${file}
  done
done
install -D -m 644 prometheus.yml %{buildroot}%{_sysconfdir}/prometheus/prometheus.yml
install -D -m 644 %{SOURCE1} %{buildroot}%{_unitdir}/prometheus.service
install -D -m 644 %{SOURCE2} %{buildroot}%{_sysconfdir}/default/prometheus

%pre
getent group prometheus >/dev/null || groupadd -r prometheus
getent passwd prometheus >/dev/null || \
  useradd -r -g prometheus -d %{_sharedstatedir}/prometheus -s /sbin/nologin \
          -c "Prometheus services" prometheus
exit 0

%post
%systemd_post prometheus.service

%preun
%systemd_preun prometheus.service

%postun
%systemd_postun prometheus.service

%files
%defattr(-,root,root,-)
%{_bindir}/prometheus
%{_bindir}/promtool
%config(noreplace) %{_sysconfdir}/prometheus/prometheus.yml
%{_datarootdir}/prometheus
%{_unitdir}/prometheus.service
%config(noreplace) %{_sysconfdir}/default/prometheus
%dir %attr(755, prometheus, prometheus)%{_sharedstatedir}/prometheus

%changelog
