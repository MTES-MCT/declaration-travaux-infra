# RIEAU INFRA

> Infrastructure de déploiement de RIEAU

## Développement

### Prérequis

* Docker 18.09+

### Dev

* Docker-compose 1.24+
* [Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/) 1.12+

## Déploiements

### Dev

* Ajouter les domaines virtuels dans `/etc/hosts`:

```
127.0.0.1  app.rieau.local
127.0.0.1  sso.rieau.local
127.0.0.1  traefik.rieau.local

* Générer les certificats statiques auto-signés (pour le domaine localhost) dans le dossier `reverse-proxy/certs`:

```
cd reverse-proxy/certs/
openssl req -x509 -new -keyout root.key -out root.cer -config conf/root.cnf
openssl req -nodes -new -keyout server.key -out server.csr -config conf/server.cnf
openssl x509 -days 3650 -req -in server.csr -CA root.cer -CAkey root.key -set_serial 123 -out server.cer -extfile conf/server.cnf -extensions x509_ext
```

* Renseigner les variables d'environnement:

```
cp sso/keycloak.env.sample sso/keycloak.env
cp sso/gatekeeper/keycloak-gatekeeper.conf.sample sso/gatekeeper/keycloak-gatekeeper.conf
cp app/application.properties.sample app/application.properties
cp app/app.env.sample app/app.env
```

* [Reverse Proxy Traefik](https://www.traefik.io/):

Configuration dans `reverse-proxy/traefik.toml`.

```
docker-compose -f reverse-proxy/docker-compose.yml up -d --build
```

* [Gatekeeper SSO Keycloak](https://www.keycloak.org/):

Utile pour ne pas partager le client_secret de OpenIDConnect entre keycloak et les clients.

```
docker-compose -f sso/gatekeeper/docker-compose.yml up -d --build
```

* [SSO Keycloak](https://www.keycloak.org/):

```
docker-compose -f sso/docker-compose.yml up -d --build
```

* App (UI+API):

```
docker-compose -f app/docker-compose.yml up -d --build
```

### Prod

* Administration du cluster [Kubernetes](https://kubernetes.io) avec [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/).

* Déploiements des pods par [kubectl](https://kubernetes.io/docs/reference/kubectl/kubectl/).