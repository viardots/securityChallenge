<!-- Copyright {2017} {Viardot Sebastien} -->
# Exemple d'image Docker pour créer un challenge de sécurité

Ce dépôt contient un exemple simple de challenge de sécurité basé sur Docker.

Récupérez les fichiers [Dockerfile](Dockerfile) et [sls.c](sls.c).

## Mode conteneur seul : challenge directement dans le conteneur

**Remarque** : si vous avez `podman` installé sur votre machine au lieu de `docker`, vous pouvez faire les mêmes expérimentations en remplaçant la commande `docker` par `podman`.

Construisez l'image avec :

```bash
docker build . -t challenge
```

Vous disposez alors d'une image nommée **challenge** pour réaliser le challenge.
```bash
docker images
REPOSITORY                     TAG                 IMAGE ID            CREATED             SIZE
challenge                      latest              3e8e6eb66c4e        7 seconds ago       307MB
```

Créez ensuite un conteneur qui lance un shell avec l'utilisateur **level01** (voir les deux dernières lignes non commentées du [Dockerfile](Dockerfile)) :

```bash
docker run -t -i --rm challenge
level01@3009210a28f9:~$
```

Vous pouvez alors faire le challenge : l'objectif est de lire le contenu du fichier `.password`.

Indice : regardez les droits sur les fichiers et ce qu'ils font.

## Mode conteneur avec serveur SSH

Pour utiliser ce mode, il faut modifier légèrement l'image afin de lancer un serveur SSH et permettre à l'utilisateur **level01** de se connecter avec le mot de passe **mdpLevel01**.

Pour cela, modifiez la fin du fichier [Dockerfile](Dockerfile) en commentant le lancement d'un shell en tant qu'utilisateur **level01** et en décommentant le lancement du serveur SSH en tant qu'administrateur. En commentant `USER level01`, on reste en `USER root`.

```bash
...
# Démarre le container en level01 avec un shell (à décommenter)
# A lancer avec
# docker run -t -i --rm challenge
#USER level01
#CMD /bin/bash
# Version avec un serveur ssh, lancer le container avec docker run -d -p 22222:22 --rm challenge
COPY startssh.sh /usr/bin/startssh.sh
RUN chmod +x /usr/bin/startssh.sh
EXPOSE 22
CMD /usr/bin/startssh.sh
```

Construisez ensuite l'image avec :

```bash
docker build . -t challengessh
```

Vous disposez alors d'une image nommée **challengessh** pour réaliser le challenge.

```bash
docker images
REPOSITORY                     TAG                 IMAGE ID            CREATED             SIZE
challengessh                   latest              8e3b6626d8de        7 seconds ago       307MB
challenge                      latest              3e8e6eb66c4e        7 hours ago         307MB
```

Démarrez le conteneur en mode « démon » (`-d`) pour qu'il reste actif, puis redirigez le port local **22222** vers le port **22** :

```bash
docker run -d -p 22222:22 --name conteneurChallengeSSH challengessh
```

Le conteneur est alors démarré :

```bash
#docker ps
CONTAINER ID        IMAGE               COMMAND               CREATED             STATUS              PORTS                   NAMES
9fc2b87554f2        challengessh        "/usr/sbin/sshd -D"   4 minutes ago       Up 4 minutes        0.0.0.0:22222->22/tcp   conteneurChallengeSSH
```

Vous pouvez alors vous connecter au conteneur via SSH et faire le challenge :

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

**Attention** : le conteneur reste démarré jusqu'à ce que vous lui demandiez de s'arrêter :

```bash
docker stop conteneurChallengeSSH
```

puis à le supprimer :

```bash
docker rm conteneurChallengeSSH
```

## Vérification de la sécurité de l'image générée

En utilisant [trivy](https://github.com/aquasecurity/trivy), il est possible de scanner l'image générée pour identifier d'éventuels problèmes.

Avec Docker, voici un moyen simple de le faire :

```bash
docker run -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image challengessh
```

Avec Podman :

```bash
podman save challengessh -o challengessh.tar # Permet de disposer d'une archive de l'image créée
trivy image --input challengessh.tar
```

La distribution [alpine](https://www.alpinelinux.org/) est légère et orientée sécurité pour la construction de conteneurs.

1. Modifiez le Dockerfile pour utiliser Alpine plutôt que Debian (la configuration est déjà présente).
2. Construisez l'image avec l'option `--no-cache` pour éviter de conserver d'anciennes failles : `docker build --no-cache . -t challengesshtrivy`
3. Scannez de nouveau l'image avec Trivy.
