VBoxManage internalcommands  sethduuid  "D:\soft\vm\node1\centos7-9.vdi"



master  192.168.1.9
node1  192.168.1.10
node2  192.168.1.11

# 修改 hostname
hostnamectl set-hostname master01
# 查看修改结果
hostnamectl status
# 设置 hostname 解析
echo "127.0.0.1   $(hostname)" >> /etc/hosts


# 只在 master 节点执行
# 替换 x.x.x.x 为 master 节点实际 IP（请使用内网 IP）
# export 命令只在当前 shell 会话中有效，开启新的 shell 窗口后，如果要继续安装过程，请重新执行此处的 export 命令
export MASTER_IP=192.168.1.9
# 替换 apiserver.demo 为 您想要的 dnsName
export APISERVER_NAME=apiserver.demo
# Kubernetes 容器组所在的网段，该网段安装完成后，由 kubernetes 创建，事先并不存在于您的物理网络中
export POD_SUBNET=10.100.0.1/16
echo "${MASTER_IP}    ${APISERVER_NAME}" >> /etc/hosts
curl -sSL https://kuboard.cn/install-script/v1.21.x/init_master.sh | sh -s 1.21.0

watch kubectl get pod -n kube-system -o wide
kubectl get nodes -o wide
### 驱离k8s-node-1节点上的pod ###
kubectl drain k8s.node1 --delete-local-data --force --ignore-daemonsets
### 删除节点 ###
kubectl delete node k8s.node1
kubectl get componentstatus
kubectl config view
kubectl cluster-info
kubectl get replicaset
kubectl get node --show-labels

kubeadm config images list
### 重置节点 ###
kubeadm reset
# 只在 master 节点执行
kubeadm token create --print-join-command
# --skip-preflight-checks，可以防止每次初始化都去检查配置文件
kubeadm join apiserver.demo:6443 --token 16h42d.01eem3xgw6picahg --discovery-token-ca-cert-hash sha256:ac138daa9c26e58f4d0215365cdf817fb43c438cc724a1a6fad7970d6faf0185 --skip-preflight-checks
kubeadm token list
kubeadm init --kubernetes-version=v1.14.2 --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/16

部署Dashboard 在master节点上执行：
wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
 

kubectl apply -f kubernetes-dashboard.yaml
kubectl get secret --all-namespaces | grep kubernetes-dashboard-admin
kubectl describe secret kubernetes-dashboard-admin-token-jzmzp -n kube-system
kubectl get svc --all-namespaces
kubectl describe svc kubernetes-dashboard -n kubernetes-dashboard

端口转发
# Change mongo-75f59d57f4-4nd6q to the name of the Pod
kubectl port-forward mongo-75f59d57f4-4nd6q 28015:27017
kubectl port-forward pods/mongo-75f59d57f4-4nd6q 28015:27017
kubectl port-forward deployment/mongo 28015:27017
kubectl port-forward replicaset/mongo-75f59d57f4 28015:27017
kubectl port-forward service/mongo 28015:27017

https://kubernetes.io/zh/docs/tasks/access-application-cluster/service-access-application-cluster/
kubectl get deployments hello-world
kubectl describe deployments hello-world
kubectl get replicasets
kubectl describe replicasets
kubectl expose deployment hello-world --type=NodePort --name=example-service
kubectl describe services example-service
kubectl get pods --selector="run=load-balancer-example" --output=wide
kubectl delete services example-service
kubectl delete deployment hello-world

/var/lib/kubelet/config.yaml
/var/lib/kubelet/kubeadm-flags.env

k8s.gcr.io/kube-apiserver:v1.21.1
k8s.gcr.io/kube-controller-manager:v1.21.1
k8s.gcr.io/kube-scheduler:v1.21.1
k8s.gcr.io/kube-proxy:v1.21.1
k8s.gcr.io/pause:3.4.1
k8s.gcr.io/etcd:3.4.13-0
k8s.gcr.io/coredns/coredns:v1.8.0


kubectl create secret docker-registry docker-regsitry-auth --docker-username=develop --docker-password=Dev888888 --docker-server=harbor.cn
kubectl get deployment java-demo
kubectl get pod -l app=java-demo
kubectl describe pod java-demo-6cd76ccd78-8c6pp
kubectl get ing java-demo

https://www.pianshen.com/article/30471096773/

# ingress 部署
crictl pull docker.io/xzxiaoshan/nginx-ingress-controller:0.30.0
# 生成证书
openssl genrsa -out ingress-key.pem 2048 
openssl req -new -x509 -key ingress-key.pem -out ingress.pem -subj /C=CN/ST=GuangXi/L=Nanning/O=Yunlang/OU=Yunlang/CN=www.yunlang.com
# 注意这里一定要用--key和--cert方式，不建议你用--from-file方式（除非你已经很了解secret不然有可能坑的你家都不知道在哪）
kubectl create secret tls ingress-secret --key ingress-key.pem --cert ingress.pem 
kubectl apply -f mandatory.yaml
kubectl apply -f ingress-nginx.yaml
# 下面几个命令用于查看相关组件
kubectl get ingress -o wide -A
kubectl get secret -o wide -A
kubectl get deploy -o wide -A
kubectl get svc -o wide -A
kubectl get pod -o wide -A
kubectl get ingress -A
kubectl get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx --watch
kubectl logs -f -n ingress-nginx   nginx-ingress-controller-57c9688cff-xtdcx


# 应用滚动升级
kubectl apply -f springboot-example-deployment.yaml
kubectl get pod -l app=java-demo -w
kubectl rollout history deployment/java-demo  #查看应用历史版本
kubectl rollout undo deployment/java-demo   #回滚到之前的版本
kubectl rollout undo deployment/java-demo --to-revision=1   #回到指定的历史版本
kubectl rollout status deploy/java-demo    #查看发布情况


# 下载并安装sealos, sealos是个golang的二进制工具，直接下载拷贝到bin目录即可, release页面也可下载
$ wget -c https://sealyun.oss-cn-beijing.aliyuncs.com/latest/sealos && \
    chmod +x sealos && mv sealos /usr/bin 

# 下载离线资源包
$ wget -c https://sealyun.oss-cn-beijing.aliyuncs.com/2fb10b1396f8c6674355fcc14a8cda7c-v1.20.0/kube1.20.0.tar.gz

# 安装一个三master的kubernetes集群
$ sealos init --passwd 'qiujiabao' \
	--master 192.168.56.101 \
	--node 192.168.56.102 --node 192.168.56.103 \
	--pkg-url /data/k8s/install/kube1.20.0.tar.gz \
	--version v1.20.0


sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://6ikg7eqs.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
