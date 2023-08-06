data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../01-cluster/terraform.tfstate"
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.cluster.name
    ]
  }
}


resource "kubernetes_deployment" "node" {
  metadata {
    name = "microservice-deployment"
    labels = {
      app = "node-microservice"
    }
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        app = "node-microservice"
      }
    }
    template {
      metadata {
        labels = {
          app = "node-microservice"
        }
      }
      spec {
        container {
          image = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/hello-world-image:latest"
          name  = "node-microservice-container"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "node" {
  depends_on = [kubernetes_deployment.node]
  metadata {
    name = "node-microservice-service"
  }
  spec {
    selector = {
      app = "node-microservice"
    }
    port {
      port        = 80
      target_port = 8080
    }
    type = "LoadBalancer"
  }
}
