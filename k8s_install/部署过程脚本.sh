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
# 查看名称为 “e2e” 的用户的密码
$ kubectl config view -o jsonpath='{.users[?(@.name == "e2e")].user.password}'
kubectl cluster-info
kubectl get replicaset
kubectl get node --show-labels
kubectl apply -f deployment.yaml --record

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
kubectl apply -k ./

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
kubectl create --validate -f mypod.yaml
# 下面几个命令用于查看相关组件
kubectl get ingress -o wide -A
kubectl get secret -o wide -A
kubectl get deploy -o wide -A
kubectl get svc -o wide -A
kubectl get pod -o wide -A
kubectl get ingress -A
kubectl get pods --selector=name=nginx,type=frontend
kubectl get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx --watch
# 获取命名空间下所有运行中的 pod
$ kubectl get pods --field-selector=status.phase=Running
kubectl logs -f -n ingress-nginx   nginx-ingress-controller-57c9688cff-xtdcx
kubectl exec nginx-76d945c598-bjn4h -it -- /bin/sh
确认当前user信息
kubectl config current-context
kubectl config use-context my-cluster-name  # 设置默认的上下文为 my-cluster-name
kubectl config get-contexts


#卸载 要卸载kubeadm功能。
kubectl drain <node name> --delete-local-data --force --ignore-daemonsets
kubectl delete node <node name>
# 然后，在要删除的节点上，重置所有kubeadm安装状态：
kubeadm reset

# node 和集群交互
kubectl cordon my-node                                                # 标记节点 my-node 为不可调度
kubectl drain my-node                                                 # 准备维护时，排除节点 my-node
kubectl uncordon my-node                                              # 标记节点 my-node 为可调度
kubectl top node my-node                                              # 显示给定节点的度量值
kubectl cluster-info                                                  # 显示 master 和 service 的地址
kubectl cluster-info dump                                             # 将集群的当前状态转储到标准输出
kubectl cluster-info dump --output-directory=/path/to/cluster-state   # 将集群的当前状态转储到目录 /path/to/cluster-state

kubectl logs my-pod                                 # 转储 pod 日志到标准输出
kubectl logs my-pod -c my-container                 # 有多个容器的情况下，转储 pod 中容器的日志到标准输出
kubectl logs -f my-pod                              # pod 日志流向标准输出
kubectl logs -f my-pod -c my-container              # 有多个容器的情况下，pod 中容器的日志流到标准输出
kubectl run -i --tty busybox --image=busybox -- sh  # 使用交互的 shell 运行 pod
kubectl attach my-pod -i                            # 关联到运行中的容器
kubectl port-forward my-pod 5000:6000               # 在本地监听 5000 端口，然后转到 my-pod 的 6000 端口
kubectl exec my-pod -- ls /                         # 1 个容器的情况下，在已经存在的 pod 中运行命令
kubectl exec my-pod -c my-container -- ls /         # 多个容器的情况下，在已经存在的 pod 中运行命令
kubectl top pod POD_NAME --containers               # 显示 pod 及其容器的度量
kubectl --namespace monitoring port-forward svc/prometheus-k8s 9090
kubectl create deployment java-demo --image=yueming33990/java-demo --dry-run -o yaml > deploy.yaml
kubectl expose deployment java-demo --port=80 --target-port=8080 --type=NodePort -o yaml --dry-run > svc.yaml
kubectl label nodes <node-name> <label-key>=<label-value>

# 查看、查找资源
# 具有基本输出的 get 命令
kubectl get services                          # 列出命名空间下的所有 service
kubectl get pods --all-namespaces             # 列出所有命名空间下的 pod
kubectl get pods -o wide                      # 列出命名空间下所有 pod，带有更详细的信息
kubectl get deployment my-dep                 # 列出特定的 deployment
kubectl get pods --include-uninitialized      # 列出命名空间下所有的 pod，包括未初始化的对象

# 有详细输出的 describe 命令
kubectl describe nodes my-node
kubectl describe pods my-pod

kubectl get services --sort-by=.metadata.name # List Services Sorted by Name

# 根据重启次数排序，列出所有 pod
kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'

