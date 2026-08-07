# Prometheus alerting rules YAML (native mode).
package main

import rego.v1

deny contains msg if {
	group := input.groups[_]
	rule := group.rules[_]
	rule.alert
	not rule.annotations.runbook_url
	msg := sprintf("alert %s missing runbook_url annotation", [rule.alert])
}

deny contains msg if {
	group := input.groups[_]
	rule := group.rules[_]
	rule.alert
	not rule.labels.severity
	msg := sprintf("alert %s missing severity label", [rule.alert])
}
