# RIEAU INFRA - Reverse proxy HTTP

> Installation du Reverse proxy HTTP

## Développement

### Prérequis

* Docker 19.03+

### Dev

* Docker-compose 1.24+
* [Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/) 1.12+

## Déploiements

### En dev

* Remplacer le vrai domaine: `cohesion-territoires.gouv.fr` par le domaine de dev `docker.localhost` dans tous les fichiers de conf.

* Générer les certificats statiques auto-signés (pour le domaine localhost) dans le dossier `reverse-proxy/certs`:

```shell
cd reverse-proxy/certs/
openssl req -x509 -new -keyout root.key -out root.cer -config conf/root.cnf
openssl req -nodes -new -keyout server.key -out server.csr -config conf/server.cnf
openssl x509 -days 3650 -req -in server.csr -CA root.cer -CAkey root.key -set_serial 123 -out server.cer -extfile conf/server.cnf -extensions x509_ext
```

Copier server.cer dans `app`.

* Renseigner les variables d'environnement:

```shell
cp sso/keycloak.env.sample sso/keycloak.env
cp app/application.properties.sample app/application.properties
cp app/app.env.sample app/app.env
```

* [Reverse Proxy Traefik](https://www.traefik.io/):

Configuration dans `reverse-proxy/traefik.toml`.

```shell
docker-compose -f reverse-proxy/docker-compose.yml up -d --build
```

La consultation de la Web GUI du reverse proxy est disponible sur [rieau.docker.localhost/traefik](https://rieau.docker.localhost/traefik).

### En prod

* Créer un namespace rieau: `kubectl create ns rieau`
* Installer [kubectx](https://github.com/ahmetb/kubectx/)
* Sélectionner le contexte du namespace: `kubens rieau`

* Déploiement de Traefik comme Ingress controller (cf. [tuto](https://www.cerenit.fr/blog/kubernetes-ovh-traefik-cert-manager-secrets/) et [doc traefik](https://docs.traefik.io/user-guide/kubernetes/))

* Pour pouvoir gérer les certificats avec Let'Encrypt sans avoir à stocker l'acme.json dans un volume mais comme un secret, il faut installer [cert-manager](https://cert-manager.readthedocs.io/en/latest/getting-started/install/kubernetes.html) depuis les manifests:

```shell
kubectl create namespace cert-manager
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.9.1/cert-manager.yaml
```

* [Générer le secret](https://docs.traefik.io/user-guide/kubernetes/#basic-authentication) pour l'authentification basique à l'api:

```shell
sudo apt install apache2-utils
htpasswd -c ./auth ???
kubectl create secret generic traefik-api-secret --from-file auth
```

* Installer traefik avec les manifests: `kubectl create -f traefik/`