# 查询带有标签 app=cassandra 的所有 pod，获取它们的 version 标签值
kubectl get pods --selector=app=cassandra rc -o \
  jsonpath='{.items[*].metadata.labels.version}'

# 获取命名空间下所有运行中的 pod
kubectl get pods --field-selector=status.phase=Running
kubectl get pods -w -l app=nginx

# 所有所有节点的 ExternalIP
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'

# 列出输出特定 RC 的所有 pod 的名称
# "jq" 命令对那些 jsonpath 看来太复杂的转换非常有用，可以在这找到：https://stedolan.github.io/jq/
sel=${$(kubectl get rc my-rc --output=json | jq -j '.spec.selector | to_entries | .[] | "\(.key)=\(.value),"')%?}
echo $(kubectl get pods --selector=$sel --output=jsonpath={.items..metadata.name})

# 检查那些节点已经 ready
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}' \
 && kubectl get nodes -o jsonpath="$JSONPATH" | grep "Ready=True"

# 列出某个 pod 目前在用的所有 Secret
kubectl get pods -o json | jq '.items[].spec.containers[].env[]?.valueFrom.secretKeyRef.name' | grep -v null | sort | uniq

# 列出通过 timestamp 排序的所有 Event
kubectl get events --sort-by=.metadata.creationTimestamp

# 修补资源
kubectl patch node k8s-node-1 -p '{"spec":{"unschedulable":true}}' # 部分更新节点
# 更新容器的镜像，spec.containers[*].name 是必需的，因为它们是一个合并键
kubectl patch pod valid-pod -p '{"spec":{"containers":[{"name":"kubernetes-serve-hostname","image":"new image"}]}}'
# 使用带有数组位置信息的 json 修补程序更新容器镜像
kubectl patch pod valid-pod --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"new image"}]'
# 使用带有数组位置信息的 json 修补程序禁用 deployment 的 livenessProbe
kubectl patch deployment valid-deployment  --type json   -p='[{"op": "remove", "path": "/spec/template/spec/containers/0/livenessProbe"}]'
# 增加新的元素到数组指定的位置中
kubectl patch sa default --type='json' -p='[{"op": "add", "path": "/secrets/1", "value": {"name": "whatever" } }]'

# 更新资源
kubectl rolling-update frontend-v1 -f frontend-v2.json           # 滚动更新 pod：frontend-v1
kubectl rolling-update frontend-v1 frontend-v2 --image=image:v2  # 变更资源的名称并更新镜像
kubectl rolling-update frontend --image=image:v2                 # 更新 pod 的镜像
kubectl rolling-update frontend-v1 frontend-v2 --rollback        # 中止进行中的过程
cat pod.json | kubectl replace -f -                              # 根据传入标准输入的 JSON 替换一个 pod

# 强制替换，先删除，然后再重建资源。会导致服务中断。
kubectl replace --force -f ./pod.json

# 为副本控制器（rc）创建服务，它开放 80 端口，并连接到容器的 8080 端口
kubectl expose rc nginx --port=80 --target-port=8000

# 更新单容器的 pod，将其镜像版本（tag）更新到 v4
kubectl get pod mypod -o yaml | sed 's/\(image: myimage\):.*$/\1:v4/' | kubectl replace -f -

kubectl label pods my-pod new-label=awesome                      # 增加标签
kubectl annotate pods my-pod icon-url=http://goo.gl/XXBTWq       # 增加注释
kubectl autoscale deployment foo --min=2 --max=10                # 将名称为 foo 的 deployment 设置为自动扩缩容

# 删除资源
kubectl delete -f ./pod.json                                              # 使用 pod.json 中指定的类型和名称删除 pod
kubectl delete pod,service baz foo                                        # 删除名称为 "baz" 和 "foo" 的 pod 和 service
kubectl delete pods,services -l name=myLabel                              # 删除带有标签 name=myLabel 的 pod 和 service
kubectl delete pods,services -l name=myLabel --include-uninitialized      # 删除带有标签 name=myLabel 的 pod 和 service，包括未初始化的对象
kubectl -n my-ns delete po,svc --all       

