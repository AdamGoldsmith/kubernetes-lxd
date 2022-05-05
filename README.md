# Deploy Kubernetes on LXD using Ansible + Terraform

## Test environment

All commands were run inside a VMware Ubuntu 22.04 Desktop Virtual Machine.

## Software packages

These are the versions of software used at time of testing

* LXD 5.1 (Installed using snap - if you install this from source you will have to update the `socket` reference in `inv.d/lxd.yml` dynamic inventory to point to `unix:/var/lib/lxd/unix.socket`)
* Ansible core 2.12.5
  * community.crypto.openssh_keypair plugin (install with `ansible-galaxy collection install community.crypto`)
  * community.general.lxd (install with `ansible-galaxy collection install community.general`)
  * ansible.posix collection (install with `ansible-galaxy collection install ansible.posix`)
* Terraform 1.1.9

## Running the code (TL;DR)

***Note***: _Don't forget to run_ `lxd init` _on the host first if it is a brand new instance!_

1. Clone repo
1. `cd ansible`
1. `ansible-playbook playbooks/prepare_once.yml`
1. `cd ../terraform/kubernetes/master`
1. `terraform init`
1. `terraform apply`
1. `cd ../terraform/kubernetes/worker`
1. `terraform init`
1. `terraform apply`
1. `cd ../../../ansible`
1. `ansible cluster -m ping`
1. `ansible-playbook playbook/site.yml`

## TODO

1. Update README :-)

## References

I used these blogs as a basis for this repo:
* https://ubuntu.com/blog/running-kubernetes-inside-lxd (Soon realised conjure-up is not being maintained)
* https://sleeplessbeastie.eu/2020/10/07/how-to-install-kubernetes-on-lxd (main source of reference)

This blog helped me select the correct LXD configuration & LXC container settings:
* https://blog.canutethegreat.com/portable-devops-platform-gitlab-in-an-lxd-container-db2850224caf
