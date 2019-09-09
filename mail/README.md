# RIEAU INFRA - Mail serveur

> Installation du Serveur [Mail](https://github.com/tomav/docker-mailserver)

## Développement

### Prérequis

* Docker 19.03+

### Dev

* Docker-compose 1.24+
* [Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/) 1.12+

## Déploiements

### En dev

Suivre le [tuto](https://github.com/tomav/docker-mailserver/wiki/Installation-Examples).

```shell
docker-compose -f mail/docker-compose.yml up -d --build
```

### En prod

* Sélectionner le contexte du namespace: `kubens rieau`

* Autoriser le port smtp tls:

```shell
sudo ufw allow 465
sudo ufw reload
```

* Installer le stockage local:

```shell
mkdir -p $HOME/data/mail/data
mkdir -p $HOME/data/mail/state
kubectl create -f k8s/pv-claims.yml -f k8s/pv-local.yml
```

* Installer le Mail serveur avec les manifests (cf. [tuto](https://github.com/tomav/docker-mailserver/wiki/Using-in-Kubernetes)):

Créer le compte `noreply@rieau.cohesion-territoires.gouv.fr` et son alias:

```shell
curl -o setup.sh https://raw.githubusercontent.com/tomav/docker-mailserver/master/setup.sh; sudo chmod a+x ./setup.sh
sudo ./setup.sh email add noreply@rieau.cohesion-territoires.gouv.fr [<password>]
sudo ./setup.sh alias add ne-pas-repondre@rieau.cohesion-territoires.gouv.fr noreply@rieau.cohesion-territoires.gouv.fr
```

Générer la clé DKIM:

```shell
sudo ./setup.sh config dkim
```

Copier les contenus des fichiers générés de `config/` dans `configmap.yml`.

Copier dans un secret la clé dkim générée dans `config/opendkim/keys/rieau.cohesion-territoires.gouv.fr/mail.private`:

```shell
kubectl create secret generic mailserver.opendkim.keys --from-file=./config/opendkim/keys/rieau.cohesion-territoires.gouv.fr/mail.private
```

Ajouter dans le DNS bind9 local la zone:

```shell
cat << EOF | sudo tee /etc/bind/named.conf.default-zones
zone "200.208.23.94.in-addr.arpa" {
        type master;
        file "/etc/bind/db.fr.gouv.cohesion-territoires.rieau";
};
EOF
```

Configurer le DNS du host pour ajouter le mail:

```shell
cat << EOF | sudo tee /etc/bind/db.fr.gouv.cohesion-territoires.rieau
;
; BIND reverse data file for  interface
;
$TTL    604800
@       IN      SOA     rieau.cohesion-territoires.gouv.fr rieau.cohesion-territoires.gouv.fr (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      rieau.cohesion-territoires.gouv.fr.
10      IN      PTR     rieau.cohesion-territoires.gouv.fr.

mail      IN  A   94.23.208.200

; mailservers for rieau.cohesion-territoires.gouv.fr
    rieau.cohesion-territoires.gouv.fr.  IN  MX  1  mail.rieau.cohesion-territoires.gouv.fr.

; Add SPF record
   rieau.cohesion-territoires.gouv.fr.       IN TXT "v=spf1 mx ~all"
; OpenDKIM
mail._domainkey	IN	TXT	( "v=DKIM1; k=rsa; "
	  "p=<dkim_key>" )  ; ----- DKIM key mail for rieau.cohesion-territoires.gouv.fr

EOF
```

Installer le chart de [docker-mailserver](https://hub.helm.sh/charts/funkypenguin/docker-mailserver):

```shell
kubectl create -f k8s/
```

Supprimer `rm -r /tmp/docker-mailserver`.
