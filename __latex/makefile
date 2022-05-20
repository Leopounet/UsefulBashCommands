all: texcomp
xall: pyscript xtexcomp

texcomp:
	pdflatex -shell-escape main.tex && \
	pdflatex -shell-escape main.tex && \
	pdflatex -shell-escape main.tex

xtexcomp:
	cd build_py_tex && \
	xelatex -shell-escape main.tex && \
	xelatex -shell-escape main.tex && \
	xelatex -shell-escape main.tex && \
	cp main.pdf ../ && \
	cd ..

pyscript:
	python3 fetch.py

openpdf:
	firefox main.pdf &

clean:
	rm -rf build_py_tex
	rm -rf *.toc *.aux *.pdf *.log *.out _minted-main