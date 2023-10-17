---
title: 'Set Up AWS EKS'
date: '2023-09-22T14:49:53-03:00'
draft: true
category: how-to
description:
weight: 500
menu:
  main:
    parent: install
    identifier:
vars:
  domain_name: libremfg.ai
  brand_name: libre
  application_name: Libre
  eks_tags: |-
    | key         | value                                 |
    |-------------|---------------------------------------|
    | location    | `YOUR_LOCATION`                          |
    | environment | `YOUR_ENVIRONMENT`                       |
    | application | Libre |
    | customer    | `YOUR_ORGANIZATION`                          |

  recommended_specs: |-
    - **AMI Type:** Amazon Linux 2 (AL2_x86_64)
    - **Capacity Type:** On Demand
    - **Instance Types:**

      - **Dev/TST:** T3.large
      - **VAL/PRD:** T3.xlarge
    - **Disk Size:** 40 GiB
    - **Node Group Scaling**
       - **Desired:** 4
       - **Minimum:** 4
       - **Maximum:** 4
    - **Node Group update configuration:** 1 Node
---

This procedure guides you on how to set up an AWS EKS cluster to run Rhize.

## Prerequisites

Before you start, ensure you have the following:

- Internet access
- An AWS account with Administrative priviledges
- [kubectx](https://github.com/ahmetb/kubectx) and kubens installed
- MQTT Explorer
- DNS records created and pointing to the following subdomains:


  | Service  | Domain                                                                    |
  |----------|---------------------------------------------------------------------------|
  | Admin UI | `<CUSTOMER>-{{< param vars.brand_name >}}.{{< param vars.domain_name >}}` |
  | Keycloak | `<CUSTOMER>-auth.{{< param vars.domain_name >}}`                          |
  | GraphQL  | `<CUSTOMER>-graphql.{{< param vars.domain_name >}}`                       |
  | NATS     | `<CUSTOMER>-mqtt.{{< param vars.domain_name >}}`                          |
  | Highbyte | `<CUSTOMER>-highbyte.{{< param vars.domain_name >}}`                      |
  | Grafana  | `<CUSTOMER>-grafana.{{< param vars.domain_name >}}`                       |
  | BPMN     | `<CUSTOMER>-bpmn.{{< param vars.domain_name >}}`                          |

### Tags

Throughout this procedure, you'll apply tags.
We recommend the following values:

{{% param vars.eks_tags %}}

## AWS Procedure

First, record your location, AWS region, and environment.
Then follow these steps.

### Create an EKS cluster role {#create-cluster-role}

For this step, follow the official AWS documentation to [Create service role](https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html#create-service-role).

1. For the role name, use `eksClusterRole-CUSTOMER-ENVIRONMENT`.

1. Add [tags](#tags):

On success, the role is visible in IAM.

### Create a security group

Security groups allow traffic to and from your VPC.

To create a group, navigate to the VPC and follow the AWS [Create security group](https://docs.aws.amazon.com/vpc/latest/userguide/security-groups.html#creating-security-groups) procedure.

1. For the **Name** field, enter `eksCluster-sg-<customer>-<environment>`.
- Add [tags](#tags)

On success, the security group creates without error and is visible in **VPC Security Groups**.

### Provision AWS EKS Cluster {#provision-cluster}

Follow the AWS [Create cluster](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html) procedure.

1. Configure the cluster.

    - **Name:** `CUSTOMER`-`ENVIRONMENT`
    - **Kubernetes version:** 1.24
    - **EKS Role:** `eksClusterRole-CUSTOMER-ENVIRONMENT` (refer to the [Create cluster role](#create-cluster-role) step)


   - Add the following tags:

     {{% param vars.eks_tags %}}

1. Specify networking for the VPC
    - **All subnets.**
    - **Security group:** (refer to the [Create a security group](#create-a-security-group) step).
    - **IP address family:** `IPv4`
    - **Endpoint access:** Public and Private

1. Enable logging for the following:
    - API server
    - Audit
    - Authenticator
    - Controller Manager Logging
    - Scheduler logging

1. Configure the following add-ons:
    - **Kube-proxy:** v1.24.7-eksbuild.2
    - **CoreDNS:** v1.8.7-eksbuild.3
    - **Amazon VPN CNI:** v1.11.4-eksbuild.1

1. Review and create

## Create a node group

1. From EKS, change to the appropriate region.
1. Select the [cluster you provisioned](#provision-cluster).
1. Add a node group with the following values:
  - **Name:** eksNodeGroup-`CUSTOMER`-`ENVIRONMENT`
  - The role you created
  - For kubernetes labels and tags, add [Tags](#tags).
  - No taints
1. Set the compute and scaling. We recommend the following values:

    {{% param vars.recommended_specs %}}

1. Select the private subnets.

## Create an ID provider

Follow the AWS instructions to [Create an IAM OIDC provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html).

## Create roles

- For recovery, create an IAM role and add it to the Kubernetes cluster RBAC as EKS Cluster admin.
- [Amazon EBS CSI driver](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html).
- AWS role for node worker group. Follow the AWS [Create node role](https://docs.aws.amazon.com/eks/latest/userguide/service_IA) procedure.

## Create load-balancer policy

Follow the instructions for [Load balancer controller installation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/deploy/installation/).

For configuration, you can use the recommended [`iam_policy.json`](https://github.com/kubernetes-sigs/aws-load-balancer-controller/tree/main/docs/install).

We recommend the following values:
- **Name:** AWSLoadBalancerControllerIAMPolicy
- **Description:** AWS load balancer controller to an Amazon EKS cluster
- The recommended [Tags](#tags)


## Create a retained storage class

Apply the following manifest:

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
type: gp2
reclaimPolicy: Retain
mountOptions:
- debug
allowVolumeExpansion: true
volumeBindingMode: Immediate
```

## Request certificates

From the AWS console, use the Certificate Manager (ACM) to request a certificate for each of the following sub-domains:

- `<CUSTOMER>-auth.{{< param vars.domain_name >}}`
- `<CUSTOMER>-api.{{< param vars.domain_name >}}`
- `<CUSTOMER>-mqtt.{{< param vars.domain_name >}}`
- `<CUSTOMER>-dashboard.{{< param vars.domain_name >}}`
- `<CUSTOMER>-historian.{{< param vars.domain_name >}}`

For each record, apply the following:
- **Validation Method**: DNS
- **Key algorithm**: RSA 2048
- Suggested [Tags](#tags)

After success, all certificates show as issued.

## Next steps:

After you've set up your cluster, you can start configuring Kubernetes.
