# LuaLaTeX (UTF-8 and system fonts), everything generated goes to build/
$pdf_mode = 4;
$out_dir = 'build';
$bibtex_use = 2;
$lualatex = 'lualatex -synctex=1 -interaction=nonstopmode -file-line-error %O %S';
# `latexmk -pvc main.tex`: rebuilds on every change and shows the PDF in zathura
$pdf_previewer = 'zathura %S';
