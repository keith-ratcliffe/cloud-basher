
Prerequisites

      None other than Linux/Bash, and an Internet connection to wget tarballs.
      Tested on CentOS 7. *Should* be fine on any Linux with Bash 4.x

Why does this thing exist?

      To speed up my development and prototyping workflow. Cloud stuff mostly

What does this thing do?

      Automates the steps that I'd otherwise have to perform manually to 
      install/configure/teardown services, using a consistent, repeatable,
      extensible process. That is all.

What the heck is it?

      It's just a couple of bash scripts that provide a pluggable framework for doing 
      whatever you want with whichever (bash-compatible) services you need.

      Currently you get Hadoop, Accumulo, and NiFi plugins out of the box. Standalone
      single-node cluster configuration is implemented, but multi-node options coming soon.

      You can easily pick/choose which service plugins you want, modify existing plugins,
      or create new plugins without much hassle

What does this thing do that something like Docker or Cloudera Manager couldn't do even better?

      Not much. However, additional dependencies and complexities here are minimal compared
      with those. Distributed applications built on Hadoop and Accumulo have complex networking
      and IPC requirements, which makes them challenging to implement using containers. And as
      far as Cloudera Manager, I've spent far less time implementing this thing than I've spent
      just trying to decipher its documentation.

      That being said, I do love Docker ;)

How do I get started?

    (1) Edit ~/.bashrc: 
        Source cloud-devel-env.sh in your ~/.bashrc. E.g...
        echo "source /path/to/this_dir/bin/cloud-devel-env.sh" >> ~/.bashrc

    (2) Download tarballs: 
        Open a new terminal... 
        Tarballs for any registered services (in this case, Hadoop, Accumulo/ZooKeeper,
        and NiFi) will begin downloading immediately.
      
    (3) Install services:
        When downloads are finished, execute the "installAll" command

    (4) Start services:
        When installs are finished, execute the "startAll" command

    (5) To check the status of services, execute the "statusAll" command.
        And visit some websites in your browser...

           Hadoop: http://localhost:50070/dfshealth.html#tab-overview
         Accumulo: http://localhost:50095
             NiFi: http://localhost:8080/nifi/

    (6) Do more stuff. Let the real work begin

How do I stop doing stuff?

    (1) To stop services, execute the "stopAll" command
    (2) To uninstall services, execute the "uninstallAll" command

How do I find out more?

    Read some code. There's about a 39% chance that it'll have some useful comments. 
    Start with bin/cloud-devel-env.sh. It's the key to everything else
