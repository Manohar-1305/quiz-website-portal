{{- define "quiz-app.name" -}}
quiz-app
{{- end }}

{{- define "quiz-app.fullname" -}}
{{ include "quiz-app.name" . }}
{{- end }}

{{- define "quiz-app.labels" -}}
app: {{ include "quiz-app.name" . }}
{{- end }}
