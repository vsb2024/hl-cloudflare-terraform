# Cloudflare Terraform Configuration for Halloween Game

This repository contains Terraform configuration to set up Cloudflare DNS for the Halloween Candy Rush game deployed on AWS EKS.

## What This Does

- Creates a CNAME DNS record pointing `cball.media.pp.ua` to the AWS ELB (Elastic Load Balancer)
- Configures SSL/TLS settings for secure HTTPS access
- Enables Cloudflare proxy (orange cloud) for DDoS protection and CDN
- Optionally creates www subdomain

## Prerequisites

1. **Terraform** (version >= 1.0)
2. **Cloudflare account** with API access
3. **EKS cluster deployed** with nginx-ingress Load Balancer

## Configuration

### 1. Setup Credentials

The credentials are already configured in `terraform.auto.tfvars` (excluded from git):

```hcl
cloudflare_email   = "mediafactoryhosting@gmail.com"
cloudflare_api_key = "44f0c7699ae490feb78793fbefd31819d9179"
cloudflare_zone_id = "e6e933f342a6bd502f2d0c38098da594"
```

⚠️ **Security Note**: The `terraform.auto.tfvars` file is in `.gitignore` to prevent committing sensitive credentials to git.

### 2. Get Load Balancer Hostname

After deploying the EKS cluster, get the Load Balancer hostname:

```bash
# Configure kubectl
aws eks --region us-east-1 update-kubeconfig --name hl-game-cluster --profile claude-aws

# Get Load Balancer hostname
kubectl get svc -n ingress-nginx nginx-ingress-ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Example output:
```
a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6-1234567890.us-east-1.elb.amazonaws.com
```

### 3. Update terraform.auto.tfvars

Edit `terraform.auto.tfvars` and replace `REPLACE_WITH_ELB_HOSTNAME` with the actual Load Balancer hostname:

```hcl
load_balancer_hostname = "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6-1234567890.us-east-1.elb.amazonaws.com"
```

## Deployment Instructions

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

This will show:
- DNS CNAME record to be created
- SSL/TLS settings to be configured

### 3. Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted. Deployment takes less than 1 minute.

### 4. Verify

Check the outputs:
```bash
terraform output
```

You should see:
```
game_url = "https://cball.media.pp.ua"
record_status = "Proxied through Cloudflare (orange cloud)"
```

### 5. Test DNS Resolution

```bash
# Test DNS propagation
dig cball.media.pp.ua

# Or using nslookup
nslookup cball.media.pp.ua
```

### 6. Access the Game

Open your browser and navigate to:
```
https://cball.media.pp.ua
```

## Configuration Options

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `subdomain` | Subdomain for the game | `cball` |
| `cloudflare_proxied` | Enable Cloudflare proxy (orange cloud) | `true` |
| `create_www_subdomain` | Create www subdomain | `false` |
| `ssl_mode` | SSL/TLS mode | `flexible` |

### SSL/TLS Modes

- **flexible**: Cloudflare to client HTTPS, Cloudflare to origin HTTP (recommended for ELB without SSL)
- **full**: End-to-end HTTPS but allows self-signed certificates
- **strict**: End-to-end HTTPS with valid SSL certificate required
- **off**: No SSL (not recommended)

## DNS Propagation

- **Cloudflare**: Updates are usually instant (within seconds)
- **Global DNS**: Full propagation can take up to 24-48 hours
- **TTL**: Set to 300 seconds (5 minutes) for faster updates during setup

## Cloudflare Features Enabled

- ✅ Always Use HTTPS
- ✅ HTTP/2 and HTTP/3
- ✅ Minimum TLS 1.2
- ✅ DDoS protection (when proxied)
- ✅ CDN caching (when proxied)

## Outputs

After deployment:

```bash
# Get game URL
terraform output game_url

# Get DNS record status
terraform output record_status
```

## Cleanup

To remove DNS records and configuration:

```bash
terraform destroy
```

## Troubleshooting

### Issue: DNS not resolving

**Solution**: Check DNS propagation:
```bash
dig cball.media.pp.ua @1.1.1.1  # Check Cloudflare DNS
```

Wait a few minutes for propagation.

### Issue: SSL certificate error

**Solution**:
- If using `flexible` SSL mode, ensure Load Balancer accepts HTTP (port 80)
- If using `full` or `strict`, configure SSL certificate on Load Balancer
- Check Cloudflare SSL/TLS settings in dashboard

### Issue: 522 Connection timeout error

**Solution**:
- Verify Load Balancer is healthy
- Check security groups allow traffic from Cloudflare IPs
- Ensure nginx-ingress is running:
  ```bash
  kubectl get pods -n ingress-nginx
  ```

### Issue: 404 Not Found

**Solution**:
- Game is not deployed yet - deploy using Helm chart first
- Check ingress configuration:
  ```bash
  kubectl get ingress -A
  ```

## Architecture Flow

```
User Browser
    ↓ (HTTPS)
Cloudflare CDN/Proxy
    ↓ (HTTP or HTTPS depending on ssl_mode)
AWS Classic Load Balancer (ELB)
    ↓
nginx-ingress Controller
    ↓
Halloween Game Pod
```

## Security Notes

1. **API Keys**: Never commit `terraform.auto.tfvars` to git
2. **Cloudflare Proxy**: Keep `cloudflare_proxied = true` for DDoS protection
3. **SSL/TLS**: Use `flexible` mode minimum; upgrade to `full` when ELB has SSL
4. **Origin Rules**: Consider adding Cloudflare firewall rules to allow only Cloudflare IPs to origin

## Next Steps

After DNS is configured:
1. Deploy the Halloween game using Helm chart
2. Verify game is accessible at https://cball.media.pp.ua
3. Configure Cloudflare page rules or caching if needed
4. Set up Cloudflare Analytics to monitor traffic

## References

- [Cloudflare Terraform Provider](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs)
- [Cloudflare SSL/TLS Modes](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/)
- [Cloudflare DNS](https://developers.cloudflare.com/dns/)
