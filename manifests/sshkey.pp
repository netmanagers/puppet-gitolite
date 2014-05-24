# = Type: gitolite::sshkey
#
# XXX
#
define gitolite::sshkey
(
	$user = $title,
	$host = undef,
	$source = undef,
	$content = undef
)
{
	# determine the full key name
	if $host == undef {
		$key = "${user}"
	}
	else {
		$key = "${user}@${host}"
	}

	if $source == undef and $content == undef {
		fail("Type ${module_name} requires ssh key source or content.")
	}

	# create the public key
	file {"gitolite-sshkeys-${title}":
		ensure  => file,
		path    => "${::gitolite_basedir}/gitolite-admin/keydir/${key}.pub",
		owner   => 'root',
		group   => 'root',
		mode    => '0644',
		source  => $source,
		content => $content,
                require => Exec['gitolite-pull'],
                before  => Exec['gitolite-push'],
                notify  => Exec['gitolite-push'],
	}
}
