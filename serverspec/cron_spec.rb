require 'spec_helper'

describe file('/etc/at.deny') do
  it { should_not be_directory }
  it { should_not be_file }
  it { should_not be_socket }
  it { should_not be_symlink }
end

describe file('/etc/cron.deny') do
  it { should_not be_directory }
  it { should_not be_file }
  it { should_not be_socket }
  it { should_not be_symlink }
end

describe file('/etc/at.allow') do
  it { should be_file }
  it { should be_mode 400 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:md5sum) { should eq '74cc1c60799e0a786ac7094b532f01b1' }
               # 'root' =  '74cc1c60799e0a786ac7094b532f01b1'
end

describe file('/etc/cron.allow') do
  it { should be_file }
  it { should be_mode 400 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:md5sum) { should eq '732d5c9e8ad3b562023a2fb28c079616' }
               # 'root\nvera' = 732d5c9e8ad3b562023a2fb28c079616
end

describe file('/etc/crontab') do
  it { should be_file }
  it { should be_mode 400 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/etc/anacrontab') do
  it { should be_file }
  it { should be_mode 400 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

crondirs = [ '/etc/cron.d',
             '/etc/cron.hourly',
             '/etc/cron.daily',
             '/etc/cron.weekly',
             '/etc/cron.monthly' ]
crondirs.each do |i|
  describe file(i) do
    it { should be_directory }
    it { should be_mode 700 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end

cronfiles = [ '/etc/cron.d/0hourly',
              '/etc/cron.d/raid-check',
              '/etc/cron.d/sysstat' ]
cronfiles.each do |i|
  describe file(i) do
    it { should be_file }
    it { should be_mode 600 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end

execronfiles = [ '/etc/cron.daily/logrotate',
                 '/etc/cron.daily/rhsmd',
                 '/etc/cron.daily/makewhatis.cron',
                 '/etc/cron.hourly/0anacron' ]
execronfiles.each do |i|
  describe file(i) do
    it { should be_file }
    it { should be_mode 700 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end

describe file('/var/spool/cron') do
  it { should be_directory }
  it { should be_mode 700 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe command('find /var/spool/cron/* -exec ls -ld {} \; | grep -v -- \'-rw-------. [0-9]* root root\' | wc -l') do
  its(:stdout) { should eq "0\n" }
end
