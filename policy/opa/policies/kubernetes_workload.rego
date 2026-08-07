# Kubernetes manifest checks for Helm-rendered golden paths (conftest input per document).
package kubernetes

import rego.v1

required_finops_labels := {
	"repave.dev/owner",
	"repave.dev/service",
	"repave.dev/environment",
}

deny contains msg if {
	input.kind == "Deployment"
	not input.metadata.name
	msg := "Deployment must include metadata.name"
}

deny contains msg if {
	input.kind == "Deployment"
	label := required_finops_labels[_]
	not input.metadata.labels[label]
	msg := sprintf("Deployment metadata.labels must include %s", [label])
}
