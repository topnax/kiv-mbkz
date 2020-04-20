while inotifywait kral-doc.tex; do echo changed; rubber --pdf kral-doc.tex; done