# 缩放资源
kubectl scale --replicas=3 rs/foo                                 # 缩放名称为 'foo' 的 replicaset，调整其副本数为 3
kubectl scale --replicas=3 -f foo.yaml                            # 缩放在 "foo.yaml" 中指定的资源，调整其副本数为 3
kubectl scale --current-replicas=2 --replicas=3 deployment/mysql  # 如果名称为 mysql 的 deployment 目前规模为 2，将其规模调整为 3
kubectl scale --replicas=5 rc/foo rc/bar rc/baz                   # 缩放多个副本控制器

# 编辑资源
kubectl edit svc/docker-registry                      # 编辑名称为 docker-registry 的 service
KUBE_EDITOR="nano" kubectl edit svc/docker-registry   # 使用 alternative 编辑器

# 如果带有该键和效果的污点已经存在，则将按指定的方式替换其值
kubectl taint nodes foo dedicated=special-user:NoSchedule

# 应用滚动升级
kubectl apply -f springboot-example-deployment.yaml
kubectl get pod -l app=java-demo -w
kubectl rollout history deployment/java-demo  #查看应用历史版本
kubectl rollout undo deployment/java-demo   #回滚到之前的版本
kubectl rollout undo deployment/java-demo --to-revision=1   #回到指定的历史版本
kubectl rollout status deploy/java-demo    #查看发布情况

# 更新资源
kubectl rolling-update frontend-v1 -f frontend-v2.json           # 滚动更新 pod：frontend-v1
kubectl rolling-update frontend-v1 frontend-v2 --image=image:v2  # 变更资源的名称并更新镜像
kubectl rolling-update frontend --image=image:v2                 # 更新 pod 的镜像
kubectl rolling-update frontend-v1 frontend-v2 --rollback        # 中止进行中的过程
cat pod.json | kubectl replace -f -                              # 根据传入标准输入的 JSON 替换一个 pod

# 强制替换，先删除，然后再重建资源。会导致服务中断。
kubectl replace --force -f ./pod.json

# 为副本控制器（rc）创建服务，它开放 80 端口，并连接到容器的 8080 端口
kubectl expose rc nginx --port=80 --target-port=8000

# 更新单容器的 pod，将其镜像版本（tag）更新到 v4
kubectl get pod mypod -o yaml | sed 's/\(image: myimage\):.*$/\1:v4/' | kubectl replace -f -

kubectl label pods my-pod new-label=awesome                      # 增加标签
kubectl annotate pods my-pod icon-url=http://goo.gl/XXBTWq       # 增加注释
kubectl autoscale deployment foo --min=2 --max=10                # 将名称为 foo 的 deployment 设置为自动扩缩容

kubectl get ingress
kubectl describe svc/mysql
kubectl describe endpoints/mysql
#手动创建无头服务及endpoint，引入外部数据库，然后通过k8s集群中的域名解析服务访问，访问的主机名格式为：[svc_name].[namespace_name].svc.cluster.local。

# Kubernetes 基础对象清理
kubectl get pods --all-namespaces -o wide | grep Evicted | awk '{print $1,$2}' | xargs -L1 kubectl delete pod -n
kubectl get pods --all-namespaces -o wide | grep Error | awk '{print $1,$2}' | xargs -L1 kubectl delete pod -n
kubectl get pods --all-namespaces -o wide | grep Completed | awk '{print $1,$2}' | xargs -L1 kubectl delete pod -n
# 清理没有被使用的 PV
kubectl describe -A pvc | grep -E "^Name:.*$|^Namespace:.*$|^Used By:.*$" | grep -B 2 "<none>" | grep -E "^Name:.*$|^Namespace:.*$" | cut -f2 -d: | paste -d " " - - | xargs -n2 bash -c 'kubectl -n ${1} delete pvc ${0}'
# 清理没有被绑定的 PVC
kubectl get pvc --all-namespaces | tail -n +2 | grep -v Bound | awk '{print $1,$2}' | xargs -L1 kubectl delete pvc -n

# 隔离你的集群中除 4 个节点以外的所有节点
kubectl cordon <node-name>
kubectl get pdb zk-pdb
# 使用 kubectl drain 来隔离和腾空 zk-0 Pod 调度所在的节点。
kubectl drain $(kubectl get pod zk-0 --template {{.spec.nodeName}}) --ignore-daemonsets --force --delete-emptydir-data
# 使用 kubectl uncordon 来取消对第一个节点的隔离。
kubectl uncordon kubernetes-node-pb41

