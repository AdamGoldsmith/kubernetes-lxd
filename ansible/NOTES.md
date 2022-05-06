### Useful commands

kubectl --kubeconfig /etc/kubernetes/admin.conf cluster-info
kubectl --kubeconfig /etc/kubernetes/admin.conf get nodes
kubectl --kubeconfig /etc/kubernetes/admin.conf get pods --all-namespaces
kubectl --kubeconfig /etc/kubernetes/admin.conf logs <POD> -n kube-system