package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestResourceGroupExample validates the resource group module
func TestResourceGroupExample(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/phase-1-foundation",
		Vars: map[string]interface{}{
			"location": "eastus",
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Verify outputs
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	assert.NotEmpty(t, resourceGroupName)
}

// TestModuleValidation runs terraform validate on all modules
func TestModuleValidation(t *testing.T) {
	modulesPath := "../modules"

	modules, err := os.ReadDir(modulesPath)
	if err != nil {
		t.Fatalf("Failed to read modules directory: %v", err)
	}

	for _, module := range modules {
		if module.IsDir() {
			t.Run(module.Name(), func(t *testing.T) {
				terraformOptions := &terraform.Options{
					TerraformDir: modulesPath + "/" + module.Name(),
				}

				terraform.Init(t, terraformOptions)

				err := terraform.Validate(t, terraformOptions)
				assert.NoError(t, err, "Module %s validation failed", module.Name())
			})
		}
	}
}

// TestModuleOutputs validates that all modules produce expected outputs
func TestModuleOutputs(t *testing.T) {
	modules := []string{
		"resource-group",
		"virtual-network",
		"storage-account",
		"key-vault",
	}

	for _, moduleName := range modules {
		t.Run(moduleName, func(t *testing.T) {
			terraformOptions := &terraform.Options{
				TerraformDir: "../modules/" + moduleName,
			}

			terraform.Init(t, terraformOptions)

			// Test that module can be parsed and validated
			err := terraform.Validate(t, terraformOptions)
			assert.NoError(t, err, "Module %s should validate successfully", moduleName)

			// Verify outputs file exists
			outputPath := "../modules/" + moduleName + "/outputs.tf"
			_, err = os.Stat(outputPath)
			assert.NoError(t, err, "Module %s should have outputs.tf", moduleName)
		})
	}
}

// BenchmarkModuleInit benchmarks terraform init performance
func BenchmarkModuleInit(b *testing.B) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/phase-1-foundation",
	}

	for i := 0; i < b.N; i++ {
		terraform.Init(b, terraformOptions)
	}
}
