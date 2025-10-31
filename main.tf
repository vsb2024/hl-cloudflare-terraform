terraform {
  required_version = ">= 1.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_key = var.cloudflare_api_key
  email   = var.cloudflare_email
}

# Get the zone information
data "cloudflare_zone" "main" {
  zone_id = var.cloudflare_zone_id
}

# Create A record for the game subdomain pointing to the Load Balancer
resource "cloudflare_record" "game" {
  zone_id = var.cloudflare_zone_id
  name    = var.subdomain
  content = var.load_balancer_hostname
  type    = "CNAME"
  ttl     = var.cloudflare_proxied ? 1 : 300
  proxied = var.cloudflare_proxied

  comment = "Halloween Candy Rush game - EKS Load Balancer"
}

# Optional: Create www subdomain as well
resource "cloudflare_record" "game_www" {
  count   = var.create_www_subdomain ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "www.${var.subdomain}"
  content = var.load_balancer_hostname
  type    = "CNAME"
  ttl     = 300
  proxied = var.cloudflare_proxied

  comment = "Halloween Candy Rush game WWW - EKS Load Balancer"
}

# Optional: Configure SSL/TLS settings
resource "cloudflare_zone_settings_override" "game_zone_settings" {
  zone_id = var.cloudflare_zone_id

  settings {
    # Always use HTTPS
    always_use_https = "on"

    # SSL mode
    ssl = var.ssl_mode

    # Minimum TLS version
    min_tls_version = "1.2"

    # Enable HTTP/3
    http3 = "on"
  }
}
