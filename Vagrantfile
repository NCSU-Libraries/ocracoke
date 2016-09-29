# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # This box works better than the centos project created one
  config.vm.box = "boxcutter/centos72"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.30"

  config.vm.synced_folder '.', '/vagrant', type: 'nfs', mount_options: ['nolock']
  # :mount_options => ['nolock,vers=3,udp,noatime,actimeo=1']

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
    vb.cpus = 1
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = 'ansible/development-playbook.yml'
    ansible.inventory_path = 'ansible/development.ini'
    ansible.limit = 'all'
    # ansible.verbose = 'vvvv'
  end

  # https://github.com/kierate/vagrant-port-forwarding-info
  # vagrant plugin install vagrant-triggers
  # Get the port details in these cases:
  # - after "vagrant up" and "vagrant resume"
  config.trigger.after [:up, :resume] do
    run "#{File.dirname(__FILE__)}/get-ports.sh #{@machine.id}"
  end
  # - before "vagrant ssh"
  config.trigger.before :ssh do
    run "#{File.dirname(__FILE__)}/get-ports.sh #{@machine.id}"
  end

  # Until the patch in 1.8.6 is released do not try to insert ssh key. Or
  # manually apply the patch here:
  # https://github.com/mitchellh/vagrant/pull/7611
  # config.ssh.insert_key = false

  # set auto_update to false, if you do NOT want to check the correct
  # additions version when booting this machine
  config.vbguest.auto_update = true

  # do NOT download the iso file from a webserver
  config.vbguest.no_remote = false

  config.ssh.forward_agent = true
end
