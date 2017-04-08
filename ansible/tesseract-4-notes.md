# Notes for compiling tesseract 4 on CentOS

yum:
- autoconf
- autoconf-archive
- automake
- libtool
- libpng12-devel
- libjpeg-turbo-devel
- libtiff-devel
- zlib-devel
- libicu-devel
- pango-devel
- cairo-devel

## install leptonica 1.74.1 from source:
wget http://leptonica.org/source/leptonica-1.74.1.tar.gz
tar -xvf leptonica-1.74.1.tar.gz
cd leptonica-1.74.1
autoreconf -vi
./autobuild
./configure
./make-for-auto # may need to run ./make-for-local first then make then ./make-for-auto
sudo make
sudo make install

## install tesseract from source
cd ~
git clone --depth 1 https://github.com/tesseract-ocr/tesseract.git
cd tesseract
./autogen.sh
PKG_CONFIG_PATH=/usr/local/lib/pkgconfig LIBLEPT_HEADERSDIR=/usr/local/include ./configure --with-extra-includes=/usr/local/include --with-extra-libraries=/usr/local/lib
LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include" make
sudo make install
sudo ldconfig

## Language Data
mkdir traineddata
cd traineddata
wget https://github.com/tesseract-ocr/tessdata/raw/3.04.00/osd.traineddata
wget https://github.com/tesseract-ocr/tessdata/raw/3.04.00/equ.traineddata
wget https://github.com/tesseract-ocr/tessdata/raw/4.00/eng.traineddata

## hOCR config
cp ~/tesseract/tessdata/configs/ ~/tessdata/.

## Run Tesseract

TESSDATA_PREFIX=~/traineddata tesseract
