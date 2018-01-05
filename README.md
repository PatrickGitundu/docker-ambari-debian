Most of the credit for this goes to <a href="https://github.com/weiqingy/caochong">weiqingy/caochong</a>

# Hadoop and Spark on Docker using Debian Wheezy

This tool sets up a Hadoop and/or Spark **cluster** running within Docker **containers** on a **single** physical machine (e.g. your laptop). It's convenient for debugging, testing and operating a real cluster, especially when you run customized packages with changes of Hadoop/Spark source code and configuration files.

The major difference between this work and Caochong's is that I used debian instead of Centos for my build.
I used debian because in trying to deploy this on an Ubuntu 16.04 server, the Centos installation would not recognize the correct kernel and therefore would not launch any of the ambari-services. I found that using Debian and specifically; wheezy; overcame this and a host of other problems caused by apt on other flavors of Debian.
