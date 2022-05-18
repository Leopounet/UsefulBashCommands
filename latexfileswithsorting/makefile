all: pyscript texcomp

texcomp:
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