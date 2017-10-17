# Copyright {2017} {Viardot Sebastien}
# Pour créer l'image docker build . -t challenge
# Image de base
FROM debian:stable
# Auteur, inspiré de newbiecontest wargame level01
MAINTAINER Sebastien Viardot <Sebastien.Viardot@grenoble-inp.fr>
# Ajoute 2 utilisateurs dont level01 avec le mot de passe mdpLevel01
RUN useradd -ms /bin/bash level01
RUN echo 'level01:mdpLevel01' | chpasswd
RUN useradd -ms /bin/bash level01priv
# Installe de quoi compiler le programme vulnérable et le serveur ssh
RUN apt-get update && \
    apt-get -y install gcc openssh-server && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir /var/run/sshd
# Configure le compte level01 avec une commande permettant d'endosser l'identité de level01priv
USER root
WORKDIR /home/level01
COPY sls.c .
RUN /usr/bin/gcc sls.c -o sls && \
    chown level01priv.level01priv sls* && \
    chmod 4755 sls && chmod 444 sls.c
# Crée le fichier .password avec des droits en lecture seule pour level01priv
RUN echo "B@UTitmdp!" > .password && \
    chown level01priv.level01priv .password &&\
    chmod 400 .password
# Démarre le container en level01 avec un shell (à décommenter)
# A lancer avec
# docker run -t -i --rm challenge
USER level01
CMD /bin/bash
# Version avec un serveur ssh, lancer le container avec docker run -d -p 22222:22 --rm challenge
#EXPOSE 22
#CMD ["/usr/sbin/sshd", "-D"]
