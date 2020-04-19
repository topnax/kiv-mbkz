while inotifywait vzor_prace.tex; do echo changed; rubber --pdf vzor_prace.tex; done
