# eks-cluster

Resources that will be created
- NETWORK
    - VPC
    - Internet Gateway
    - Public Subnet
    - Private Subnet
    - Security Group for CLuster
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
    
- EKS
    - Cluster
    
- AutoScale
- Keypair
- Launch Template



Make sure:
Worker Node has the following tags:
```cython
k8s.io/cluster-autoscaler/<cluster-name> = owned
k8s.io/cluster-autoscaler/enabled = true
kubernetes.io/cluster/<cluster-name> = owned
```