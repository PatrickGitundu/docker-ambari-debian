FROM debian:wheezy-slim

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update
RUN apt-get install -y nano wget ntp sudo ca-certificates python-software-properties gnupg2 ufw 
RUN useradd ambari -p bigdata

# configure ssh free key access
RUN apt-get install -y openssh-client openssh-server
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN sed -i '/pam_loginuid.so/c session    optional     pam_loginuid.so'  /etc/pam.d/sshd
RUN echo "Host *\n StrictHostKeyChecking no" >> /etc/ssh/ssh_config

RUN apt-get install -y supervisor
RUN mkdir /etc/supervisor.d/
RUN echo "[program:sshd]\ncommand=/sbin/service sshd start" >> /etc/supervisord.conf
RUN echo "[program:ntpd]\ncommand=/sbin/service ntpd start" >> /etc/supervisord.conf

RUN add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main"
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update && apt-get upgrade -y 
RUN apt-get install -y postgresql 

RUN wget -O /etc/apt/sources.list.d/ambari.list http://public-repo-1.hortonworks.com/ambari/debian7/2.x/updates/2.6.0.0/ambari.list
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD
RUN apt-get update && apt-get install -y ambari-server

RUN ambari-server setup -s

RUN apt-get clean

EXPOSE 22 8080 8081 8082 8083 8084 8085 8086 8087 8088

CMD /usr/bin/supervisord -n