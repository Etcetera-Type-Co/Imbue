#!/bin/sh
set -e
#source ../env/bin/activate

fontName="Imbue"

echo ".
GENERATING STATIC OTF
."
OT_DIR=../fonts/otf
rm -rf $OT_DIR
mkdir -p $OT_DIR

fontmake -g $fontName.glyphs --family-name "$fontName 10pt" -i -o otf --output-dir $OT_DIR
fontmake -g $fontName.glyphs --family-name "$fontName 50pt" -i -o otf --output-dir $OT_DIR
fontmake -g $fontName.glyphs --family-name "$fontName 100pt" -i -o otf --output-dir $OT_DIR


echo "Post processing OTFs"
otfs=$(ls $OT_DIR/*.otf)
for otf in $otfs
do
	gftools fix-dsig -f $otf
done


echo "Building webfonts"
rm -rf ../fonts/web/woff2
ttfs=$(ls ../fonts/ttf/*.ttf)
for ttf in $ttfs; do
    woff2_compress $ttf
done
mkdir -p ../fonts/web/woff2
woff2s=$(ls ../fonts/*/*.woff2)
for woff2 in $woff2s; do
    mv $woff2 ../fonts/web/woff2/$(basename $woff2)
done

rm -rf ../fonts/web/woff
ttfs=$(ls ../fonts/ttf/*.ttf)
for ttf in $ttfs; do
    sfnt2woff-zopfli $ttf
done

mkdir -p ../fonts/web/woff
woffs=$(ls ../fonts/*/*.woff)
for woff in $woffs; do
    mv $woff ../fonts/web/woff/$(basename $woff)
done
