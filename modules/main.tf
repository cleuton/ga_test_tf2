# Configure o provedor Kubernetes
provider "kubernetes" {
  config_path        = "~/.kube/config"  # Caminho para o arquivo de configuração do kubectl
}

# Configura o backend para armazenar o estado do terraform
terraform {
  backend "kubernetes" {
    secret_suffix    = "state"
    config_path      = "~/.kube/config"
  }
}

# Defina um recurso Deployment para o Nginx
resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx-tf-deployment"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "nginx-tf"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx-tf"
        }
      }

      spec {
        container {
          name  = "nginx-tf"
          image = "nginx:latest"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Defina um recurso Service NodePort para expor o Nginx
resource "kubernetes_service" "nginx-service" {
  metadata {
    name = "nginx-tf-service"
  }

  spec {
    selector = {
      app = "nginx-tf"
    }

    port {
      port        = 80
      target_port = 80
      node_port   = 30080
    }

    type = "NodePort"
  }
}
