# RIEAU INFRA - SSO

> Installation du SSO [Keycloak](https://www.keycloak.org/)

## Développement

### Prérequis

* Docker 19.03+

### Dev

* Docker-compose 1.24+
* [Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/) 1.12+

## Déploiements

### En dev

```shell
docker-compose -f sso/docker-compose.yml up -d --build
```

L'administration du SSO est disponible sur [rieau.docker.localhost/auth](https://rieau.docker.localhost/auth).

### En prod

* Sélectionner le contexte du namespace: `kubens rieau`

* Installer le SSO keycloak avec helm:

Installer le stockage local:

```shell
kubectl create -f k8s/pv-claims.yml
```

Importer le realm-rieau.json en secret:

```shell
kubectl create secret generic realm-rieau-secret --from-file=realm-rieau.json
```

* Ajout du dépôt codecentric:

```shell
helm repo add codecentric https://codecentric.github.io/helm-charts --tiller-namespace rieau
```

Installer le [chart](https://github.com/codecentric/helm-charts/tree/master/charts/keycloak) de keycloak avec base de données PostgreSQL:

```shell
helm install \
--name keycloak codecentric/keycloak \
--values k8s/helm-values.yml \
--tls \
--tiller-namespace rieau \
--set-string postgresql.postgresqlPassword='<secret-password>' \
--set-string keycloak.password='<secret-password>'
```

Pour récupérer le mot de passe de admin initialisé au départ:

```shell
kubectl get secret --namespace rieau keycloak-http -o jsonpath="{.data.password}" | base64 --decode; echo
```

Mettre à jour des values:

```shell
helm upgrade --tls --tiller-namespace rieau --set <key>=<value> -f sso/helm-values.yml keycloak codecentric/keycloak
```
