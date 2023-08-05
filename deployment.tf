
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
          image = "497322782010.dkr.ecr.us-east-2.amazonaws.com/hello-world-image:latest"
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
