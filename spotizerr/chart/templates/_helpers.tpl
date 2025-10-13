{{/*
Expand the name of the chart.
*/}}
{{- define "spotizerr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "spotizerr.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "spotizerr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "spotizerr.labels" -}}
helm.sh/chart: {{ include "spotizerr.chart" . }}
{{ include "spotizerr.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "spotizerr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spotizerr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "spotizerr.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "spotizerr.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Redis fullname
*/}}
{{- define "spotizerr.redis.fullname" -}}
{{- printf "%s-redis" (include "spotizerr.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Redis selector labels
*/}}
{{- define "spotizerr.redis.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spotizerr.name" . }}-redis
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: redis
{{- end }}

{{/*
Redis labels
*/}}
{{- define "spotizerr.redis.labels" -}}
helm.sh/chart: {{ include "spotizerr.chart" . }}
{{ include "spotizerr.redis.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Get the Redis password secret name
*/}}
{{- define "spotizerr.redis.secretName" -}}
{{- if .Values.redis.existingSecret }}
{{- .Values.redis.existingSecret }}
{{- else }}
{{- printf "%s-redis" (include "spotizerr.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Get the Spotizerr secret name
*/}}
{{- define "spotizerr.secretName" -}}
{{- printf "%s-secrets" (include "spotizerr.fullname" .) }}
{{- end }}

