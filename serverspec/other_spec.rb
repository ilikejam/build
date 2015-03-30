require 'spec_helper'

describe file('/tftpboot') do
  it { should_not be_directory }
  it { should_not be_file }
  it { should_not be_socket }
  it { should_not be_symlink }
end

describe file('/var/log/samba') do
  it { should_not be_file }
  it { should_not be_directory }
  it { should_not be_socket }
  it { should_not be_symlink }
end

describe file('/root') do
  it { should be_directory }
  it { should be_mode 700 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

rootshellrc = [ '/root/.bash_profile',
                '/root/.bashrc',
                '/root/.cshrc',
                '/root/.tcshrc',
                '/root/.profile' ]
rootshellrc.each do |i|
  describe file(i) do
    it { should be_file }
    it { should be_mode 400 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end

describe package('sudo') do
  it { should be_installed }
end

compilers = [ 'gcc',
              'clang',
              'g++',
              'cc',
              'gas',
              'nasm' ]
compilers.each do |i|
  describe package(i) do
    it { should_not be_installed }
  end
end

describe command('find /usr/share/doc -exec ls -ld {} \; | egrep \'^[^l](....w|.......w)\' | wc -l') do
  its(:stdout) { should eq "0\n" }
end

describe command('find /usr/share/man -exec ls -ld {} \; | egrep \'^[^l](....w|.......w)\' | wc -l') do
  its(:stdout) { should eq "0\n" }
end
