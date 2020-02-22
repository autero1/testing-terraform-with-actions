// +build unit

package test

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"path/filepath"
	"testing"
)

func TestStaticSiteValidity(t *testing.T) {
	t.Parallel()

	_fixturesDir := test_structure.CopyTerraformFolderToTemp(t, "../", "test/fixtures")
	exampleDir := filepath.Join(_fixturesDir, "static-site")
	terratestOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: exampleDir,
		Vars:         map[string]interface{}{},
	}
	t.Logf("Running in %s", exampleDir)
	output := terraform.InitAndPlan(t, terratestOptions)
	assert.Contains(t, output, "2 to add, 0 to change, 0 to destroy", "Plan OK and should attempt to create 2 resources")
}
