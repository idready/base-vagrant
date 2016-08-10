###############
# Welcome !!! #
###############

###
# If you are creating a new machine for a new project, please make sure you've checked that:
# 1- the MySQL section is correctly filled,
# 2- the Apache configuration match the project's needs
###

#Defining default path
Exec { path => '/usr/bin:/bin:/usr/sbin:/sbin' }
#Adding puppet group non-available by default on lucid64 box
group { 'puppet':
    ensure => 'present',
}

#Defining apt-get update
exec { 'apt-get update':
    command => '/usr/bin/apt-get update && touch /tmp/apt.update',
    onlyif => "/bin/sh -c '[ ! -f /tmp/apt.update ] || /usr/bin/find /etc/apt -cnewer /tmp/apt.update | /bin/grep . > /dev/null'",
}
#Regeneration of locale to avoid ubuntu completion bug
exec { 'locale-gen fr_FR.UTF-8': }
# Configure timezone of the server
exec { 'echo "export TZ=Europe/Paris" >> /etc/environment': }

###
# MySQL
###
#Install and defining root password
class { 'mysql::server':
  config_hash => {'root_password' => 'passw0rd'}
}

#mysql::db { 'goldfinger_db':
#    user => 'admin',
#    password => 'passw0rd',
#    sql => '/vagrant/database/bdd.sql'
#}

# Remarks:
#   If you have a model which needs its own database,
#   or you have several applications (ex: eZ Publish + Magento) with their own database,
#   you can take a look on the script behind

#mysql::db { 'MODEL':
#   user => 'model_user',
#   password => 'model_password',
#   sql => '/vagrant/database/MODEL.sql'
#}

###
# Apache 2 - Installation
###
# Install package
package { apache2:
    ensure => installed,
    require => Exec['apt-get update']
}
package { libapache2-mod-php5:
    ensure => installed,
    require => Exec['apt-get update'],
    notify => Exec['/etc/init.d/apache2 restart']
}
package { php5-mysql:
    ensure => installed,
    require => [Exec['apt-get update'], Package['libapache2-mod-php5']],
    notify => Exec['/etc/init.d/apache2 restart']
}
package { php5-cli:
    ensure => installed,
    require => [Exec['apt-get update']],
    notify => Exec['/etc/init.d/apache2 restart']
}
package { php5-gd:
    ensure => installed,
    require => Exec['apt-get update'],
    notify => Exec['/etc/init.d/apache2 restart']
}
package { php5-curl:
    ensure => installed,
    require => [Exec['apt-get update']],
    notify => Exec['/etc/init.d/apache2 restart']
}
package { php5-mcrypt:
    ensure => installed,
    require => [Exec['apt-get update']],
    notify => Exec['/etc/init.d/apache2 restart']
}

###
# Apache 2 - Configuration
###
# AcceptPathInfo directive - Not working
file { '/etc/apache2/conf.d/acceptpathinfo':
    content => 'AcceptPathInfo On',
    require => Package['apache2'],
    notify => Exec['/etc/init.d/apache2 restart']
}
# Resolving sharing problem with Apache
file { '/etc/apache2/conf.d/enablesendfileoff':
    content => 'EnableSendfile Off',
    require => Package['apache2'],
    notify => Exec['/etc/init.d/apache2 restart']
}
# Activating mod_rewrite
exec { 'a2enmod rewrite':
    require => Package['apache2'],
    notify => Exec['/etc/init.d/apache2 restart']
}
# Time zone config
file { '/etc/php5/conf.d/timezone.ini':
    content => 'date.timezone = "Europe/Paris"',
    require => Package['libapache2-mod-php5'],
    notify => Exec['/etc/init.d/apache2 restart']
}

# Virtualhost configuration
file {'/etc/apache2/sites-available/magento':
    ensure => link,
    target => '/vagrant/puppet/manifests/magento.vhost',
    require => Package['apache2']
}
file {'/var/log/apache2':
    recurse => 'true',
    group => 'www-data',
    mode => 'a+rwX'
}
exec {'a2ensite magento':
    require => File['/var/log/apache2'],
    notify => Exec['/etc/init.d/apache2 restart'],
}
exec { '/etc/init.d/apache2 restart': }