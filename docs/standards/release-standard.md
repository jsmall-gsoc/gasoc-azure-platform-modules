# Module Release Standard

## Release Types

| Release Type | Example | Meaning |
|---|---|---|
| Patch | v1.0.1 | Bug fix |
| Minor | v1.1.0 | Backward-compatible feature |
| Major | v2.0.0 | Breaking change |

## Release Process

1. Merge approved PR to `develop`.
2. Validate module using pipeline.
3. Promote to `main`.
4. Create Git tag.
5. Generate changelog.
6. Notify consuming teams.

## Tagging Example

```bash
git tag -a v1.0.0 -m "Production-ready baseline"
git push origin v1.0.0
```

## Consuming Repos

Environment repositories must pin to a release tag:

```hcl
source = "git::https://dev.azure.com/<org>/<project>/_git/gasoc-azure-terraform-modules//modules/resource-group?ref=v1.0.0"
```
