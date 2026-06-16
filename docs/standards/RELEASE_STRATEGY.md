# Release Management Strategy

This document defines the release process, versioning strategy, and lifecycle management for GASOC Azure Terraform Modules.

## Versioning

**Format**: `MAJOR.MINOR.PATCH` (e.g., `v1.0.0`)

**Rules**:
- `MAJOR` version: Breaking changes (migration required, API changes)
- `MINOR` version: New features (backward compatible)
- `PATCH` version: Bug fixes (no new features)

**Examples**:
- v1.0.0 → v1.1.0 = New module added (backward compatible)
- v1.0.0 → v1.0.1 = Bug fix in existing module
- v1.0.0 → v2.0.0 = Redesigned module with breaking changes

## Release Cadence

- **LTS (Long-Term Support)**: v1.x - 24-month support window
- **Current**: v2.x (when released)
- **Patch releases**: Monthly security/bug fix reviews
- **Minor releases**: Quarterly (new features)
- **Major releases**: Annually (significant changes)

## Release Lifecycle

### Phase 1: Planning (2 weeks before release)

- [ ] Create release branch: `git checkout -b release/v1.X.X`
- [ ] Identify all changes since last release
- [ ] Update CHANGELOG.md with all changes
- [ ] Review for NERC CIP compliance impact
- [ ] Create release note draft

### Phase 2: Validation (1 week before release)

- [ ] Run full test suite:
  ```bash
  terraform validate
  tflint --recursive
  checkov --framework terraform --compact
  ```
- [ ] Test in non-production environment
- [ ] Verify all examples work:
  ```bash
  cd examples/phase-1-foundation && terraform plan
  cd examples/phase-2-networking && terraform plan
  cd examples/phase-3-governance && terraform plan
  ```
- [ ] Get security team approval
- [ ] Document any breaking changes with migration guide

### Phase 3: Release (Release Date)

- [ ] Merge release branch to `main`
- [ ] Create Git tag:
  ```bash
  git tag -a v1.X.X -m "Release v1.X.X

  Breaking Changes:
  - (list any MAJOR changes)

  Security Updates:
  - (list any CRITICAL fixes)

  Features:
  - (new modules/capabilities)

  Bug Fixes:
  - (list fixes)
  "
  ```
- [ ] Push tag:
  ```bash
  git push origin v1.X.X
  ```
- [ ] Create release on Azure DevOps:
  ```bash
  az devops release create \
    --release-name "v1.X.X" \
    --definition-id <release-definition-id> \
    --artifacts <build-artifact-id> \
    --reason "Scheduled release"
  ```
- [ ] Announce in:
  - Slack #infrastructure-eng
  - Teams announcement
  - Email to platform engineering list

### Phase 4: Post-Release (1 week after release)

- [ ] Monitor for issues/bug reports
- [ ] Create patch branch if critical bugs found: `hotfix/v1.X.X`
- [ ] Plan next release

## Change Classification

### MAJOR (Breaking Changes)
- Module input variables renamed/removed
- Module output values changed
- Resource type or structure redesigned
- Backward compatibility impossible
- **Action**: Requires 6-month deprecation notice

### MINOR (Features)
- New modules added
- New optional variables added
- New outputs added
- Performance improvements
- **Action**: All code is backward compatible

### PATCH (Bug Fixes)
- Typo fixes
- Logic errors corrected
- Documentation updates
- Security patch applied (no behavior change)
- **Action**: No code changes that affect behavior

### SECURITY
- Critical vulnerability fixed
- May be released outside cadence
- Affects NERC CIP compliance
- Requires immediate deployment

## Breaking Change Policy

Breaking changes require:
1. **6-month deprecation notice** in CHANGELOG.md
2. **Migration guide** in documentation
3. **Example showing** old vs. new approach
4. **Security team approval** (if compliance-related)
5. **MAJOR version bump** (v1.0.0 → v2.0.0)

Example deprecation notice:

```markdown
### Deprecated (BREAKING - Deprecated in v1.2.0, Removed in v2.0.0)

The `authentication_method` variable is deprecated. Use `use_managed_identity` instead:

```hcl
# ❌ OLD (v1.0.0 - v1.9.9)
variable "authentication_method" {
  type = string
}

# ✅ NEW (v2.0.0+)
variable "use_managed_identity" {
  type = bool
}
```

Migration: All deployments must use `use_managed_identity` before upgrading to v2.0.0.
```

## Module Pinning

**Always pin module versions** in production:

```hcl
# ✅ GOOD
module "key_vault" {
  source = "git::https://dev.azure.com/org/project/_git/gasoc-azure-terraform-modules//modules/key-vault?ref=v1.0.0"
}

# ❌ BAD (unpinned - unsafe)
module "key_vault" {
  source = "git::https://dev.azure.com/org/project/_git/gasoc-azure-terraform-modules//modules/key-vault"
}

# ❌ BAD (uses main/develop - unpredictable)
module "key_vault" {
  source = "git::https://dev.azure.com/org/project/_git/gasoc-azure-terraform-modules//modules/key-vault?ref=main"
}
```

## Upgrade Strategy

### For Patch Releases (v1.0.0 → v1.0.1)

