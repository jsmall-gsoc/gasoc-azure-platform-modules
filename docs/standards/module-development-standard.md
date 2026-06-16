# Terraform Module Development Standard

## Required Files

Every module must include:

```text
main.tf
variables.tf
outputs.tf
README.md
examples/basic/main.tf
```

## Naming

Module names must use lowercase kebab-case.

Examples:

```text
virtual-network
network-security-group
private-endpoint
```

## Input Standards

Use descriptive variable names and include types for all variables.

## Output Standards

At minimum, output:

- `id`
- `name`

where applicable.

## Tags

All taggable Azure resources must accept:

```hcl
variable "tags" {
  type    = map(string)
  default = {}
}
```

## Security

Modules should default to secure settings where possible:

- Public network access disabled
- TLS 1.2 or higher
- Soft delete enabled
- Purge protection enabled
- RBAC enabled
- Diagnostics supported
