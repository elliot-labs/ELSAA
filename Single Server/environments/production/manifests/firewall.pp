if $firewallToggle {

    class { 'firewall': }

    resources { 'firewall':
        purge => true,
    }

    # Default firewall rules
    firewall { '000 accept all icmp':
        proto  => 'icmp',
        action => 'accept',
    }

    firewall { '001 accept all to lo interface':
        proto   => all,
        iniface => lo,
        action  => accept,
    }

    firewall { '002 reject local traffic not on loopback interface':
        iniface     => '! lo',
        proto       => 'all',
        destination => '127.0.0.1/8',
        action      => 'reject',
    }

    $ports.each | String $ruleName, Array $ruleParam | {
        firewall { "${ruleParam[0]} ${ruleName}":
            proto  => $ruleParam[2],
            dport  => $ruleParam[1],
            action => $ruleParam[3],
        }
    }

    # Optimize firewall traffic
    firewall { '998 accept related established rules':
        proto  => 'all',
        state  => ['RELATED', 'ESTABLISHED'],
        action => 'accept',
    }

    # Creates the second set of firewall rules, after the first set.
    firewall { '999 drop all':
        proto  => 'all',
        action => 'drop',
        before => undef,
    }
}
