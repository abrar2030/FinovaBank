{{/*
Helpers for FinovaBank Kubernetes templates
*/}}

{{/* Create a default fully qualified app name */}}
{{- define "finovabank.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Create chart name and version as used by the chart label */}}
{{- define "finovabank.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Common labels */}}
{{- define "finovabank.labels" -}}
helm.sh/chart: {{ include "finovabank.chart" . }}
{{ include "finovabank.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/* Selector labels */}}
{{- define "finovabank.selectorLabels" -}}
app.kubernetes.io/name: {{ include "finovabank.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* Create the name of the service account to use */}}
{{- define "finovabank.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "finovabank.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Define the base name for resources */}}
{{- define "finovabank.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Define environment variables */}}
{{- define "finovabank.env" -}}
- name: API_BASE_URL
  value: {{ .Values.environment.API_BASE_URL | quote }}
{{- if .Values.environment.extra }}
{{- range $key, $value := .Values.environment.extra }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end -}}