# kubectl scale 扩展副本数为 5
kubectl scale sts web --replicas=5
# 将 StatefulSet 缩容回三个副本
kubectl patch sts web -p '{"spec":{"replicas":3}}'
# Patch web StatefulSet 来执行 RollingUpdate 更新策略
kubectl patch statefulset web -p '{"spec":{"updateStrategy":{"type":"RollingUpdate"}}}'
# StatefulSet 来再次的改变容器镜像
kubectl patch statefulset web --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value":"gcr.io/google_containers/nginx-slim:0.8"}]'
# 获取 Pod 来查看他们的容器镜像
for p in 0 1 2; do kubectl get pod "web-$p" --template '{{range $i, $c := .spec.containers}}{{$c.image}}{{end}}'; echo; done
你还可以使用 kubectl rollout status sts/<name> 来查看 rolling update 的状态
# 使用 RollingUpdate 更新策略的 partition 参数来分段更新一个 StatefulSet
kubectl patch statefulset web -p '{"spec":{"updateStrategy":{"type":"RollingUpdate","rollingUpdate":{"partition":3}}}}'
kubectl patch statefulset web --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value":"k8s.gcr.io/nginx-slim:0.7"}]'
# 非级联删除 --cascade=orphan 只删除 StatefulSet 而不要删除它的任何 Pod
kubectl delete statefulset web --cascade=orphan
# 级联删除 
kubectl delete statefulset web
# sts is an abbreviation for statefulset
kubectl delete sts web


# configmap
kubectl create configmap game-config-2 --from-file=game.properties --from-file=ui.properties
kubectl describe cm game-config-2
kubectl get pod/redis configmap/example-redis-config 

# https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/baremetal/deploy.yaml
# 云服务商 https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/cloud/deploy.yaml
使用下面的命令查看 webhook
kubectl get validatingwebhookconfigurations
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission

# 调试问题 
kubectl run -it --rm --restart=Never busybox-test --image=busybox sh
kubectl get pods -l app=java-demo \
    -o go-template='{{range .items}}{{.status.podIP}}{{"\n"}}{{end}}'
for ep in 10.244.2.49:8080 10.244.1.58:8080 10.244.2.48:8080; do
    wget -qO- $ep
done

# 搭建NFS服务
# 服务器端防火墙开放111、662、875、892、2049的 tcp / udp 允许，否则远端客户无法连接
netstat -tnal |grep 111、662、875、892、2049
firewall-cmd --zone=public --add-port=892/tcp --permanent
firewall-cmd --zone=public --add-port=892/udp --permanent
firewall-cmd --reload
firewall-cmd --list-port
 # 安装nfs
yum install -y nfs-utils
# 创建nfs目录
mkdir -p /nfs/data/
mkdir -p /nfs/data/mysql
# 授予权限
chmod -R 777 /nfs/data
# 编辑export文件
vi /etc/exports
  /nfs/data *(insecure,rw,no_root_squash,sync)
# 使得配置生效
exportfs -r
# 查看生效
exportfs
# 启动rpcbind、nfs服务
systemctl restart rpcbind && systemctl enable rpcbind
systemctl start nfs-server && systemctl enable nfs-server
# 查看rpc服务的注册情况
rpcinfo -p localhost
# showmount测试
showmount -e 192.168.1.5
# 报错rpc mount export: RPC: Unable to receive; errno = No route to host
firewall-cmd --add-service=nfs --permanent
firewall-cmd --add-service=rpc-bind --permanent
firewall-cmd --add-service=mountd --permanent


# 客户端安装
yum -y install nfs-utils
systemctl start nfs && systemctl enable nfs 
# 执行以下命令检查 nfs 服务器端是否有设置共享目录
showmount -e 192.168.1.5
# 挂载目录到本机
mkdir -p /nfs/nfsmount
# mount -t nfs $(nfs服务器的IP):/root/nfs_root /root/nfsmount
mount -t nfs 192.168.1.5:/nfs/data /nfs/nfsmount
# 写入一个测试文件
echo "hello nfs server" > /nfs/nfsmount/test.txt


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
systemctl daemon-reload && systemctl restart docker


https://github.com/chinaboy007/kube-prometheus