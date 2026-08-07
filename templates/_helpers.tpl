{{/*
Repave helm-chart-generic helpers (prefix: repave.).
*/}}
{{- define "repave.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "repave.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "repave.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}

{{- define "repave.selectorLabels" -}}
app.kubernetes.io/name: {{ include "repave.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "repave.labels" -}}
helm.sh/chart: {{ include "repave.chart" . }}
{{ include "repave.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
managed-by: repave
repave.dev/owner: {{ required "set values.owner for FinOps allocation" .Values.owner | quote }}
repave.dev/service: {{ required "set values.serviceName for FinOps allocation" .Values.serviceName | quote }}
repave.dev/environment: {{ required "set values.environment for FinOps allocation" .Values.environment | quote }}
{{- end }}
