---

# templates/_helpers.tpl
{{/* Helper template for FinovaBank application */}}
{{- define "finovabank.labels" -}}
app: {{ .Chart.Name }}
{{- end -}}