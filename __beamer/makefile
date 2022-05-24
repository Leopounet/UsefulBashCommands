TO_CLEAN=.pdf .aux .toc .nav .snm .log .out _minted-main build_py_tex build .bbl .blg

all: clearall copyfiles texcomp

all: clearall copyfiles texcomp
xall: clearall copyfiles xtexcomp

clearall:
	if [ ! -d build ]; then \
		mkdir build; \
	fi
	rm -rf build/*

copyfiles:
	$(shell find . -name "*.tex" -not -path "./build/*" -exec cp --parents \{\} build/ \;)

texcomp:
	pdflatex -shell-escape main.tex && \
	pdflatex -shell-escape main.tex && \
	pdflatex -shell-escape main.tex

xtexcomp:
	cd build && \
	xelatex -shell-escape main.tex && \
	xelatex -shell-escape main.tex && \
	xelatex -shell-escape main.tex && \
	cp main.pdf ../ && \
	cd ..

openpdf:
	firefox main.pdf &

clean:
	@for pattern in ${TO_CLEAN}; do \
		files=`find . -regex .*\$${pattern}`; \
		rm -rf $${files}; \
	done