# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos-6.6-X86_64"

  config.vm.provider "virtualbox" do |vb|
    #vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
    vb.customize ["modifyvm", :id, "--name", "app", "--memory", "512"] 
  end
  
  config.vm.host_name = "app"
  config.vm.network :forwarded_port, guest: 80, host: 80
  # config.vm.network :forwarded_port, guest: 9200, host: 9200
  # config.vm.network :forwarded_port, guest: 9300, host: 9300
  
  config.vm.network :private_network, ip: "192.168.33.10"

  config.vm.provision :shell, :path => "install-java.sh"
  config.vm.provision :shell, :path => "install-elasticsearch.sh"
  config.vm.provision :shell, :path => "install-logstash.sh"
  config.vm.provision :shell, :path => "install-kibana.sh"
  config.vm.provision :shell, :path => "install-redis.sh"
end
