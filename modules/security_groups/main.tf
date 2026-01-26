# Security Group для Load Balancer
resource "yandex_vpc_security_group" "load_balancer" {
  name        = "${var.network_name}-lb-sg"
  description = "Security group for Load Balancer"
  network_id  = var.network_id

  # Входящий трафик HTTP/HTTPS из интернета
  ingress {
    protocol       = "TCP"
    description    = "HTTP from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTPS from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  # Исходящий трафик к Kubernetes nodes
  egress {
    protocol       = "TCP"
    description    = "Kubernetes NodePorts"
    v4_cidr_blocks = [var.private_subnet_cidr]
    from_port      = 30000
    to_port        = 32767
  }
}

# Security Group для Kubernetes nodes
resource "yandex_vpc_security_group" "k8s_nodes" {
  name        = "${var.network_name}-k8s-nodes-sg"
  description = "Security group for Kubernetes nodes"
  network_id  = var.network_id

  # Входящий трафик от Control Plane (Yandex Managed K8s)
  ingress {
    protocol       = "TCP"
    description    = "Kubernetes API Server"
    v4_cidr_blocks = ["10.0.0.0/8"]
    port           = 6443
  }

  ingress {
    protocol       = "TCP"
    description    = "Kubelet API"
    v4_cidr_blocks = ["10.0.0.0/8"]
    port           = 10250
  }

  # Входящий трафик от Load Balancer (NodePorts)
  ingress {
    protocol       = "TCP"
    description    = "NodePorts from Load Balancer"
    v4_cidr_blocks = [var.public_subnet_cidr]
    from_port      = 30000
    to_port        = 32767
  }

  # Внутренний трафик для overlay network
  ingress {
    protocol       = "UDP"
    description    = "VXLAN overlay network"
    v4_cidr_blocks = [var.private_subnet_cidr]
    port           = 8472
  }

  # DNS
  ingress {
    protocol       = "TCP"
    description    = "DNS TCP"
    v4_cidr_blocks = [var.private_subnet_cidr]
    port           = 53
  }

  ingress {
    protocol       = "UDP"
    description    = "DNS UDP"
    v4_cidr_blocks = [var.private_subnet_cidr]
    port           = 53
  }

  # Исходящий трафик в интернет (для образов, обновлений)
  egress {
    protocol       = "ANY"
    description    = "Outbound to internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
