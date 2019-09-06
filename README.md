# RIEAU INFRA

[![CircleCI](https://circleci.com/gh/MTES-MCT/rieau-infra/tree/master.svg?style=svg)](https://circleci.com/gh/MTES-MCT/rieau-infra/tree/master)

> Infrastructure de déploiement de RIEAU

## En dev

* Le [reverse proxy](reverse-proxy/README)

* Le [SSO](sso/README)

* Le [Mail server](mail/README)

* L'[application](app/README)

* Backups:

Lancer un serveur ftp en mode passif pour les tests:

```shell
docker-compose -f backup/ftp/docker-compose.yml up -d --build
```

Renseigner les variables d'environnement:

```shell
cp backup/backup.env.sample backup/backup.env
```

```shell
./backup/backup.sh
```

Restore:

```shell
./backup/restore.sh
```

## En prod

Administration du cluster [Kubernetes](https://kubernetes.io) avec [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/).

### Préparation du Host

* Créer le user ??? avec droits sudo:

```shell
addUser ???
usermod -aG sudo ???
```

* Sécuriser le serveur en s'inspirant du [tuto](https://gist.github.com/lokhman/cc716d2e2d373dd696b2d9264c0287a3)

* Retirer le root:

```shell
sudo passwd -l root
```

* Activer authentification 2FA cf [tuto](https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-16-04):

```shell
sudo apt-get install libpam-google-authenticator
google-authenticator
sudo echo `auth required pam_google_authenticator.so` >> /etc/pam.d/sshd
sudo echo `#@include common-auth` >> /etc/pam.d/sshd
```

* Restreindre l'accès SSH au certificat pour le user en s'inspirant du [tuto](https://medium.com/@jasonrigden/hardening-ssh-1bcb99cd4cef):

```shell
ssh-copy-id -i ...
sudo nano /etc/ssh/sshd_config
PermitRootLogin no
PermitEmptyPasswords no
StrictModes yes
UseDNS no
X11Forwarding no
PasswordAuthentication no
AllowUsers ???@?.?.?.*
UsePAM yes
ChallengeResponseAuthentication yes
AuthenticationMethods publickey,keyboard-interactive
...
sudo systemctl reload sshd
```

* Activer le firewall local:

```shell
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable
```

* Mises à jour automatiques des patchs de sécurité:

```shell
sudo apt-get install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

* Installer fail2ban et l'antivirus ClamAV:

```shell
sudo apt install fail2ban clamav clamav-daemon
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo echo `[sshd]
enabled  = true
port    = ssh
logpath = %(sshd_log)s` >> /etc/fail2ban/jail.local
```

* Sécuriser la mémoire partagée:

```shell
sudo echo 'tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0' >> /etc/fstab
```

* Changer le timezone: `sudo timedatectl set-timezone Europe/Paris`

* Désactiver le swap:

```shell
sudo swapoff -a
# comment lines swap in /etc/fstab
```

* Hostname unique: `sudo hostnamectl set-hostname rieau.cohesion-territoires.gouv.fr`

### Installation du cluster Kubernetes

* Installer le Container runtime [Docker](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker)
* Installer [runc](https://github.com/opencontainers/runc): `sudo apt install runc`, pour corriger le [Bug](https://github.com/kubernetes/kubernetes/issues/76531), installer ce [fix de runc](https://github.com/youurayy/runc/releases/tag/v1.0.0-rc8-slice-fix-2).
* Installer [kubeadm](https://kubernetes.io/fr/docs/setup/independent/install-kubeadm/)
* [Création](https://kubernetes.io/fr/docs/setup/independent/create-cluster-kubeadm/) du cluster: `sudo kubeadm init --pod-network-cidr=192.168.0.0/16`
* Installation du CNI [Calico](https://docs.projectcalico.org/v3.8/getting-started/kubernetes/):

```shell
kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml
```

* Créer le stockage local sur le single node `rieau.cohesion-territoires.gouv.fr`:

```shell
mkdir -p $HOME/data
kubectl create -f storage/
```

### Installation de Helm

> [Helm](https://helm.sh/docs/using_helm/#installing-helm)

#### Client

```shell
curl -L https://git.io/get_helm.sh | sudo bash
```

#### Serveur Tiller

* [Sécurisation](https://helm.sh/docs/using_helm/#securing-your-helm-installation) préalable:

Création du service account tiller dans le namespace rieau:

```shell
kubectl create serviceaccount tiller --namespace rieau
```

Création du role et de son binding:

```shell
kubectl create -f helm/
```

Pour la création des clés pour la connexion TLS entre le client et le serveur, se placer dans le répertoire k8s/helm et suivre le [tuto](https://helm.sh/docs/using_helm/#using-ssl-between-helm-and-tiller).

* Installation de Tiller restreint au namespace rieau:

```shell
helm init \
--override 'spec.template.spec.containers[0].command'='{/tiller,--storage=secret}' \
--tiller-tls \
--tiller-tls-cert ./tiller.cert.pem \
--tiller-tls-key ./tiller.key.pem \
--tiller-tls-verify \
--tls-ca-cert ca.cert.pem \
--service-account=tiller \
--tiller-namespace=rieau
```

* Configuration du client:

Test:

```shell
helm ls --tls --tls-ca-cert ca.cert.pem --tls-cert helm.cert.pem --tls-key helm.key.pem --tiller-namespace rieau
```

Installation des certificats client:

```shell
cp ca.cert.pem $(helm home)/ca.pem
cp helm.cert.pem $(helm home)/cert.pem
cp helm.key.pem $(helm home)/key.pem
```

Test:

```shell
helm ls --tls --tiller-namespace rieau
```
