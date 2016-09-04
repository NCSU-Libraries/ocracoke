# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # This box works better than the centos project created one
  config.vm.box = "boxcutter/centos72"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.30"

  config.vm.network "forwarded_port", guest: 80, host: 8088,
      auto_correct: true
  config.vm.network "forwarded_port", guest: 443, host: 8443,
      auto_correct: true
  config.vm.network "forwarded_port", guest: 3000, host: 8090,
      auto_correct: true
  config.vm.network "forwarded_port", guest: 8983, host: 8984,
      auto_correct: true


  config.vm.provider "virtualbox" do |vb|
    vb.linked_clone = true
    vb.memory = 1024
    vb.cpus = 2
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = 'ansible/development-playbook.yml'
    ansible.inventory_path = 'ansible/development.ini'
    ansible.limit = 'all'
    # ansible.verbose = 'vvvv'
  end

  config.ssh.forward_agent = true
end
