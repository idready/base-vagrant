###############
# Welcome !!! #
###############

###
# If you are creating a new machine for a new project, please make sure you've checked that:
# 1- the web port number redirection,
# 2- the ssh port number redirection,
# 3- the virtualbox shared folder location
###

Vagrant::Config.run do |config|

    #Using default base box
    config.vm.box = "precise32"

    # config.vm.boot_mode = :gui

    # Increase RAM Memory default value
    config.vm.customize ["modifyvm", :id, "--memory", 1024]
    config.vm.customize ["modifyvm", :id, "--cpus", 1]
    
    ## For testing purpose
    #config.vm.network :hostonly, "10.1.1.51"

    #Puppet files configuration
    config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "puppet/manifests"
        puppet.manifest_file = "vm.box.pp"
        puppet.module_path = "puppet/modules"
    end

    #Forwarding ports (name, virtual marchine port, physical marchine port)
    config.vm.forward_port(80, 9000)
    config.vm.forward_port(22, 2229)
    
    # config.vm.network :bridged

    #Shared folders
    config.vm.share_folder("web_files", "/var/www/", "app", :owner => "www-data", :group => "vagrant")
end

