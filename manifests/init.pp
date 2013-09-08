# = Class: gitolite
#
# This class installs and configures gitolite3.
#
class gitolite
(
	$admin_username,
	$admin_sshkey,
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

	# configure gitolite
	exec {'gitolite_firstrun':
		refreshonly => true,
		subscribe   => Package['gitolite3'],
		path        => [$::gitolite_basedir],
		command     => "setup.sh '${::gitolite_basedir}' ${admin_username}"
	}
}
