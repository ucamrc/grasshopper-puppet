# Grasshopper Event Engine

Puppet configuration and environment management for the Grasshopper event engine.

## Environments

 * The app server logs can be found at /opt/grasshopper/server.log
 * If you make changes to the backend code you will need to restart the app server.
   This can be done by ssh'ing into the client machine by running `service grasshopper restart`.
 * Even if you'd install all the components on your host OS, you would not be
   able to run the server as some of the npm modules are compiled during the
   provisioning step.

### Local machine / Vagrant

It's possible to get Grasshopper up and running on your local machine using
[Vagrant](http://www.vagrantup.com) by following these steps:

#### Preparation

##### Install VirtualBox and Vagrant

* Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* Install [Vagrant](http://downloads.vagrantup.com)

##### Get the source code

Clone [grasshopper](https://github.com/CUL-DigitalServices/grasshopper),
[grasshopper-ui](https://github.com/CUL-DigitalServices/grasshopper-ui) and
[grasshopper-puppet](https://github.com/CUL-DigitalServices/grasshopper-puppet)
and make sure they are all in the same folder. You should have something like:

```
+ grasshopper
|-- + grasshopper
|-- + grasshopper-ui
|-- + grasshopper-puppet
```

You should **NOT** attempt to use these directories straight from your host OS
as they will contain Linux specific compiled binaries and will not work on your
host OS.
Vice versa, do not try to share anything that you compiled on your host OS with
Vagrant.

##### Configure your hosts file

The hosts file is a file that allows you to map fake domain names to certain IP
addresses. By mapping them to the Virtualbox VM IP address we can fake multiple
tenants running on one system. (This IP address is specified in `Vagrantfile`).
Edit your hosts file (`/etc/hosts` on UNIX,
C:\Windows\System32\drivers\etc\hosts on Windows) and add the following entries.

```
192.168.56.123   admin.timetable.vagrant.com
192.168.56.123   2014.timetable.vagrant.com
192.168.56.123   2013.timetable.vagrant.com
```

##### Configure the amount of memory Vagrant/VirtualBox can use.

By default the VM will be allotted 3072MB of RAM. If you do not have this much
RAM available, you can change this in the VagrantFile found in
grasshopper/grasshopper-puppet.

#### Getting up and running

cd into the `grasshopper-puppet` directory and run:

```
vagrant box add grasshopper https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box
vagrant up
```

This command will pull down a VirtualBox image and deploy all the necessary
components onto it. Depending on how fast your host machine and internet
connection is, this can take quite a while. Initial set-ups of 30-45 minutes
are not uncommon.

(Note: this image already has puppet installed for convenience, though it will
probably be an older version (3.4) than the puppet installed in the non-vagrant
environments)

Once that is done you should have a VM with a fully functioning environment.
Open your browser and go to http://admin.vagrant.com and you should be presented
with the Admin UI.

#### Notes

 * The app server logs can be found at /opt/grasshopper/server.log (or at
   grasshopper/grasshopper/server.log on your host machine).
 * If you make changes to the backend code you will need to restart the app server.
   This can be done by ssh'ing into the client machine by running `vagrant ssh`
   and running `service grasshopper restart`.
 * Even if you'd install all the components on your host OS, you would not be
   able to run the server as some of the npm modules are compiled during the
   provisioning step.
 * If you've finished your development tasks or want to free up some resources
   for something else, you can run `vagrant halt` which will shutdown the VM.
 * If you restart the VM using 'vagrant up', you may need to start Grasshopper
   server manually by running 'vagrant ssh' and 'sudo service grasshopper start'.


### Dev and QA Environments (e.g. on EC2)

#### Provisioning

Provision an Ubuntu Trusty server, then:
```
local$ ssh devserver.ontheinternet
devserver$ sudo apt-get update
devserver$ sudo apt-get -y install git
# (If you're testing puppet changes not in main master, don't forget to modify this next line!)
devserver$ sudo git clone git://github.com/CUL-DigitalServices/grasshopper-puppet /opt/grasshopper-puppet
devserver$ cd /opt/grasshopper-puppet
```

Now edit the right `common.json` for your chosen environment (`dev`/`qa`):
* to make `tenant_hostname` match your new server's hostname
* review the two git `revision`s under `app_install_config`: if appropriate,
  edit each to a commit SHA, tag or branch name of your choice

`devserver$ sudo vim environments/[dev|qa]/hiera/common.json`

Copy some timetable data to import onto the server:

`local$ scp timetabledata.json devserver.ontheinternet:/tmp/timetabledata.json`

Back to the server to run puppet. **Take note** of the puppet command line
displayed at the end, you may find it useful later. This puppet step could take
**at least 60 mins** if you have a slow server and lots of data to import!

`devserver$ sudo ./provisioning/grasshopper/init.sh [dev|qa]`

*Optional: only on environments like `dev` where `ghservice::apache::enable_basic_auth` is `true`:*
* *Set username and password to protect externally visible server with play data in:*
* *`devserver$ sudo htpasswd -c /etc/apache2/dev_auth_file #username#`*

#### Client usage

In a web browser, try going to the hostname you entered into `common.json` above, 
it should show you the Student UI!

If you wish to access the Global Admin (e.g. UI or Swagger Docs) you will need
to edit the `/etc/hosts` file on the client that you wish to browse from. Add
something like this to it:

`nn.nnn.nn.n  admin.ec2-nn-nnn-nn-n.eu-west-1.compute.amazonaws.com`

#### Grasshopper usage

You can monitor grasshopper's logs like this:

`devserver$ sudo tail -f /var/log/upstart/grasshopper.log`

You can control the grasshopper server like this:

`devserver$ sudo service grasshopper [start|stop|restart]`

#### HANDY HINT, especially for EC2 users (and similar)

You may want to **avoid changing your hostname** - either get a static IP, or
don't shutdown! Otherwise reconfiguring the system with a new hostname might be
fiddly.
*(Have not yet tested/audited how fiddly or whether puppet will fix it all;
but for instance, the `setup-via-api.sh` script won't know how to rename an app etc)*

#### Known warnings and errors during provisioning

**NOTE**: during the puppet step, you may get some of the following warnings and
errors, but these can safely be ignored: *(Last two pertain to
`/usr/lib/update-notifier/apt-check`)*

```
- Warning: Setting templatedir is deprecated ...
- Could not retrieve fact='apt_updates'...
- Could not retrieve fact='apt_security_updates'...
```

