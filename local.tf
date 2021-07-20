locals {
  env     = terraform.workspace
  project = "demo"
  dev     = "Shubho Shaha"
  common_tags = {
    Environment = local.env
    Owner       = local.dev
    Project     = local.project
  }
  tf_vpc_ipblock = {
    uat  = "10.145.0.0/20"
    prod = "10.145.16.0/20"
    lt   = "10.145.32.0/20"
  }
  vpc_ipblock = local.tf_vpc_ipblock[local.env]

  tf_public_subnet_1a = {
    uat  = "10.145.0.0/24"
    prod = "10.145.16.0/24"
    lt   = "10.145.32.0/24"
  }
  public_subnet_1a = local.tf_public_subnet_1a[local.env]
  tf_public_subnet_1b = {
    uat  = "10.145.1.0/24"
    prod = "10.145.17.0/24"
    lt   = "10.145.33.0/24"
  }
  public_subnet_1b = local.tf_public_subnet_1b[local.env]
  tf_public_subnet_1c = {
    uat  = "10.145.2.0/24"
    prod = "10.145.18.0/24"
    lt   = "10.145.34.0/24"
  }
  public_subnet_1c = local.tf_public_subnet_1c[local.env]

  tf_private_subnet_1a = {
    uat  = "10.145.4.0/24"
    prod = "10.145.20.0/24"
    lt   = "10.145.36.0/24"
  }
  private_subnet_1a = local.tf_private_subnet_1a[local.env]
  tf_private_subnet_1b = {
    uat  = "10.145.5.0/24"
    prod = "10.145.21.0/24"
    lt   = "10.145.37.0/24"
  }
  private_subnet_1b = local.tf_private_subnet_1b[local.env]
  tf_private_subnet_1c = {
    uat  = "10.145.6.0/24"
    prod = "10.145.22.0/24"
    lt   = "10.145.38.0/24"
  }
  private_subnet_1c = local.tf_private_subnet_1c[local.env]



  eks_cluster_name = "${local.env}_${local.project}_eks_cluster"
  tf_k8_version = {
    uat  = "1.18"
    prod = "1.18"
    lt   = "1.18"
  }
  k8_version = local.tf_k8_version[local.env]

  tf_eks_worker_node_instance_type = {
    uat  = "t3.micro"
    prod = "t3.micro"
    lt   = "t3.micro"
  }
  eks_worker_node_instance_type = local.tf_eks_worker_node_instance_type[local.env]

  tf_eks_worker_node_userdata = {
    uat  = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks.certificate_authority[0].data}' '${aws_eks_cluster.eks.name}'
USERDATA
    prod = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks.certificate_authority[0].data}' '${aws_eks_cluster.eks.name}'
USERDATA
    lt   = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks.certificate_authority[0].data}' '${aws_eks_cluster.eks.name}'
