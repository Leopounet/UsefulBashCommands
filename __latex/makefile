TO_CLEAN=.pdf .aux .toc .nav .snm .log .out _minted-main build_py_tex build .bbl .blg

all: texcomp
xall: pyscript xtexcomp

texcomp:
	pdflatex -shell-escape main.tex && \
	bibtex main && \
	pdflatex -shell-escape main.tex && \
	pdflatex -shell-escape main.tex

xtexcomp:
	cd build_py_tex && \
	xelatex -shell-escape main.tex && \
	bibtex main && \
	xelatex -shell-escape main.tex && \
	xelatex -shell-escape main.tex && \
	cp main.pdf ../ && \
	cd ..

pyscript:
	python3 fetch.py

openpdf:
	firefox main.pdf &

clean:
	@for pattern in ${TO_CLEAN}; do \
		files=`find . -regex .*\$${pattern}`; \
		rm -rf $${files}; \
	done