# RIEAU INFRA

[![CircleCI](https://circleci.com/gh/MTES-MCT/rieau-infra/tree/master.svg?style=svg)](https://circleci.com/gh/MTES-MCT/rieau-infra/tree/master)

> Infrastructure de déploiement de RIEAU

## Développement

### Prérequis

* Docker 19.03+

### Dev

* Docker-compose 1.24+
* [Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/) 1.12+

## Déploiements

### Dev

* Remplacer le vrai domaine: `cohesion-territoires.gouv.fr` par le domaine de dev `docker.localhost` dans tous les fichiers de conf.

* Générer les certificats statiques auto-signés (pour le domaine localhost) dans le dossier `reverse-proxy/certs`:

```
cd reverse-proxy/certs/
openssl req -x509 -new -keyout root.key -out root.cer -config conf/root.cnf
openssl req -nodes -new -keyout server.key -out server.csr -config conf/server.cnf
openssl x509 -days 3650 -req -in server.csr -CA root.cer -CAkey root.key -set_serial 123 -out server.cer -extfile conf/server.cnf -extensions x509_ext
```

Copier server.cer dans `app`.

* Renseigner les variables d'environnement:

```
cp sso/keycloak.env.sample sso/keycloak.env
cp app/application.properties.sample app/application.properties
cp app/app.env.sample app/app.env
```

* [Reverse Proxy Traefik](https://www.traefik.io/):

Configuration dans `reverse-proxy/traefik.toml`.

```
docker-compose -f reverse-proxy/docker-compose.yml up -d --build
```

La consultation de la Web GUI du reverse proxy est disponible sur [rieau.docker.localhost/traefik](https://rieau.docker.localhost/traefik).

* [SSO Keycloak](https://www.keycloak.org/):

```
docker-compose -f sso/docker-compose.yml up -d --build
```

L'administration du SSO est disponible sur [rieau.docker.localhost/auth](https://rieau.docker.localhost/auth).

* App (UI+API):

```
docker-compose -f app/docker-compose.yml up -d --build
```

L'application est disponible sur [rieau.docker.localhost](https://rieau.docker.localhost).

* Tester manuellement l'intégration de l'API (backend) avec le SSO Keycloak:

Prérequis: [jq](https://stedolan.github.io/jq/).

Récupération d'un token valide (cf. application.properties.sample):

```
KC_REALM=rieau
KC_USERNAME=jean.martin
KC_PASSWORD=
KC_CLIENT=rieau-api
KC_CLIENT_SECRET=
KC_URL="https://sso.rieau.docker.localhost/auth"

# Request Tokens for credentials
KC_RESPONSE=$( \
   curl -k -v \
        -d "username=$KC_USERNAME" \
        -d "password=$KC_PASSWORD" \
        -d 'grant_type=password' \
        -d "client_id=$KC_CLIENT" \
        -d "client_secret=$KC_CLIENT_SECRET" \
        "$KC_URL/realms/$KC_REALM/protocol/openid-connect/token" \
    | jq .
)

KC_ACCESS_TOKEN=$(echo $KC_RESPONSE| jq -r .access_token)
KC_ID_TOKEN=$(echo $KC_RESPONSE| jq -r .id_token)
KC_REFRESH_TOKEN=$(echo $KC_RESPONSE| jq -r .refresh_token)
```

Test d'une ressource, par exemple `/depots`:

```
curl -k -H "Authorization: Bearer $KC_ACCESS_TOKEN" -v https://rieau.docker.localhost/api/depots
```

* Backups:

Renseigner les variables d'environnement:

```
cp backup/backup.env.sample backup/backup.env
```

```
./backup/backup.sh
```

Restore:

```
./backup/restore.sh
```

### Prod

* Administration du cluster [Kubernetes](https://kubernetes.io) avec [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/).

* Déploiements des pods par [kubectl](https://kubernetes.io/docs/reference/kubectl/kubectl/).