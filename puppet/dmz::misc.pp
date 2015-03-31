class dmz::build_misc {
  # For DMZ hosts, add the vco user to the template - the boot script will remove it.
  user { 'vco':
    ensure           => present,
    password         => $dmz::vco_passwd,
    max_password_age => -1,
    expiry           => absent,
    forcelocal       => true,
  }
  augeas { 'ins-vco-access':
    context => '/files/etc/security/access.conf',
    changes => ['ins tempalias before access[1]',
                'rm access[*]/user[. = "vco"]/..',
                'ins access before tempalias',
                'set access[1] +',
                'set access[1]/user vco',
                'set access[1]/origin ALL',
                'rm tempalias' ],
    onlyif  => 'match access size > 0',
    # what a pain in the balls.
  }
  augeas { 'add-vco-access':
    context => '/files/etc/security/access.conf',
    changes => ['set access[1] +',
                'set access[1]/user vco',
                'set access[1]/origin ALL' ],
    onlyif  => 'match access size == 0',
  }

  # Slap in a minimal first run script
  file { '/etc/init.d/zDMZFirstBoot':
    ensure => present,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/dmz/FirstBoot',
  }

  file { '/etc/rc3.d/S99zDMZFirstBoot':
    ensure => 'link',
    target => '/etc/init.d/zDMZFirstBoot',
  }
}
