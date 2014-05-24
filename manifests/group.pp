# = Type: gitolite::group
#
# XXX
#
define gitolite::group
(
  $members = []
)
{
  # validate parameters
  validate_array($members)

  if ($title == 'all') {
    fail("Resource ${module_name} cannot be defined with title 'all'.")
  }

  # XXX members can't be empty

  # configure the group
  concat::fragment {"gitolite-group-${title}":
    target  => 'gitolite.conf',
    order   => '10',
    content => template('gitolite/group.conf.erb')
  }
}
