all: clearall copyfiles texcomp

clearall:
	if [ ! -d build ]; then \
		mkdir build; \
	fi
	rm -rf build/*

copyfiles:
	$(shell find . -name "*.tex" -not -path "./build/*" -exec cp --parents \{\} build/ \;)

texcomp:
	cd build && \
	xelatex -shell-escape main.tex && \
	xelatex -shell-escape main.tex && \
	xelatex -shell-escape main.tex && \
	cp main.pdf ../ && \
	cd ..

openpdf:
	firefox main.pdf &

clean:
	rm -rf build/