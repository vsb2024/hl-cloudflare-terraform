output "game_url" {
  description = "Full URL of the game"
  value       = "https://${cloudflare_record.game.hostname}"
}

output "dns_record_id" {
  description = "Cloudflare DNS record ID"
  value       = cloudflare_record.game.id
}

output "zone_name" {
  description = "Cloudflare zone name"
  value       = data.cloudflare_zone.main.name
}

output "record_status" {
  description = "DNS record proxied status"
  value       = cloudflare_record.game.proxied ? "Proxied through Cloudflare (orange cloud)" : "DNS only (grey cloud)"
}

output "www_game_url" {
  description = "Full URL of the www subdomain (if created)"
  value       = var.create_www_subdomain ? "https://${cloudflare_record.game_www[0].hostname}" : "Not created"
}
