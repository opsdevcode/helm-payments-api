# Native observability artifacts (JSON/YAML) — not Terraform plan input.
package main

import rego.v1

_has_managed_by_tag(tags) if {
	tags[_] == "managed-by:repave"
}

deny contains msg if {
	input.name
	input.type
	not input.message
	msg := "datadog monitor must include message"
}

deny contains msg if {
	input.name
	input.type
	tags := input.tags
	not _has_managed_by_tag(tags)
	msg := sprintf("datadog monitor %s missing managed-by:repave tag", [input.name])
}

deny contains msg if {
	input.title
	input.uid
	tags := input.tags
	not _has_managed_by_tag(tags)
	msg := sprintf("grafana dashboard %s missing managed-by:repave tag", [input.title])
}

deny contains msg if {
	input.title
	input.layout_type
	tags := input.tags
	not _has_managed_by_tag(tags)
	msg := sprintf("datadog dashboard %s missing managed-by:repave tag", [input.title])
}
