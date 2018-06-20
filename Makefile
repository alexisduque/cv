TITLE = cv-*
FILE = cv-*.tex
NAME = cv
GRAPHIC_DIR = figures
PDFLATEX = xelatex cv-en.tex && xelatex cv-fr.tex && xelatex cv-en-mobicom.tex
BIBER = bibtex ${OUTPUT}/${FILE}
OUTPUT = .
# Finding the required images
FIGSRC	:= $(wildcard $(GRAPHIC_DIR)/*.svg)
FIG	:= $(FIGSRC:%.svg=%.pdf)
FIGTEX	:= $(FIGSRC:%.svg=%.pdf_tex)

.PHONY: all, bib, _main, _bib

all: build

build: pdf

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
	xdg-open cv-en-mobicom.pdf

lint:
	chktex -W
	chktex -q -n 6 *.tex chapters.*.tex 2>/dev/null | tee lint.out
	test ! -s lint.out

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

upload:
	./dropbox_uploader.sh -f .dropbox_uploader upload cv-fr.pdf cv-fr.pdf
	./dropbox_uploader.sh -f .dropbox_uploader upload cv-en.pdf cv-en.pdf
	./dropbox_uploader.sh -f .dropbox_uploader upload cv-en-mobicom.pdf cv-en-mobicom.pdf