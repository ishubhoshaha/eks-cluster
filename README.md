# eks-cluster
This repo will deploy production ready AWS EKS cluster using terraform.
### Provisioning EKS Cluster
- Clone the repo 
```cython
  git clone https://github.com/ishubhoshaha/eks-cluster.git
```
- Go to `eks-cluster` directory and initialize terraform
```cython
  cd eks-cluster
  terraform init
```
- Create terraform workspace. Possible value `dev`, `uat`, `prod`
```cython
  terraform workspace create dev
  terraform workspace select dev
```
- Now deploy infra
```cython
  terraform apply
```
**Following resources will be created once you apply terraform**
- NETWORK
    - VPC
    - Internet Gateway
    - Public Subnet
    - Private Subnet
    - Security Group for Cluster
    - Security Group for Worker Node
    - NAT Gateway
    - Private Route Table
        - Add route to NAT Gateway
        - Associate all private subnet to route table
    - Public Route Table
        - Add route to IGW
        - Associate all public subnet to route table
- IAM 
    - IAM Role for EKS CLuster Node
    - IAM Role for EKS Worker Node
    
- EKS Cluster
- AutoScale
- Keypair
- Launch Template


### Connecting to your EKS Cluster
Now that we have all the resources needed in AWS, so we can connect to kubernetes cluster from management machine.
- Install kubectl. All the step to install kubectl can be found [here](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html).
- Install AWS CLI. All the step to install kubectl can be found [here](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html). 
- Create `aws-auth-cm.yml`
- Copy the value of `config-map-aws-auth` from terraform output and paste the value into `aws-auth-cm.yml`
- Apply newly created Configmap `kubectl apply -f aws-auth-cm.yml`
- Update kubeconfig for new cluster
```cython
  aws eks --region <region-code> update-kubeconfig --name <cluster_name>
```
- Test your configuration.
```cython
  kubectl get svc
```
- Check worker nodes by running.
```cython
  kubectl get nodes
```

### Make sure:

- Worker Node has the following tags:
    ```cython
    k8s.io/cluster-autoscaler/<cluster-name> = owned
    k8s.io/cluster-autoscaler/enabled = true
    kubernetes.io/cluster/<cluster-name> = owned
    ```
- Security Group of Worker Node has the following tags:
    ```cython
    kubernetes.io/cluster/<cluster-name> = owned
    ```
- Private Subnet has the following tags
  ```cython
   kubernetes.io/cluster/<cluster-name> = shared
  ```
- Attach following permission to the IAM role that attached to the Worker Node
    - AmazonEKSWorkerNodePolicy
    - AmazonEKS_CNI_Policy
    - AmazonEC2ContainerRegistryReadOnly

- Attach following permission to the IAM role that attached to the EKS Cluster Role
  - AmazonEKSClusterPolicy
  - AmazonEKSServicePolicy
  - AmazonEKS_CNI_Policy

- Configure the user data for your worker nodes Launch Template
    ```cython
    set -o xtrace
    /etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks.certificate_authority[0].data}' '${aws_eks_cluster.eks.name}'
    ```
- Verify that your worker nodes are in a subnet that is associated with your Amazon EKS cluster

### Gotchas
- Here we have kubernets version 1.18. If you want to change version make sure to use appropriate ami in `launch_template.tf`
- 

[Reference]
1. https://aws.amazon.com/premiumsupport/knowledge-center/eks-worker-nodes-cluster/
2. https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html