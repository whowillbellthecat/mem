home(X,Y):-environ('HOME',H),atom_join([H,X],'/',Y).
pdfviewer(mupdf).
logfile(X):-memdir(M),atom_join([M,'dat.pl'],'/',X).
carddir(X):-home('.cards',X).
memdir(X):-home('.mem',X).
