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

* Créer les réseaux internes Docker:

```
docker network create web
```

* Générer les certificats statiques auto-signés (pour localhost) dans le dossier `/sso/certs`:

```
openssl req -x509 -new -keyout root.key -out root.cer -config conf/root.cnf
openssl req -nodes -new -keyout server.key -out server.csr -config conf/server.cnf
openssl x509 -days 825 -req -in server.csr -CA root.cer -CAkey root.key -set_serial 123 -out server.cer -extfile conf/server.cnf -extensions x509_ext
```

* Renseigner les variables d'environnement:

```
cp sso/keycloak.env.sample sso/keycloak.env
cp sso/gatekeeper/keycloak-gatekeeper.conf.sample sso/gatekeeper/keycloak-gatekeeper.conf
```

* [Reverse Proxy Traefik](https://www.traefik.io/):

Configuration dans `reverse-proxy/traefik.toml`.

```
docker-compose -f reverse-proxy/docker-compose.yml up -d
```

* [Gatekeeper SSO Keycloak](https://www.keycloak.org/):

Utile pour ne pas partager le client_secret de OpenIDConnect entre keycloak et les clients.

```
docker-compose -f sso/gatekeeper/docker-compose.yml up -d
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