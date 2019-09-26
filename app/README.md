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
curl -k -H "Authorization: Bearer $KC_ACCESS_TOKEN" -v https://rieau.docker.localhost/api/dossiers
```

### En prod

* Sélectionner le contexte du namespace: `kubens rieau`

* Installer le stockage local:

```shell
mkdir -p $HOME/data/app/db
mkdir -p $HOME/data/app/files
kubectl create -f app/storage/
```

* Installer la base de données avec Helm:

```shell
helm install --name db stable/postgresql --tls --tiller-namespace rieau --values app/db/helm-values.yml --set-string postgresqlPassword='<secret>' --set-string global.postgresql.postgresqlPassword='<secret>'
```

* Pour se connecter à la base de données:

```shell
export POSTGRES_PASSWORD=$(kubectl get secret --namespace rieau db-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode)
kubectl run db-postgresql-client --rm --tty -i --restart='Never' --namespace rieau --image docker.io/bitnami/postgresql:11.5.0-debian-9-r26 --env="PGPASSWORD=$POSTGRES_PASSWORD" --command -- psql --host db-postgresql -U postgres -p 5432
```

* Générer les secrets d'accès à la base de données et à keycloak:

```shell
kubectl create secret generic app-db-secret --from-literal=username=rieau --from-literal=password='<password>'
kubectl create secret generic keycloak-app-secret --from-literal=secret='<secret>'
kubectl create secret generic minio-app-secret --from-literal=accesskey='<secret>' --from-literal=secretkey='<secret>'
```

* Installer le serveur de fichiers Minio avec Helm:

```shell
helm install --name minio stable/minio --tls --tiller-namespace rieau --values app/files/helm-values.yml
```

* Installer l'application avec les manifests:

```shell
kubectl create -f app/app/
```

* Installer la demo avec les manifests:

```shell
kubectl create -f app/demo/
```
