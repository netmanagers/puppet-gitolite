# = Class: gitolite
#
# This class installs and configures gitolite3.
#
# == Parameters
#
# admin_username::  The posix username of the administrator account.
# admin_sshkey::    Absolute path to administrator's private ssh key.
# manage_repos::    Manage repositories through this module only.
#                   Defaults to true.
# manage_keys::     Manage ssh keys through this module only. Defaults to true.
# local_keys::      Don't purge unmanaged ssh keys. Defaults to false.
# package_version:: Manage gitolite3 package version. Defaults to 'installed'.
#
# == Examples
#
# This is how to set up gitolite3 and manage it from puppet.
#
#  class {'gitolite':
#    admin_username => 'root',
#    admin_sshkey   => '/root/.ssh/id_rsa'
#  }
#
# This is how to set up gitolite3 without managing repositories or keys.
#
#  class {'gitolite':
#    admin_username => 'redmine',
#    admin_sshkey   => '/usr/share/redmine/.ssh/id_rsa',
#    manage_repos   => false,
#    manage_keys    => false
#  }
#
class gitolite
(
  $admin_username,
  $admin_sshkey,
  $manage_repos = true,
  $manage_keys = true,
  $local_keys = false,
  $package_version = 'installed'
)
{
  # resource defaults
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644'
  }

  # validate parameters
  validate_string($admin_username)
  validate_absolute_path($admin_sshkey)
  validate_bool($manage_repos)
  validate_bool($manage_keys)
  validate_bool($local_keys)
  validate_string($package_version)

  # install the package
  package {'gitolite3':
    ensure => $package_version
  } ->

  # setup the admin directory
  file {'gitolite-vardir':
    ensure => directory,
    path   => $::gitolite_basedir
  } ->

  file {'gitolite-sshkey':
    ensure => file,
    path   => "${::gitolite_basedir}/${admin_username}.key",
    mode   => '0600',
    source => $admin_sshkey
  } ->

  exec {'gitolite-sshkey-public':
    refreshonly => true,
    subscribe   => File['gitolite-sshkey'],
    path        => '/usr/bin',
    cwd         => $::gitolite_basedir,
    command     => "ssh-keygen -y -f ${admin_username}.key > ${admin_username}.pub"
  } ->

  file {'gitolite-gitssh.sh':
    ensure => file,
    path   => "${::gitolite_basedir}/gitssh.sh",
    mode   => '0755',
    source => 'puppet:///modules/gitolite/gitssh.sh'
  } ->

  file {'gitolite-setup.sh':
    ensure => file,
    path   => "${::gitolite_basedir}/setup.sh",
    mode   => '0755',
    source => 'puppet:///modules/gitolite/setup.sh'
  } ->

  file {'gitolite-pull.sh':
    ensure => file,
    path   => "${::gitolite_basedir}/pull.sh",
    mode   => '0755',
    source => 'puppet:///modules/gitolite/pull.sh'
  } ->

  file {'gitolite-push.sh':
    ensure => file,
    path   => "${::gitolite_basedir}/push.sh",
    mode   => '0755',
    source => 'puppet:///modules/gitolite/push.sh'
  } ->

  # configure sudo
  file {'gitolite-sudo.conf':
    ensure => file,
    path   => '/etc/sudoers.d/gitolite',
    mode   => '0640',
    source => 'puppet:///modules/gitolite/sudoers'
  } ->

  # setup gitolite for the first time
  exec {'gitolite-firstrun':
    refreshonly => true,
    subscribe   => Package['gitolite3'],
    path        => [$::gitolite_basedir],
    command     => "setup.sh '${::gitolite_basedir}' ${admin_username}"
  } ->

  # this exec is here only for other resources to trigger it,
  # it updates gitolite's configuration when a new hook is installed or
  # a change is made to the .gitolite.rc file (XXX manage .gitolite.rc)
  exec {'gitolite-update':
    refreshonly => true,
    path        => ['/usr/bin'],
    command     => 'sudo -u gitolite3 gitolite setup'
  }

  # pull the most recent gitolite-admin repository
  if $manage_repos or $manage_keys {
    exec {'gitolite-pull':
      path    => [$::gitolite_basedir],
      command => "pull.sh '${::gitolite_basedir}' ${admin_username}",
      require => [File['gitolite-pull.sh'], Exec['gitolite-update']]
    }
  }

  # configure gitolite repositories
  if $manage_repos {
    concat {'gitolite.conf':
      path    => "${::gitolite_basedir}/gitolite-admin/conf/gitolite.conf",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Exec['gitolite-pull'],
      before  => Exec['gitolite-push']
    }

    gitolite::repo {'gitolite-admin':
      full_access => [$admin_username]
    }
  }

  # configure gitolite ssh keys
  if $manage_keys {
    file {'gitolite-sshkeys':
      ensure  => directory,
      path    => "${::gitolite_basedir}/gitolite-admin/keydir",
      mode    => '0755',
      purge   => !$local_keys,
      recurse => true,
      require => Exec['gitolite-pull'],
      before  => Exec['gitolite-push']
    }

    gitolite::sshkey {$admin_username:
      host   => $::hostname,
      source => "${::gitolite_basedir}/${admin_username}.pub"
    }
  }

  # push any changes to the gitolite-admin repository
  if $manage_repos or $manage_keys {
    exec {'gitolite-push':
      path    => [$::gitolite_basedir],
      command => "push.sh '${::gitolite_basedir}' ${admin_username}",
      require => [File['gitolite-push.sh'], Exec['gitolite-pull']]
    }
  }
}
