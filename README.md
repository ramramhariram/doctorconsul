# HashiCorp Consul Docker-Compose Test Environment

This repo contains a full featured environment for setting up and testing HashiCorp Consul Enterprise. While it is not directly intended to be used for Consul demos, the entire environment is consistently built within ~2 minutes.

**Details**:

* Heavy focus on implementing and testing the latest Consul features.
* Rapidly changing, constant work-in-progress.
* [Doctor Consul Helper](https://github.com/joshwolfer/doctorconsul-helper) tool for easily collecting troubleshooting data.

**Software Versions used in this environment**:

* Consul: 1.15.2 (Enterprise)
* Envoy: 1.25.1
* FakeService: 0.25.0
* Prometheus: 2.42.0

#### Consul Features

* Consul Enterprise
* Admin Partitions Enabled
* Best-Practice Security Features Enabled
  * TLS encryption on all nodes.
  * TLS Verify on everything.
  * Gossip Encryption enabled.
* UI Visualizations turned on for all mesh applications.
  * Prometheus servers:
    * k3d: prometheus-server
    * docker: prometheus
* PKI / Certificates
  * Auto encrypt enabled (automatic distribution of Consul Client RPC certificates)
* ACLs enabled w/ tokens and policies applied.
* External OIDC Authentication:
  * OIDC enabled with Auth0 service.

# Environment Pre-Requirements

### Docker Compose

* Environment requires Docker-Compose
  * **!! MAC M1 USERS !!** : The Docker images referenced in the `docker-compose.yml` are AMD64, not ARM64.
  * M1 user will need to build your own ARM64 consul+envoy images using [https://github.com/joshwolfer/convoy-build](https://github.com/joshwolfer/convoy-build) and modify the `docker-compose.yml` file to reflect these new images.

### HashiCorp Consul Enterprise

* HashiCorp Consul Enterprise license required.
  * Place in `./license`
* For the  `./k3d-config.sh` script to execute properly, you also need to - 
  * Have a local version of Consul on the latest ENT version
  * Create a /tokens directory, CA and other files will be copied into this directory.
* Generate Consul PKI Root certs and Consul Server RPC certs
  * Self-signed certificates have already been provided in this repo.
  * If they need to be regenerated:
    * From within `./certs`
      ```
      consul tls ca create -days=3650
      consul tls cert create -server -dc=dc1 -additional-dnsname=consul-server1-dc1 -days=1825
      consul tls cert create -server -dc=dc2 -additional-dnsname=consul-server1-dc2 -days=1825
      chmod 644 *
      ```

### Auth0 (Optional)

* Create Auth0 account with appropriate configuration
  * Required only for the OIDC authentication in this Consul environment.
  * Details on how to do that will come later. For now reference this [Learn Guide](https://https://developer.hashicorp.com/consul/tutorials/datacenter-operations/single-sign-on-auth0?in=consul%2Fdatacenter-operations).
    * NOTE: The guide is outdated and Auth0 has since changed the locations for a few of the components. Everything is still possible to complete using this guide, but the locations of the config params are in different places on the leftside bar. Specifically:
      * `Applications` > `Applications` > Default
      * `Auth Pipeline` > `Rules`

### K3d

* K3d is a dockerized version of K3s, which is a simple version of Rancher Kubernetes.
* K3d is used for the platform Consul on Kubernetes portion of this environment.
* Installation instructions [HERE](https://github.com/k3d-io/k3d#get)

### Kubectl

* Installation instructions [HERE](https://kubernetes.io/docs/tasks/tools/)

### Helm

* Helm is used to configure and install Consul into Kubernetes.
* Installation instructions [HERE](https://helm.sh/docs/intro/install/)

### k9s (Optional)

* Highly recommended to get k9s to make navigating Kubernetes a lot easier.
* [https://github.com/derailed/k9s/releases](https://github.com/derailed/k9s/releases)

### HashiCorp consul-k8s CLI

* Installation instructions [HERE](https://developer.hashicorp.com/consul/docs/k8s/installation/install-cli#install-the-latest-version)

# Instructions to Execute Environment

### Startup Script

* Startup script (Cleans out previous containers, k3d clusters, and peering tokens)
  * `./start.sh`
  * `./start.sh -root`
  * `./start.sh -custom`

The start script has three modes. By default the environment will assign Consul ACL tokens to most of the agents and proxies using the principle of least privilege (secure mode).

For more details, see the ACL docs belows.

### Configuration Script

* Configure the core environment using the `post-config.sh` script:
  * `./post-config.sh`
  * `./post-config.sh -k3d`

The `-k3d` argument automatically runs the `k3d-config.sh` script with no arguments.

### k3d configuration script (optional)

* Build K3d Kubernetes cluster using the `k3d-config.sh` script:
  * `./k3d-config.sh -eksonly`
  * `./k3d-config.sh -eksonly -nopeer`

The `-nopeer` option launches the k3d cluster with no peering. This is useful when it is desired to launch only the k3d cluster without the rest of the Doctor Consul environment.

### Delete Environment

When the docker-compose windows is sent control+c, most of the docker images will shutdown. The k3d environment continues to run. To destroy everything, including the k3d containers, run the kill script:

* `./kill.sh`
* `./kill.sh -k3d`   (Only destroy the k3d clusters so they can be rebuilt without tearing down the entire docker environment.)

# Documentation

The Doctor Consul architecture (including visual diagram) and details are [HERE](docs/architecture.md)

### Consul Specifics:

* Network Overview and Chart: [HERE](docs/network.md)
* Admin Partitions, Namespaces, & Cluster Peering Details: [HERE](docs/consul-structure.md)
* Consul Client Details: [HERE](docs/consul-clients.md)
* ACL Authentication, Policies, Roles, and ACL Tokens: [HERE](docs/acl-everything.md)
* UI Visualizations (Prometheus): [HERE](docs/ui-viz.md)

### Zork Control Script

The `./zork.sh` script is a menu driven system to control various aspects of the Doctor Consul environment.
Docs: [HERE](docs/zork.md)

### Doctor Consul Applications

Several "fake service" applications are deployed in the Doctor Consul environment. These applications are used to demonstrate and observe various Consul service mesh behaviors, such as advanced routing and service failover.

Docs: [HERE](docs/fake-service.md)

# Future Goals

### Key Architecture

* Add ECS cluster
  * Need to figure out how to expose local networking to ECS. This may not be practical for a DC lab. We'll see.
* Find someone that is a Terraform boss and launch an HCP cluster with integration.
* Add AWS Lambda connected via Consul Terminating Gateway.

### PKI / Certificates

HashiCorp Vault will eventually be implemented in the future as the Certificate Authority for the Consul Connect Service Mesh.

* The Vault server is currently commented out in the docker-compose file.
* Add Vault as the ConnectCA
* Use a unique CA keyset for each DC (`DC1` / `DC2`)
  * This is how separately managed clusters would work in the real world.

### Authentication Methods

* Add JWT authentication

### Transparent Proxy on VM and Kube

* Add some transparent proxies + fake service.
* Figure out VM Consul DNS config:
  * systemd-resolved:

  ```
  [Resolve]
  DNS=127.0.0.1:8600
  Domains=~consul
  ```