**Automatic approval**:
- Can deploy without testing
- Backward compatible
- Example: `ref=v1.0.0` → `ref=v1.0.1`

```bash
terraform init -upgrade
terraform plan  # Should be minimal changes
terraform apply
```

### For Minor Releases (v1.0.0 → v1.1.0)

**Requires validation**:
- Run full test suite: `terraform plan`
- Review new variables/outputs in CHANGELOG
- Test in non-prod first
- Update documentation
- Example: `ref=v1.0.0` → `ref=v1.1.0`

```bash
terraform init -upgrade
terraform plan  # Review all changes
terraform apply -target=module.x  # Apply per module
```

### For Major Releases (v1.0.0 → v2.0.0)

**Requires migration**:
- Read MIGRATION GUIDE in release notes
- Plan comprehensive testing
- Schedule maintenance window
- Backup all Terraform state
- Plan rollback procedure
- Get approval from all stakeholders

```bash
# 1. Backup state
terraform state pull > terraform.state.backup

# 2. Update module versions
sed -i 's/ref=v1\./ref=v2\./g' main.tf

# 3. Test plan (expect significant changes)
terraform init -upgrade
terraform plan -out=tfplan  # Review carefully!

# 4. Apply with caution
terraform apply tfplan
```

## Support Window

| Version | Release Date | LTS Until | Status |
|---|---|---|---|
| v2.x | TBD | TBD | Unreleased |
| v1.x | 2026-06-16 | 2028-06-16 | Supported |
| v0.x | 2026-06-01 | 2026-12-01 | Deprecated |

**Support Includes**:
- Security updates (CRITICAL)
- Bug fixes affecting compliance
- Documentation updates

**Not Included**:
- Feature backports
- Performance improvements
- Optional enhancements

## Security Patch Releases

For critical vulnerabilities (NERC CIP violations, CVEs):

1. **Severity Assessment** (within 24 hours)
   - Is this NERC CIP violation?
   - Does it affect production?
   - What's the blast radius?

2. **Emergency Release** (within 48 hours)
   - Create hotfix branch: `hotfix/v1.X.X+security`
   - Deploy patch to all supported versions
   - Use vX.X.X-security tag

3. **Announcement** (immediate)
   - Send urgent security bulletin
   - Provide mitigation steps
   - Require immediate deployment

## Release Notes Template

```markdown
# v1.X.X Release Notes

**Release Date**: 2026-MM-DD
**LTS Until**: 2028-MM-DD (24 months)

## Highlights

- [Feature] New subscription-bootstrap module
- [Security] Fixed encryption vulnerability (CIP-011)
- [Compliance] Enhanced policy enforcement

## What's New

### Modules Added
- `subscription-bootstrap` - NERC CIP-compliant subscription initialization

### Modules Enhanced
- `policy-assignment` - Added NERC CIP control library

### Modules Deprecated
- `legacy-auth` - Migrate to managed identities (v2.0.0)

## Security Updates

**CRITICAL**: Fixed unencrypted storage account creation (CVE-XXXX-XXXXX)
- Affects: v1.0.0 through v1.0.3
- Impact: Compliance violation (CIP-011)
- Action: Upgrade immediately

## Breaking Changes

None. This is a backward-compatible release.

## Migration Guide

No migration needed. Existing deployments continue to work.

## Known Issues

- None

## Contributors

- @platform-eng-team

## Upgrade Instructions

```bash
# Update module reference
sed -i 's/ref=v1.0.3/ref=v1.1.0/g' *.tf

# Validate changes
terraform init -upgrade
terraform plan

# Deploy
terraform apply
```

## Support

- Questions? [Create an issue](https://dev.azure.com/...)
- Security concern? Email security@company.com
- Feature request? [Create discussion](https://dev.azure.com/...)
```

## Automation

### CI/CD Pipeline for Releases

```yaml
# .azure-pipelines/release.yml
trigger:
  tags:
    include:
      - v*

stages:
  - stage: Validate
    jobs:
      - job: ValidateRelease
        steps:
          - task: TerraformCLI@0
            inputs:
              command: validate
          - script: tflint --recursive
          - script: checkov -d . --framework terraform

  - stage: Test
    jobs:
      - job: TestExamples
        steps:
          - script: |
              for dir in examples/*/; do
                (cd "$dir" && terraform plan) || exit 1
              done

  - stage: Release
    jobs:
      - job: CreateRelease
        steps:
          - task: GithubRelease@1
            inputs:
              gitHubConnection: github.com
              repositoryName: gasoc-azure-terraform-modules
              action: create
              tag: $(Build.SourceBranchName)
              releaseNotesSource: file
              releaseNotesFile: RELEASE_NOTES.md
```

## Checklist for Release

- [ ] All tests passing
- [ ] CHANGELOG.md updated
- [ ] Security review completed
- [ ] NERC CIP compliance verified
- [ ] Examples tested
- [ ] Documentation reviewed
- [ ] Migration guide written (if MAJOR)
- [ ] Release notes prepared
- [ ] Announcement scheduled
- [ ] Support team notified

---

## Questions?

- Release schedule: Check [Roadmap](../docs/ROADMAP.md)
- Security patches: Email security@company.com
- General questions: Ask in #infrastructure-eng Slack
