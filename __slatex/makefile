TO_CLEAN=.pdf .aux .toc .nav .snm .log .out _minted-main build_py_tex build .bbl .blg

all: texcomp
xall: texcomp

texcomp:
	pdflatex -shell-escape main.tex && \
	bibtex main && \
	pdflatex -shell-escape main.tex && \
	pdflatex -shell-escape main.tex

openpdf:
	firefox main.pdf &

clean:
	@for pattern in ${TO_CLEAN}; do \
		files=`find . -regex .*\$${pattern}`; \
		rm -rf $${files}; \
	done