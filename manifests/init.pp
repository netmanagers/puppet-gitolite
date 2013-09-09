# = Class: gitolite
#
# This class installs and configures gitolite3.
#
class gitolite
(
	$admin_username,
	$admin_sshkey,
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

	# install the package
	package {'gitolite3':
		ensure => $package_version
	} ->

	# setup the admin directory
	file {'gitolite_vardir':
		ensure  => directory,
		path    => $::gitolite_basedir
	} ->

	file {'gitolite_sshkey':
		ensure => file,
		path   => "${::gitolite_basedir}/${admin_username}.key",
		mode   => '0600',
		source => $admin_sshkey
	} ->

	exec {'gitolite_pubkey':
		refreshonly => true,
		subscribe   => File['gitolite_sshkey'],
		path        => '/usr/bin',
		cwd         => $::gitolite_basedir,
		command     => "ssh-keygen -y -f ${admin_username}.key > ${admin_username}.pub"
	} ->

	file {'gitolite_gitssh':
		ensure => file,
		path   => "${::gitolite_basedir}/gitssh.sh",
		mode   => '0755',
		source => 'puppet:///modules/gitolite/gitssh.sh'
	} ->

	file {'gitolite_setup':
		ensure => file,
		path   => "${::gitolite_basedir}/setup.sh",
		mode   => '0755',
		source => 'puppet:///modules/gitolite/setup.sh'
	} ->

	file {'gitolite_pull':
		ensure => file,
		path   => "${::gitolite_basedir}/pull.sh",
		mode   => '0755',
		source => 'puppet:///modules/gitolite/pull.sh'
	} ->

	file {'gitolite_push':
		ensure => file,
		path   => "${::gitolite_basedir}/push.sh",
		mode   => '0755',
		source => 'puppet:///modules/gitolite/push.sh'
	} ->

	# setup gitolite for the first time
	exec {'gitolite_firstrun':
		refreshonly => true,
		subscribe   => Package['gitolite3'],
		path        => [$::gitolite_basedir],
		command     => "setup.sh '${::gitolite_basedir}' ${admin_username}"
	} ->

	# configure gitolite repositories and keys
	exec {'gitolite_pull':
		path    => [$::gitolite_basedir],
		command => "pull.sh '${::gitolite_basedir}' ${admin_username}",
		require => File['gitolite_pull']
	} ->

	concat {'gitolite.conf':
		path  => "${::gitolite_basedir}/gitolite-admin/conf/gitolite.conf",
		owner => 'root',
		group => 'root',
		mode  => '0644'
	} ->

	file {'gitolite_sshkeys':
		ensure  => directory,
		path    => "${::gitolite_basedir}/gitolite-admin/keydir",
		mode    => '0755',
		purge   => !$local_keys,
		recurse => true
	} ->

	exec {'gitolite_push':
		path    => [$::gitolite_basedir],
		command => "push.sh '${::gitolite_basedir}' ${admin_username}",
		require => File['gitolite_push']
	}

	# default configuration
	gitolite::repo {'gitolite-admin':
		full_access => [$admin_username]
	}

	gitolite::sshkey {$admin_username:
		host   => $::hostname,
		source => "${::gitolite_basedir}/${admin_username}.pub"
	}
}
