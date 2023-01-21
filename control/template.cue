package template

provider_version:    string @tag(provider_version)
provider_identifier: string @tag(provider_identifier)

"provider_tf": {
	out: {
		terraform: {
			required_providers: {
				provider: {
					source:  provider_identifier
					version: provider_version
				}
			}
		}
	}
}

"lockfile_hcl": {
	out: """
provider "registry.terraform.io/\(provider_identifier)" {
  version     = "\(provider_version)"
}

"""
}

metadata: {
	input: {
		terraform: {
			terraform_version: string
		}
		timestamp:                      string
		"github.trigger.commit":        string
		"github.workflow.commit":       string
		"github.workflow.ref":          string
		"schema.raw.filename":          string
		"schema.raw.size.bytes":        string // not int, as it comes from a .txt file
		"schema.raw.sha512":            string
		"schema.compressed.filename":   string
		"schema.compressed.size.bytes": string // ditto raw.size.bytes
		"schema.compressed.format":     string
		"schema.compressed.sha512":     string
	}

	out: {
		"\(provider_version)": {
			provider: provider_identifier
			version:  provider_version
			created: {
				at: input.timestamp
				by: {
					terraform: input.terraform
					commit: {
						trigger:      input."github.trigger.commit"
						workflow_sha: input."github.workflow.commit"
						workflow_ref: input."github.workflow.ref"
					}
				}
			}
			contents: {
				raw: {
					filename: input."schema.raw.filename"
					bytes:    input."schema.raw.size.bytes"
					sha512:   input."schema.raw.sha512"
				}
				compressed: {
					filename: input."schema.compressed.filename"
					format:   input."schema.compressed.format"
					bytes:    input."schema.compressed.size.bytes"
					sha512:   input."schema.compressed.sha512"
				}
			}
		}
	}
}
