# Type: gitolite::hook
#
# This type installs a gitolite hook.
#
define gitolite::hook
(
	$path = $title,
	$source = undef,
	$content = undef,
)
{
	# install the hook
	file {"gitolite-hook-$title":
		ensure  => file,
		path    => "/var/lib/gitolite3/.gitolite/hooks/$path",
		owner   => 'gitolite3',
		group   => 'gitolite3',
		mode    => '0755',
		source  => $source,
		content => $content,
		require => Exec['gitolite-firstrun'],
		before  => Exec['gitolite-update'],
		notify  => Exec['gitolite-update']
	}
}
