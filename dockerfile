FROM almalinux:latest

LABEL vendor=sistemmsn

ENV NODEJSV              20.10.0
ENV MESHUSER             meshcentral

RUN dnf update -y && \
    dnf install -y epel-release && \
    dnf install -y wget mysql git vim sudo htop

RUN dnf install -y https://fastdl.mongodb.org/tools/db/mongodb-database-tools-rhel90-x86_64-100.9.4.rpm  && \
    dnf install -y mongodb-database-tools && \
    dnf clean all

RUN wget https://nodejs.org/dist/v${NODEJSV}/node-v${NODEJSV}-linux-x64.tar.xz  && \
    tar -xvf node-v${NODEJSV}-linux-x64.tar.xz && \
    mv node-v${NODEJSV}-linux-x64 /opt/node && \
    rm -rf node-v${NODEJSV}-linux-x64.tar.xz

WORKDIR /opt/meshcentral

RUN sudo ln -s /opt/node/bin/node /usr/bin/node && \
    sudo ln -s /opt/node/bin/npm /usr/bin/npm


RUN sed -i  '101imeshcentral ALL=(ALL) NOPASSWD: /usr/bin/npm' /etc/sudoers && \
    sed -i  '102imeshcentral ALL=(ALL) NOPASSWD: /usr/bin/node' /etc/sudoers && \
    sed -i  '103imeshcentral ALL=(ALL) NOPASSWD: /usr/bin/dnf' /etc/sudoers  && \
    sed -i  '6i[mysqldump]' /etc/my.cnf && \
    sed -i  '7icolumn-statistics=0' /etc/my.cnf
    
RUN sudo useradd -r -d /opt/${MESHUSER} -s /bin/bash  ${MESHUSER}  && \
    mkdir -p /opt/${MESHUSER} && \
    npm install -g npm@latest && \
    npm install ${MESHUSER} && \
    sudo chown -R ${MESHUSER}:${MESHUSER} /opt/${MESHUSER}
    
COPY config.json.template /opt/meshcentral/meshcentral-data/config.json
COPY mcstart.sh mcstart.sh

RUN chmod 755 /opt/${MESHUSER}/mcstart.sh && \
    sudo chown -R ${MESHUSER}:${MESHUSER} /opt/${MESHUSER}/mcstart.sh 
    
EXPOSE 80 443

VOLUME /opt/meshcentral/meshcentral-data
VOLUME /opt/meshcentral/meshcentral-files
VOLUME /opt/meshcentral/meshcentral-backups
VOLUME /opt/meshcentral/meshcentral-web

CMD ["bash","/opt/meshcentral/mcstart.sh"]
