puppet-gitolite
===============

Puppet module for installing and managing gitolite3.

Requirements
------------

* puppetlabs/stdlib (4.1.0+)
* puppetlabs/concat (1.0.0+)

Quick Start
-----------

Install and configure gitolite3.

    class {'gitolite':
      admin_username => 'root',
      admin_sshkey   => '/root/.ssh/id_rsa'
    }

Manage groups, repositories, and ssh keys with defined types.

    gitolite::group {'contractors':
      members => ['smith', 'austin']
    }

    gitolite::repo {'project-cool':
      read_only  => ['bill'],
      full_access => ['sam'],
      deny_access => ['@contractors']
    }

    gitolite::sshkey {'bill':
      source => '/home/bill/.ssh/id_rsa'
    }

    gitolite::sshkey {'sam':
      host    => 'dev.internal',
      content => $sam_ssh_key
    }

You can also install gitolite hooks.

    gitolite::hook {'redmine':
      path    => 'common/post-receive',
      content => template('redmine/post-receive.erb')
    }

Platforms
---------

This module currently supports redhat based platforms. It has been used in a
production environment on the following operating systems:

* CentOS 6.4
