# Grasshopper Event Engine

Puppet configuration and environment management for the Grasshopper event engine.

## Environments

 * The app server logs can be found at /opt/grasshopper/server.log
 * If you make changes to the backend code you will need to restart the app server. This can be done by ssh'ing into the client machine by running `service grasshopper restart`.
 * Even if you'd install all the components on your host OS, you would not be able to run the server as some of the npm modules are compiled during the provisioning step.

### Local machine / Vagrant

It's possible to get Grasshopper up and running on your local machine using [Vagrant](http://www.vagrantup.com) by following these steps:

#### Preparation

##### Install VirtualBox and Vagrant

* Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* Install [Vagrant](http://downloads.vagrantup.com)

##### Get the source code

Clone [grasshopper](https://github.com/CUL-DigitalServices/grasshopper), [grasshopper-ui](https://github.com/CUL-DigitalServices/grasshopper-ui) and [grasshopper-puppet](https://github.com/CUL-DigitalServices/grasshopper-puppet) and make sure they are all in the same folder. You should have something like:

```
+ grasshopper
|-- + grasshopper
|-- + grasshopper-ui
|-- + grasshopper-puppet
```

You should **NOT** attempt to use these directories straight from your host OS as they will contain Linux specific compiled binaries and will not work on your host OS.
Vice versa, do not try to share anything that you compiled on your host OS with Vagrant.

##### Configure your hosts file

The hosts file is a file that allows you to map fake domain names to certain IP addresses. By mapping them to
the local loopback address we can fake multiple tenants running on one system.
Edit your hosts file (`/etc/hosts` on UNIX, C:\Windows\System32\drivers\etc\hosts on Windows) and add the following entries.

```
127.0.0.1   admin.timetable.vagrant.com
127.0.0.2   2014.timetable.vagrant.com
127.0.0.2   2013.timetable.vagrant.com
```

##### Configure the amount of memory Vagrant/VirtualBox can use.

By default the VM will be allotted 3072MB of RAM. If you do not have this much RAM available,
you can change this in the VagrantFile found in grasshopper/grasshopper-puppet.

#### Getting up and running

cd into the `grasshopper-puppet` directory and run:

```
vagrant box add grashopper https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box
vagrant up
```

This command will pull down a VirtualBox image and deploy all the necessary components onto it.
Depending on how fast your host machine and internet connection is, this can take quite a while. Initial set-ups of 30-45 minutes are not uncommon.

Once that is done you should have a VM with a fully functioning environment.
Open your browser and go to http://admin.vagrant.com and you should be presented with the Admin UI.

#### Notes

 * The app server logs can be found at /opt/grasshopper/server.log (or at grasshopper/grasshopper/server.log on your host machine).
 * If you make changes to the backend code you will need to restart the app server. This can be done by ssh'ing into the client machine by running `vagrant ssh` and running `service grasshopper restart`.
 * Even if you'd install all the components on your host OS, you would not be able to run the server as some of the npm modules are compiled during the provisioning step.
 * If you've finished your development tasks or want to free up some resources for something else, you can run `vagrant halt` which will shutdown the VM.
 * If you restart the VM using 'vagrant up', you may need to start Grasshopper server manually by running 'vagrant ssh' and 'sudo service grasshopper start'.

### QA
