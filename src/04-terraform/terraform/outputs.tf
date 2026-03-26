output "instance_ip" {
  description = "IP publique de l'instance"
  value       = scaleway_instance_ip.app.address
}
