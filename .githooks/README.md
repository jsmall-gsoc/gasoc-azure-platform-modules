# Git Hooks

This directory contains Git hooks that enforce development best practices for this repository.

## Available Hooks

### pre-push
Validates branch names before pushing to ensure they follow the project's naming conventions.

**Branch naming patterns:**
- `feature/{module-name}/{description}` - New features or module enhancements
- `bugfix/{module-name|general}/{description}` - Bug fixes
- `hotfix/{module-name|general}/{description}` - Urgent production fixes
- `release/v{major}.{minor}.{patch}` - Release branches
- `docs/{description}` - Documentation changes
- `chore/{description}` - Maintenance and tooling changes

**Examples:**
```
feature/azure-firewall/add-diagnostic-settings
bugfix/key-vault/fix-purge-protection-policy
hotfix/general/critical-security-patch
release/v1.2.3
docs/branch-naming-convention
chore/update-terraform-version
```

## Installation

### Automatic Setup
The repository is configured to use `.githooks` as the hooks directory. Run this command once:

```bash
git config core.hooksPath .githooks
```

### Verify Installation
Confirm the hook is installed:

```bash
git config core.hooksPath
```

You should see: `.githooks`

### Manual Testing
To test the pre-push hook locally without pushing:

```bash
# Make the hook executable
chmod +x .githooks/pre-push

# Test it manually
./.githooks/pre-push
```

## What Happens

### On `git push`
1. The `pre-push` hook runs automatically
2. Your branch name is validated against the naming patterns
3. If valid, the push proceeds
4. If invalid, the push is blocked and you see usage examples

### On GitHub
The `.github/workflows/validate-branch-name.yml` workflow:
1. Runs on pull request creation and updates
2. Validates the branch name using the same patterns
3. Comments on the PR with validation results
4. Blocks merging if the branch name is invalid

## Disabling Hooks

⚠️ **Not recommended**, but if needed:

```bash
# Disable hooks temporarily
git push --no-verify

# Or disable for the entire repository
git config core.hooksPath /dev/null
```

## Updating Hooks

If the hook is updated in the repository, simply pull the changes. The hook will automatically use the latest version on your next `git push`.

## Troubleshooting

### Hook Not Running
Verify it's executable:
```bash
ls -la .githooks/pre-push
# Should show: -rwxr-xr-x (executable bit set)
```

Make it executable if needed:
```bash
chmod +x .githooks/pre-push
```

### Git Config Not Set
Check your configuration:
```bash
git config core.hooksPath
```

If empty, run the installation command again:
```bash
git config core.hooksPath .githooks
```

## Documentation

For more information on branch naming conventions, see [CONTRIBUTING.md](../CONTRIBUTING.md#branch-naming-conventions).
