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

* Installer le Mail serveur avec les manifests (cf. [tuto](https://github.com/tomav/docker-mailserver/wiki/Using-in-Kubernetes)):

Importer le user par défaut et son alias en secret:

```shell
kubectl create secret generic mail-user-secret --from-file=postfix-accounts.cf,postfix-virtual.cf
```

Installer le chart de [docker-mailserver](https://hub.helm.sh/charts/funkypenguin/docker-mailserver):

```shell
kubectl create -f k8s/
```
