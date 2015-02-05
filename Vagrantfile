# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Use the "grasshopper" box to host
  config.vm.box = "grasshopper"

  # Rather than forwarding ports from the Virtualbox to the host OS localhost,
  # we create an environment that is more similar to EC2, where the Virtualbox
  # VM gets its own IP address (albeit only accessible from your host box).
  config.vm.network "private_network", ip: "192.168.56.123"

  # Share the back-end and front-end code with Vagrant.
  # It's assumed that grasshopper and grasshopper-ui are on the same level as grasshopper-puppet.
  # Note that Puppet will change some files in these directories
  config.vm.synced_folder "../grasshopper", "/opt/grasshopper"
  config.vm.synced_folder "../grasshopper-ui", "/opt/grasshopper-ui"

  # Run a shell script that will do some basic bootstrapping and finally runs puppet.
  config.vm.provision "shell", run: "always", :path => "provisioning/vagrant/init.sh"

  # Allow us to create symlinks on the FS
  config.vm.provider :virtualbox do |vb|
    vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
    vb.customize ["modifyvm", :id, "--memory", 3072]
  end

end
