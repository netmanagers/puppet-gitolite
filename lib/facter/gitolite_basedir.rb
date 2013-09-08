# == Fact: gitolite_basedir
#
# A custom fact that sets the default location for gitolite shell scripts
# and configuration files.
#
# "${::vardir}/gitolite/"
#
Facter.add("gitolite_basedir") do
  setcode do
    File.join(Puppet[:vardir], "gitolite")
  end
end
