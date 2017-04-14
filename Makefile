TITLE = cv-*
FILE = cv-*.tex
NAME = cv
GRAPHIC_DIR = figures
PDFLATEX = xelatex cv-en.tex && xelatex cv-fr.tex
BIBER = bibtex ${OUTPUT}/${FILE}
OUTPUT = .
# Finding the required images
FIGSRC	:= $(wildcard $(GRAPHIC_DIR)/*.svg)
FIG	:= $(FIGSRC:%.svg=%.pdf)
FIGTEX	:= $(FIGSRC:%.svg=%.pdf_tex)

.PHONY: all, bib, _main, _bib

all: build open

build: pdf log

#bib: _bib
bib: _bib _post

pdf: _pre

clean:
	rm -rf .tmp/*.aux
	rm -rf build	
	rm -f *.dvi *.log *.bak *.aux *.bbl *.gz *.fls *.blg *.idx *.ps *.eps *.toc *.out *~ *.fdb_latexmk


# Export pdf (and pdf_TeX) file from each svg image
all-images : $(FIG) $(FIGTEX)

$(GRAPHIC_DIR)/%.pdf $(GRAPHIC_DIR)/%.pdf_tex : $(GRAPHIC_DIR)/%.svg

	inkscape -D --export-pdf=$(<:.svg=.pdf) $<
	pdfcrop --margins '5 5 5 5' $(<:.svg=.pdf) $(<:.svg=.pdf)  

# Export pdf (and pdf_TeX) file from each svg image
image :
	inkscape -D --export-pdf=$(IMAGE:%.svg=%.pdf) ${IMAGE}
	pdfcrop --margins '5 5 5 5' $(IMAGE:%.svg=%.pdf) $(IMAGE:%.svg=%.pdf)

# Clean up image outputs
clean-images : 
	rm -f $(FIG) $(FIGTEX)
 
purge:
	rm -rf .tmp/
	rm -rf build/
	rm -f *.dvi *.log *.bak *.aux *.bbl *.blg  *.gz *.fls  *.idx *.ps *.eps *.pdf *.toc *.out *~ *.fdb_latexmk

import:
	rsync -L ~/Documents/library.bib ./

open:
	xdg-open cv-fr.pdf
	xdg-open cv-en.pdf

_pre:
	${PDFLATEX}
	${PDFLATEX}

_bib:
	${BIBER}

_post:
	${PDFLATEX}
	${PDFLATEX}
	cp ${OUTPUT}/${FILE}.pdf ./${TITLE}.pdf

log:
	grep --color=always Warn ${OUTPUT}/*.log || exit 0