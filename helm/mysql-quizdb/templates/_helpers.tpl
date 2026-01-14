{{- define "mysql-quizdb.name" -}}
mysql-quizdb
{{- end }}

{{- define "mysql-quizdb.fullname" -}}
{{ include "mysql-quizdb.name" . }}
{{- end }}

{{- define "mysql-quizdb.labels" -}}
app: {{ include "mysql-quizdb.name" . }}
{{- end }}