USERDATA
  }
  eks_worker_node_userdata = local.tf_eks_worker_node_userdata[local.env]

  tf_eks_worker_node_keypair = {
    uat  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCoIUxwx3kbgs78HIjfbL34pzcoSeU1oZ4vbRabN0WJONPB60hFvBB93dUbZgfNjsNqrZhSF9FaEyd1x1Ysj+yh39NMoPQNj9YE+1HjH3o/SH7eLsUta6dky89Kxvn4Uq4KqVzsZN3Zi3vsZwSWI18+O9NlXhCGV1+Ql/+YpBQ1TUYcCfQanFlcvfVPo/sI1XyU66iCxvrboV03k5Ug307KNIfshzWsoeA2wGvOrlRidIaVOzBvy4pUM9c7CK2Wfvc9aBAYwdFlz4NWlyA2NygfdlJ8WWGdUFOiSvZqmpcCQXmfnLi+e+d+NxVTXQZ/j0xPeUJvEW/IoerHt6k8E+RWjAhv37ycgvv+7UG8ukRt/nHMEWFnlCESFVb+XWZW7GjNqr0jCVvOnn63ULE0qdTaub7AWZvw05V3R7pEDkML+mjJkjDbyGg4yYl8k+0nHnr35qk+8XIBIxkNiSZlbfH1zLtqOdcNAIS5WDcWz4gLyNID4mMMGripLYZlS5AMeO0="
    prod = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDG84pJ+uZD8E7jPMywsodfWgvw3uVCFUGKD+IR63LZkzWPeIHv+hy5ry9cE/ZQEv8TyFsVQtzxjmyPSG3eK4pn08QcmL0cFh9u0OYQT+oHImw/lp8gi8YjjmSYkTxdxQtJjxbgF3tTjKWeSt557awWogb86i32H6fxBgkqiCBVIqWZkgq1RNN34FpD5af6l0ghgZVrrJ6vqcfzGGYRDIW2q6zL9Rv9Z+fMLrnokC+BQB4KGdoStgcmq58KEkAivssvO3BEOmlbElf4KKcmriyQjviU3g+5LW85n7Q2X0UOli9zfiYu3XsLSBsjYXS+iKG3kLqimnzV0QwNc9Oj9ctgEFq6ud6mP4alg/3pu7xIhFUwWZoqzmLHah4JspDIBh5LR1MX+RoE+eG+UBLF5j7h8WL+Pm9DQzMWJMCX7eHQYcR2AMLoPmK40KsB676PERGad4cRm5te0NnKIBb6GGr8IyZfEr7ujeMDPoK9faDQKMfVOibKMyBcFyFFNAvPD+M="
    lt   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRA4wAxcpmaQ8ZWDCvokl5+Q+2Ov/+a3HoC0C7NrQdSTPOBQWmLSLnm3qkbtyabeDYGeboPD4qFo1mB0JMv4Ly6PovFyV5tWO32SM+j1S/eZv4R7ZHdOwSW53znZAofUPfIOqV3V+0p16Ufa6d9hXABJrt69QKa2QIePYd9Tdoj7bBFFd0atW8kvSbrjjBQZJ/wOorXeVg1GVD6MVIVf9Pzy7/r3J/OOJuqZPvr5avv+kmws0QjF1orSxgsB9yAMMQeKRclIwQh/HcZE4AsvG708ZA3M60p5TTPaKtWC9CNKlHWrkWIYARYAp1Ri2/BvkNwYtuTrxBgWq2iHzz/W9VKz1S1lhTz7v+4VJCdy9hGjKGFZML4JQGi9GojxvYKy0qphLIS5cuk/Kcl5nP9DULAPDOWW4vz1asSBKNY65XMPpXdaZt+6kmUfmcIiRxUIgrgvtLZ+PjUMSums3J4Fw6NzDeIWkWzEwq1ulHsvXIWqj6RnPpGUebeU/wnXt+APU="
  }
  eks_worker_node_keypair = local.tf_eks_worker_node_keypair[local.env]

  tf_min_worker_node = {
    uat  = 1
    prod = 1
    lt   = 1
  }
  min_worker_node = local.tf_min_worker_node[local.env]

  tf_max_worker_node = {
    uat  = 1
    prod = 1
    lt   = 1
  }
  max_worker_node = local.tf_max_worker_node[local.env]

  tf_asg_mixed_instance_types = {
    uat = [
      { name = "t3.large", weight = "1" },
      { name = "t3a.large", weight = "1" }
    ]
    prod = [
      { name = "m5.xlarge", weight = "1" },
      { name = "m5d.xlarge", weight = "1" },
      { name = "m5a.xlarge", weight = "1" },
      { name = "m5ad.xlarge", weight = "1" },
      { name = "m5n.xlarge", weight = "1" },
      { name = "m5dn.xlarge", weight = "1" },
      { name = "m4.xlarge", weight = "1" }
    ]
    lt = [
      { name = "m5.xlarge", weight = "1" },
      { name = "m5d.xlarge", weight = "1" },
      { name = "m5a.xlarge", weight = "1" },
      { name = "m5ad.xlarge", weight = "1" },
      { name = "m5n.xlarge", weight = "1" },
      { name = "m5dn.xlarge", weight = "1" },
      { name = "m4.xlarge", weight = "1" }
    ]
  }
  asg_mixed_instance_types = local.tf_asg_mixed_instance_types[local.env]

  tf_spot_allocation_strategy = {
    dev  = "0"
    lt   = "lowest-price"
    uat  = "lowest-price"
    prod = "lowest-price"
  }
  spot_allocation_strategy = local.tf_spot_allocation_strategy[local.env]
  tf_on_demand_percentage_above_base_capacity = {
    sit  = "0"
    uat  = "0"
    prod = "60"
    lt   = "60"
  }
  on_demand_percentage_above_base_capacity = local.tf_on_demand_percentage_above_base_capacity[local.env]

  tf_spot_instance_pools = {
    sit  = ""
    uat  = "2"
    prod = "2"
    lt   = "2"
  }
  spot_instance_pools = local.tf_spot_instance_pools[local.env]
}