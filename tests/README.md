# Infrastructure Testing with Terratest

This directory contains comprehensive infrastructure tests for all Terraform modules using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

- Go 1.21+
- Terraform 1.6+
- Azure CLI (for actual Azure resource testing)
- Azure subscription credentials configured

## Installation

```bash
# Install Go dependencies
cd tests
go mod download
go mod tidy
```

## Running Tests

### Run all tests
```bash
go test -v ./...
```

### Run specific test
```bash
go test -v -run TestResourceGroupExample
```

### Run with parallel execution
```bash
go test -v -parallel 4 ./...
```

### Run with timeout
```bash
go test -v -timeout 30m ./...
```

### Generate test coverage
```bash
go test -v -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

## Test Categories

### 1. **Module Validation Tests** (`TestModuleValidation`)
- Validates all modules can be initialized and pass `terraform validate`
- Runs on all modules in `../modules/`
- Ensures basic Terraform syntax and structure

### 2. **Module Output Tests** (`TestModuleOutputs`)
- Verifies critical modules have proper outputs defined
- Checks outputs.tf file exists and is valid
- Validates output structure matches module requirements

### 3. **Example Integration Tests** (`TestResourceGroupExample`)
- Tests real infrastructure deployment patterns
- Uses Terraform `apply` and `destroy`
- Validates expected outputs from examples

### 4. **Performance Benchmarks** (`BenchmarkModuleInit`)
- Measures Terraform initialization performance
- Tracks performance regressions
- Identifies optimization opportunities

## CI/CD Integration

Tests run automatically on:
- Pull Requests to `main` or `develop`
- Pushes to `main` or `develop`
- Changes to `modules/` or `examples/` directories

See `.github/workflows/` for the test execution workflow.

## Writing New Tests

### Basic Module Test Template
```go
func TestMyModule(t *testing.T) {
    t.Parallel()
    
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/my-module",
        Vars: map[string]interface{}{
            "location": "eastus",
        },
    }
    
    terraform.Init(t, terraformOptions)
    err := terraform.Validate(t, terraformOptions)
    assert.NoError(t, err)
}
```

### Testing with Azure Resources
```go
func TestAzureResource(t *testing.T) {
    t.Parallel()
    
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/phase-1-foundation",
        Vars: map[string]interface{}{
            "location": "eastus",
            "subscription_id": os.Getenv("ARM_SUBSCRIPTION_ID"),
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    // Verify Azure resource exists
    resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
    assert.NotEmpty(t, resourceGroupName)
}
```

## Best Practices

1. **Always use `t.Parallel()`** for independent tests to speed up execution
2. **Use `defer terraform.Destroy()`** to clean up resources after tests
3. **Validate outputs** to ensure modules produce expected results
4. **Mock Azure API calls** when possible to avoid costs and slow tests
5. **Use test helpers** to reduce code duplication across test files
6. **Document test scenarios** with clear comments
7. **Tag expensive tests** with a `// +build expensive` comment for optional execution

## Troubleshooting

### Tests fail with "subscription not found"
- Ensure Azure CLI is authenticated: `az login`
- Set `ARM_SUBSCRIPTION_ID` environment variable

### Terraform init timeout
- Increase test timeout: `go test -timeout 60m`
- Check network connectivity to Terraform registries

### Resource cleanup failures
- Manually cleanup resources: `terraform destroy -auto-approve`
- Check Azure portal for orphaned resources

## Performance Optimization

- Run tests in parallel: `go test -parallel 4`
- Use `-short` flag to skip expensive tests: `go test -short`
- Cache Terraform provider downloads with `.terraform` directory

## References

- [Terratest Documentation](https://terratest.gruntwork.io/)
- [Go Testing](https://golang.org/pkg/testing/)
- [Azure Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
