# devops-terraform-modules-tailscale

[![OpenTofu](https://img.shields.io/badge/OpenTofu-FFDA18?logo=opentofu&logoColor=black)](https://opentofu.org/)
[![Tailscale](https://img.shields.io/badge/Tailscale-000000?logo=tailscale&logoColor=white)](https://tailscale.com)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/your-org/terraform-tailscale-module?color=green)](https://github.com/your-org/terraform-tailscale-module/releases)

[![Buildkite](https://img.shields.io/buildkite/your-buildkite-badge-id/main?logo=buildkite&label=build)](https://buildkite.com/your-org/terraform-tailscale-module)
[![CodeRabbit](https://img.shields.io/badge/CodeRabbit-Enabled-blue?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0iI2ZmZiIgZD0iTTEyIDRjLTQuNDIgMC04IDMuNTgtOCA4czMuNTggOCA4IDggOC0zLjU4IDgtOC0zLjU4LTgtOC04eiIvPjwvc3ZnPg==)](https://coderabbit.ai)
[![Security](https://img.shields.io/badge/Security-Trivy-1904DA?logo=aquasecurity&logoColor=white)](https://trivy.dev/)
[![Checkov](https://img.shields.io/badge/Checkov-Passing-4CAF50?logo=paloaltonetworks&logoColor=white)](https://www.checkov.io/)

---

OpenTofu module for managing [Tailscale](https://tailscale.com) resources including tailnets, ACLs, devices, auth keys, and DNS configuration.

## ✨ Features

- 🔐 Manage Tailscale ACLs and access policies
- 🔑 Create and rotate auth keys
- 🖥️ Configure device settings and tags
- 🌐 Manage DNS settings and nameservers
- 👥 Manage users and groups
- 🏷️ Apply device tags and attributes
- 🚪 Configure exit nodes and subnet routers

## 📋 Requirements

| Name | Version |
|------|---------|
| ![OpenTofu](https://img.shields.io/badge/-OpenTofu-FFDA18?logo=opentofu&logoColor=black&style=flat-square) | `>= 1.6.0` |
| ![Tailscale](https://img.shields.io/badge/-Tailscale-000000?logo=tailscale&logoColor=white&style=flat-square) | `>= 0.13.0` |

## 🚀 Usage

### Basic ACL Configuration

```hcl
module "tailscale" {
  source  = "your-org/tailscale/tailscale"
  version = "1.0.0"

  acl = {
    groups = {
      "group:engineering" = ["user1@example.com", "user2@example.com"]
      "group:devops"      = ["admin@example.com"]
    }

    acls = [
      {
        action = "accept"
        src    = ["group:engineering"]
        dst    = ["tag:dev:*"]
      }
    ]
  }
}
```

### Auth Keys

```hcl
module "tailscale" {
  source  = "your-org/tailscale/tailscale"
  version = "1.0.0"

  auth_keys = {
    ci_runner = {
      reusable      = true
      ephemeral     = true
      preauthorized = true
      expiry        = 86400
      tags          = ["tag:ci"]
      description   = "CI/CD runner auth key"
    }
    server_key = {
      reusable      = false
      ephemeral     = false
      preauthorized = true
      tags          = ["tag:server"]
      description   = "Production server auth key"
    }
  }
}
```

### Complete Example

```hcl
module "tailscale" {
  source  = "your-org/tailscale/tailscale"
  version = "1.0.0"

  # 🔐 ACL Configuration
  acl = {
    groups = {
      "group:engineering" = ["dev1@example.com", "dev2@example.com"]
      "group:devops"      = ["ops@example.com"]
      "group:security"    = ["sec@example.com"]
    }

    tagOwners = {
      "tag:prod"    = ["group:devops"]
      "tag:dev"     = ["group:engineering"]
      "tag:ci"      = ["group:devops"]
      "tag:monitor" = ["group:security"]
    }

    acls = [
      # DevOps can access everything
      {
        action = "accept"
        src    = ["group:devops"]
        dst    = ["*:*"]
      },
      # Engineering can access dev and staging
      {
        action = "accept"
        src    = ["group:engineering"]
        dst    = ["tag:dev:*", "tag:staging:*"]
      },
      # CI runners can access deploy targets
      {
        action = "accept"
        src    = ["tag:ci"]
        dst    = ["tag:prod:22", "tag:staging:22"]
      },
      # Monitoring can access metrics ports
      {
        action = "accept"
        src    = ["tag:monitor"]
        dst    = ["*:9090", "*:9100"]
      }
    ]

    ssh = [
      {
        action = "accept"
        src    = ["group:devops"]
        dst    = ["tag:prod"]
        users  = ["root", "deploy"]
      },
      {
        action = "accept"
        src    = ["group:engineering"]
        dst    = ["tag:dev"]
        users  = ["autogroup:nonroot"]
      }
    ]
  }

  # 🔑 Auth Keys
  auth_keys = {
    ci_runner = {
      reusable      = true
      ephemeral     = true
      preauthorized = true
      expiry        = 86400
      tags          = ["tag:ci"]
      description   = "GitHub Actions runner"
    }
    k8s_operator = {
      reusable      = true
      ephemeral     = false
      preauthorized = true
      tags          = ["tag:k8s"]
      description   = "Kubernetes operator"
    }
  }

  # 🌐 DNS Configuration
  dns = {
    nameservers   = ["1.1.1.1", "8.8.8.8"]
    search_paths  = ["example.com", "internal.example.com"]
    magic_dns     = true
    override_local = false
  }

  # 🖥️ Device Settings
  device_defaults = {
    routes_enabled     = true
    key_expiry_disabled = false
  }

  tags = {
    Environment = "production"
    Team        = "platform"
    ManagedBy   = "opentofu"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## 📥 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `acl` | Tailscale ACL policy configuration | `object({ groups = map(list(string)), tagOwners = map(list(string)), acls = list(object({ action = string, src = list(string), dst = list(string) })), ssh = list(object({ action = string, src = list(string), dst = list(string), users = list(string) })) })` | `null` | no |
| `auth_keys` | Map of auth keys to create | `map(object({ reusable = bool, ephemeral = bool, preauthorized = bool, expiry = number, tags = list(string), description = string }))` | `{}` | no |
| `dns` | DNS configuration | `object({ nameservers = list(string), search_paths = list(string), magic_dns = bool, override_local = bool })` | `null` | no |
| `device_defaults` | Default device settings | `object({ routes_enabled = bool, key_expiry_disabled = bool })` | `null` | no |
| `tags` | Tags to apply to resources | `map(string)` | `{}` | no |

## 📤 Outputs

| Name | Description |
|------|-------------|
| `acl_id` | ID of the ACL policy |
| `auth_key_ids` | Map of auth key names to their IDs |
| `auth_key_values` | Map of auth key names to their values (sensitive) |
| `dns_nameservers` | Configured DNS nameservers |
| `tailnet_name` | Name of the tailnet |
<!-- END_TF_DOCS -->

## ⚙️ Provider Configuration

Configure the Tailscale provider in your root module:

```hcl
terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.13.0"
    }
  }
}

provider "tailscale" {
  api_key = var.tailscale_api_key  # Or set TAILSCALE_API_KEY env var
  tailnet = var.tailnet            # Or set TAILSCALE_TAILNET env var
}
```

## 📂 Examples

| Example | Description |
|---------|-------------|
| [🟢 Basic](./examples/basic) | Simple ACL setup |
| [🔵 Complete](./examples/complete) | Full configuration with ACLs, auth keys, and DNS |
| [🟣 Multi-Team](./examples/multi-team) | Multi-team access policies |
| [🟠 Kubernetes](./examples/kubernetes) | K8s operator integration |

## 🔒 Security Considerations

> ⚠️ **Important Security Notes**

| Item | Recommendation |
|------|----------------|
| 🔑 API Keys | Store in Vault or secure secrets manager |
| 🔐 Auth Keys | Use short expiry for ephemeral keys |
| 📋 ACLs | Follow least-privilege principle |
| 🏷️ Tags | Use tag owners to control device tagging |
| 📝 Audit | Enable audit logging in Tailscale admin |

## 🔄 Migration Guide

### v0.x → v1.0

> ⚠️ **Breaking changes in v1.0**

| Change | Before (v0.x) | After (v1.0) |
|--------|---------------|--------------|
| ACL format | `acl_policy` | `acl` (object) |
| Auth keys | `authkey` | `auth_keys` (map) |
| DNS | `dns_config` | `dns` (object) |

```hcl
# ❌ Before (v0.x)
module "tailscale" {
  source     = "your-org/tailscale/tailscale"
  version    = "0.5.0"
  acl_policy = file("acl.json")
}

# ✅ After (v1.0)
module "tailscale" {
  source  = "your-org/tailscale/tailscale"
  version = "1.0.0"
  acl = {
    groups = {}
    acls   = []
  }
}
```

## 🤝 Contributing

1. 🍴 Fork the repository
2. 🌿 Create a feature branch (`git checkout -b feat/new-feature`)
3. 💾 Commit changes using [Conventional Commits](https://www.conventionalcommits.org/)
4. 📤 Push to the branch (`git push origin feat/new-feature`)
5. 🔃 Open a Pull Request

### 📝 Commit Message Format

```
<type>(<scope>): <description>
```

| Type | Description |
|------|-------------|
| `feat` | ✨ New feature |
| `fix` | 🐛 Bug fix |
| `docs` | 📚 Documentation |
| `refactor` | ♻️ Code refactoring |
| `test` | 🧪 Tests |
| `chore` | 🔧 Maintenance |

**Scopes:** `acl`, `auth-keys`, `dns`, `devices`, `examples`, `docs`

### 🛠️ Local Development

```bash
# 🎨 Format code
tofu fmt -recursive

# ✅ Validate
tofu validate

# 📖 Generate docs
terraform-docs markdown table . > README.md

# 🧪 Run tests
cd examples/basic && tofu init && tofu plan
```

## 📄 License

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

Apache 2.0 - See [LICENSE](LICENSE) for details.

## 👥 Authors

Maintained by **Your Organization**.

## 🔗 Related

| Resource | Link |
|----------|------|
| 📖 Tailscale Documentation | [tailscale.com/kb](https://tailscale.com/kb) |
| 🔌 Tailscale Provider | [Registry](https://registry.terraform.io/providers/tailscale/tailscale/latest/docs) |
| 🔧 Tailscale API | [API Docs](https://tailscale.com/api) |
| 📋 ACL Reference | [ACL Tags](https://tailscale.com/kb/1068/acl-tags) |
| 🟡 OpenTofu | [opentofu.org](https://opentofu.org/) |
| 🟢 Buildkite | [buildkite.com](https://buildkite.com/) |

---

<p align="center">
  <sub>Built with ❤️ using <img src="https://img.shields.io/badge/-OpenTofu-FFDA18?logo=opentofu&logoColor=black&style=flat-square" alt="OpenTofu" /> and <img src="https://img.shields.io/badge/-Buildkite-14CC80?logo=buildkite&logoColor=white&style=flat-square" alt="Buildkite" /></sub>
</p>
