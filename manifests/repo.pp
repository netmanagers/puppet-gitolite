# = Type: gitolite::repo
#
# XXX
#
define gitolite::repo
(
	$read_only = [],
	$read_write = [],
	$full_access = [],
	$deny_access = []
)
{
	# validate parameters
	validate_array($read_only)
	validate_array($read_write)
	validate_array($full_access)
	validate_array($deny_access)

	# XXX must have at least one member with permission to something ???

	# configure the repository
	concat::fragment {"gitolite-repo-${title}":
		target  => 'gitolite.conf',
		order   => '20',
		content => template('gitolite/repo.conf.erb'),
                require => Exec['gitolite-pull'],
                before  => Exec['gitolite-push'],
                notify  => Exec['gitolite-push'],
	}
}
