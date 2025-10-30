variable "cloudflare_email" {
  description = "Cloudflare account email"
  type        = string
  sensitive   = true
}

variable "cloudflare_api_key" {
  description = "Cloudflare Global API Key"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
  sensitive   = true
}

variable "subdomain" {
  description = "Subdomain for the game (e.g., 'cball' for cball.media.pp.ua)"
  type        = string
  default     = "cball"
}

variable "load_balancer_hostname" {
  description = "AWS Load Balancer hostname from nginx-ingress service"
  type        = string
}

variable "cloudflare_proxied" {
  description = "Whether the DNS record should be proxied through Cloudflare (orange cloud)"
  type        = bool
  default     = true
}

variable "create_www_subdomain" {
  description = "Create www subdomain (e.g., www.cball.media.pp.ua)"
  type        = bool
  default     = false
}

variable "ssl_mode" {
  description = "SSL/TLS mode: off, flexible, full, strict, origin_pull"
  type        = string
  default     = "flexible"
}
