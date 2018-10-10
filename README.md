<!-- Copyright {2017} {Viardot Sebastien} -->
# Exemple d'image Docker pour la création d'un challenge de sécurité

Récupérer les fichiers [Dockerfile](Dockerfile) et [sls.c](sls.c).

## Mode conteneur seul, challenge directement sur la machine.

Créer la machine avec

```bash
docker build . -t challenge
```

On a à présent à notre disposition une image nommée **challenge**, pour faire le
challenge.
```bash
docker images
REPOSITORY                     TAG                 IMAGE ID            CREATED             SIZE
challenge                      latest              3e8e6eb66c4e        7 seconds ago       307MB
```

On crée ensuite un conteneur qui va lancer un shell avec l'utilisateur level01 (voir les 2 dernières lignes non commentées du [Dockerfile](Dockerfile))

```bash
docker run -t -i --rm challenge
level01@3009210a28f9:~$
```

On peut alors faire le challenge ... il faut lire le contenu du fichier .password (un indice regarder les droits sur les fichiers et ce qu'ils font...)

## Mode conteneur en serveur ssh.

Pour être dans ce mode on va changer un peu l'image pour qu'un serveur ssh
soit lancé, et permettre à l'utilisateur **level01** de se connecter avec le mot de passe
**mdpLevel01**.

Pour cela on modifie la fin du fichier [Dockerfile](Dockerfile) en commentant le lancement d'un shell en tant qu'utilisateur **level01** et on décommente le lancement du serveur ssh en tant qu'administrateur (en commentant ```USER level01``` on reste ```USER root```)

```bash
...
# Démarre le container en level01 avec un shell (à décommenter)
# A lancer avec
# docker run -t -i --rm challenge
#USER level01
#CMD /bin/bash
# Version avec un serveur ssh, lancer le container avec docker run -d -p 22222:22 --rm challenge
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
```

Créer la machine avec

```bash
docker build . -t challengessh
```

On a à présent à notre disposition une image nommée **challengessh**, pour faire le
challenge.

```bash
docker images
REPOSITORY                     TAG                 IMAGE ID            CREATED             SIZE
challengessh                   latest              8e3b6626d8de        7 seconds ago       307MB
challenge                      latest              3e8e6eb66c4e        7 hours ago         307MB
```

On démarre le conteneur en mode "démon" (**-d**) pour qu'il ne s'arrête pas, et on
redirige le port local **22222** vers **22**

```
#docker run -d -p 22222:22 --name conteneurChallengeSSH challengessh
```

Un conteneur est démarré

```bash
#docker ps
CONTAINER ID        IMAGE               COMMAND               CREATED             STATUS              PORTS                   NAMES
9fc2b87554f2        challengessh        "/usr/sbin/sshd -D"   4 minutes ago       Up 4 minutes        0.0.0.0:22222->22/tcp   conteneurChallengeSSH
```

On peut alors se connecter sur le conteneur via ssh et faire le challenge

```bash
ssh -p 22222 level01@localhost
level01@localhost's password:
Linux 9fc2b87554f2 4.9.49-moby #1 SMP Wed Sep 27 23:17:17 UTC 2017 x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
level01@9fc2b87554f2:~$
```

Il ne reste plus qu'à faire le challenge.

**Attention** Le conteneur reste démarré jusqu'à ce qu'on lui demande de s'arrêter

```bash
docker stop conteneurChallengeSSH
```

et à le supprimer

```bash
docker rm conteneurChallengeSSH
```
