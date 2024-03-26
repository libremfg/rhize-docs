
{{ $slice := "" }}
{{ $version := (.Get 0) }}
{{ $v2 := ( replace $version "." "-")  }}


{{ range readDir "content/releases/changelog" }}
   {{ if (strings.Contains $v2 .Name ) }}
   IS {{ $version }}

   {{ else }}
   NOT {{ $version }} {{ .Name }} {{ $v2 }}
{{ end }}
{{ end }}

