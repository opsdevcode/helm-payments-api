# GitOps delivery manifests (Argo CD Application, Flux HelmRelease) — conftest input per document.
package main

import rego.v1

_exact_version(version) if regex.match(`^\d+\.\d+\.\d+([-+][0-9A-Za-z.-]+)?$`, version)

_pinned_repo(url) if startswith(url, "https://")

_pinned_repo(url) if startswith(url, "oci://")

# —— Argo CD Application ——

deny contains msg if {
	input.kind == "Application"
	revision := input.spec.source.targetRevision
	not _exact_version(revision)
	msg := sprintf(
		"Application %s targetRevision %q must be an exact chart version, not a floating reference",
		[input.metadata.name, revision],
	)
}

deny contains msg if {
	input.kind == "Application"
	url := input.spec.source.repoURL
	not _pinned_repo(url)
	msg := sprintf("Application %s repoURL %q must be an https:// or oci:// URL", [input.metadata.name, url])
}

deny contains msg if {
	input.kind == "Application"
	not input.spec.project
	msg := sprintf("Application %s must set spec.project", [input.metadata.name])
}

deny contains msg if {
	input.kind == "Application"
	input.spec.project == "default"
	msg := sprintf("Application %s must not use the implicit default project", [input.metadata.name])
}

deny contains msg if {
	input.kind == "Application"
	not input.spec.destination.server
	msg := sprintf("Application %s must set spec.destination.server", [input.metadata.name])
}

deny contains msg if {
	input.kind == "Application"
	not input.spec.destination.namespace
	msg := sprintf("Application %s must set spec.destination.namespace", [input.metadata.name])
}

# Automated sync must state both prune and selfHeal; defaulting either one silently
# changes what happens to resources a developer deletes.
deny contains msg if {
	input.kind == "Application"
	automated := input.spec.syncPolicy.automated
	not has_key(automated, "prune")
	msg := sprintf("Application %s automated sync must declare prune explicitly", [input.metadata.name])
}

deny contains msg if {
	input.kind == "Application"
	automated := input.spec.syncPolicy.automated
	not has_key(automated, "selfHeal")
	msg := sprintf("Application %s automated sync must declare selfHeal explicitly", [input.metadata.name])
}

# —— Flux HelmRelease ——

deny contains msg if {
	input.kind == "HelmRelease"
	version := input.spec.chart.spec.version
	not _exact_version(version)
	msg := sprintf(
		"HelmRelease %s chart version %q must be an exact chart version, not a floating reference",
		[input.metadata.name, version],
	)
}

deny contains msg if {
	input.kind == "HelmRelease"
	not input.spec.chart.spec.sourceRef.name
	msg := sprintf("HelmRelease %s must set chart sourceRef.name", [input.metadata.name])
}

deny contains msg if {
	input.kind == "HelmRelease"
	not input.spec.targetNamespace
	msg := sprintf("HelmRelease %s must set spec.targetNamespace", [input.metadata.name])
}

deny contains msg if {
	input.kind == "HelmRelease"
	not input.spec.storageNamespace
	msg := sprintf("HelmRelease %s must set spec.storageNamespace", [input.metadata.name])
}

has_key(obj, key) if _ = obj[key]
