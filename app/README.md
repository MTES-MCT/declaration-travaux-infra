# RIEAU INFRA - Application

> Installation de l'application RIEAU

## Développement

### Prérequis

* Docker 19.03+

### Dev

* Docker-compose 1.24+
* [Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/) 1.12+

## Déploiements

### En dev

```shell
docker-compose -f app/docker-compose.yml up -d --build
```

L'application est disponible sur [rieau.docker.localhost](https://rieau.docker.localhost).

* Tester manuellement l'intégration de l'API (backend) avec le SSO Keycloak:

Prérequis: [jq](https://stedolan.github.io/jq/).

Récupération d'un token valide (cf. application.properties.sample):

```shell
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

```shell
curl -k -H "Authorization: Bearer $KC_ACCESS_TOKEN" -v https://rieau.docker.localhost/api/depots
```

### En prod

* Sélectionner le contexte du namespace: `kubens rieau`

* Installer l'application avec les manifests:

```shell
kubectl create -f app/
```
