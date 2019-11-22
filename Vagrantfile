# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # This box works better than the centos project created one
  config.vm.box = "centos/7"
  # config.vm.box_version = "1.2.4"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.30"

  config.vm.synced_folder '.', '/vagrant', type: "sshfs", ssh_opts_append: "-o Compression=yes", sshfs_opts_append: "-o cache=no"

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
    # vb.gui = true
  end

  # install git before running ansible provisioner
  config.vm.provision "shell", inline: "yum -y install git"


  config.vm.provision "ansible_local" do |ansible|
    ansible.galaxy_role_file = 'ansible/requirements.yml'
    ansible.playbook = 'ansible/development-playbook.yml'
    ansible.inventory_path = 'ansible/development.ini'
    ansible.limit = 'all'
    # ansible.verbose = 'vvvv'
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
