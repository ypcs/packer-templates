# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "debian-jessie64"
  config.vm.box_url = "https://cdn.ypcs.fi/vagrant/metadata.json"
  # config.vm.box_check_update = false

  config.vm.synced_folder "./dist", "/artifacts"
  config.vm.synced_folder '.', '/vagrant', :mount_options => ["ro"]
  config.vm.provision "shell", path: "scripts/provision.sh"  
end
