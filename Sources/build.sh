#!/bin/sh
set -e
#source ../env/bin/activate

fontName="Imbue"
axes="opsz,wght"

##########################################

echo ".
GENERATING VARIABLE
."
VF_DIR=../fonts/variable
rm -rf $VF_DIR
mkdir -p $VF_DIR

fontmake -g $fontName.glyphs --family-name $fontName -o variable --output-path $VF_DIR/$fontName[$axes].ttf

##########################################

echo ".
POST-PROCESSING VF
."
vfs=$(ls $VF_DIR/*.ttf)
for font in $vfs
do
	gftools fix-dsig --autofix $font
	gftools fix-nonhinting $font $font.fix
	mv $font.fix $font
	gftools fix-unwanted-tables --tables MVAR $font
done
rm $VF_DIR/*gasp*

python gen_stat.py $VF_DIR/$fontName[$axes].ttf

##########################################

echo ".
GENERATING STATIC TTF
."
TT_DIR=../fonts/ttf
rm -rf $TT_DIR
mkdir -p $TT_DIR

fontmake -g $fontName.glyphs --family-name "$fontName 10pt" -i -o ttf --output-dir $TT_DIR
fontmake -g $fontName.glyphs --family-name "$fontName 50pt" -i -o ttf --output-dir $TT_DIR
fontmake -g $fontName.glyphs --family-name "$fontName 100pt" -i -o ttf --output-dir $TT_DIR

##########################################

echo ".
POST-PROCESSING TTF
."
ttfs=$(ls $TT_DIR/*.ttf)
for font in $ttfs
do
	gftools fix-dsig --autofix $font
	python -m ttfautohint $font $font.fix
	[ -f $font.fix ] && mv $font.fix $font
	gftools fix-hinting $font
	[ -f $font.fix ] && mv $font.fix $font
done

rm -rf master_ufo/ instance_ufo/

echo "Complete!"
