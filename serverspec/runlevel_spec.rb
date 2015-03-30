require 'spec_helper'

describe command('who -r') do
  its(:stdout) { should match /run-level 3 / }
end

# ----- ON -----
on = [ 'altiris', 
       'atd',
       'auditd',
       'crond',
       'kdump',
       'messagebus',
       'netfs',
       'network',
       'nfslock',
       'ntpd',
       'opsview-agent',
       'restorecond',
       'rpcbind',
       'rpcidmapd',
       'sshd',
       'rsyslog',
       'xinetd' ]
if ! Isdmz
  on.push('autofs')
  on.push('nscd')
  on.push('postfix')
end
if Isvmware
  on.push('vmware-tools')
end
if Isphys
  on.push('cpuspeed')
  on.push('irqbalance')
end
on.each do |i|
  describe service(i) do
    it { should be_enabled.with_level(3) }
    it { should be_running }
  end
end

onnorun = [ 'lvm2-monitor',
            'rpcgssd',
            'sysstat' ]
onnorun.each do |i|
  describe service(i) do
    it { should be_enabled.with_level(3) }
  end
end


# ----- OFF -----

off = [ 'acpid',
        'cups',
        'gdm',
        'haldaemon',
        'ip6tables',
        'iscsi',
        'mdmonitor',
        'netconsole',
        'nfs',
        'psacct',
        'rdisc',
        'rpcsvcgssd',
        'saslauthd',
        'xfs' ]
if Isdmz
  off.push('autofs')
  off.push('sssd')
  off.push('sendmail')
  off.push('postfix')
  # nscd's init script sucks.
  describe command('pgrep -x nscd') do
    its(:exit_status) { should eq 1 }
  end
end
if Isvirt
  off.push('cpuspeed')
  off.push('irqbalance')
end
if Isvbox || Isphys
  off.push('vmware-tools')
end
off.each do |i|
  describe service(i) do
    it { should_not be_enabled.with_level(3) }
    it { should_not be_running }
  end
end

offnorun = [ 'iptables' ]
offnorun.each do |i|
  describe service(i) do
    it { should_not be_enabled.with_level(3) }
  end
end
