MY_BUILD=${HOME}/build
MY_X86=${MY_BUILD}/x86

#Compiling SDL (ffplay requires this as renderer)
# note:
#  It becomes impossible for me to link SDL libraries statically with ffplay
# because of some recent changes. thus you have to copy SDL.dll to the folder
# in your PATH.(26/03/2011)
cd ${MY_X86}/SDL-*
./configure --prefix=/mingw/i686-pc-mingw32
make clean && make && make install
cp /mingw/i686-pc-mingw32/bin/SDL.dll /usr/local/bin/

#Compiling OpenSSL (librtmp requires this)
cd ${MY_X86}/openssl-*
# note:
# for openssl, the first 'C' of Configure is a capital letter. 
./Configure mingw --prefix=/mingw/i686-pc-mingw32
make && make install

#Compiling librtmp(rtmpdump)
cd ${MY_X86}/rtmpdump-*
make prefix=/mingw/i686-pc-mingw32 SYS=mingw SHARED=no
make install prefix=/mingw/i686-pc-mingw32 SYS=mingw SHARED=no
# note:
# librtmp links libws2_32 and libwinmm on MinGW, but it is not written in librtmp.pc.
# And, ffmpeg's configure requires pkg-config to check librtmp.
# Thus you should edit librtmp.pc as follows.
sed -i -e 's/Libs: -L${libdir} -lrtmp -lz/Libs: -L${libdir} -lrtmp -lz -lws2_32 -lwinmm/g' /mingw/i686-pc-mingw32/lib/pkgconfig/librtmp.pc

#Delete orc and schroedinger compile(20110421)

#Compiling libvpx
#20110313:update libvpx version from 0.9.5 to 0.9.6
cd ${MY_X86}/libvpx-*
./configure --target=x86-win32-gcc --cpu=i686 --disable-examples --enable-runtime-cpu-detect
make clean && make
cp libvpx.a /mingw/i686-pc-mingw32/lib/
mkdir -p /mingw/i686-pc-mingw32/include/vpx
cp ./vpx/*.h /mingw/i686-pc-mingw32/include/vpx/

#Compiling xvid
#20110325:update xvidcore version from 1.3.0 to 1.3.1
cd ${MY_X86}/xvidcore/build/generic
sed -i -e s/\-mno\-cygwin// ./configure
./configure
make
cp =build/xvidcore.a /mingw/i686-pc-mingw32/lib/libxvidcore.a
cp ../../src/xvid.h /mingw/i686-pc-mingw32/include/

#Compiling faac
# note:
# faac is incompatible with GPL/LGPL.
cd ${MY_X86}/faac-*
./configure --prefix=/mingw/i686-pc-mingw32 --disable-shared --without-mp4v2
make clean && make && make install-strip

#Compiling opencore-amr
# note:
# opencore-amr's license(Apache 2.0) is compatible with GPLv3 or later.
cd ${MY_X86}/opencore-amr-*
./configure --prefix=/mingw/i686-pc-mingw32 --disable-shared
make clean && make && make install-strip

#Compiling vo-aacenc
# note:
# vo-aacenc's license(Apache 2.0) is compatible with GPLv3 or later.
# vo-aacenc-0.1.0.tar.gz includes some clitical issues.
# thus you should get latest source code from git repo.
cd ${MY_X86}/vo-aacenc
autoreconf
./configure --prefix=/mingw/i686-pc-mingw32 --disable-shared
make clean && make && make install-strip

#Compiling vo-amrwbenc
# note:
# vo-amrwbenc's license(Apache 2.0) is compatible with GPLv3 or later.
cd ${MY_X86}/vo-amrwbenc
autoreconf
./configure --prefix=/mingw/i686-pc-mingw32 --disable-shared
make clean && make && make install-strip

#Compiling libogg (libtheora/libvorbis/speex requires this)
cd ${MY_X86}/libogg-*
./configure --prefix=/mingw/i686-pc-mingw32 --disable-shared
make clean && make && make install-strip

#Compiling libtheora
cd ${MY_X86}/libtheora-*
./configure --prefix=/mingw/i686-pc-mingw32 --disable-shared
make clean && make && make install-strip

#Compiling libvorbis
cd ${MY_X86}/libvorbis-*
./configure --prefix=/mingw/i686-pc-mingw32 --disable-shared
make clean && make && make install-strip

#Compiling speex
cd ${MY_X86}/speex-*
./configure --prefix=/mingw/i686-pc-mingw32 --disable-shared --enable-sse
make clean && make && make install-strip

#Compiling openjpeg
# note:
# Compiling openjpeg is weird.
cd ${MY_X86}/openjpeg_*
./configure && make clean
./configure --prefix=/mingw/i686-pc-mingw32 --disable-shared
make clean && make && make install-strip
# note:
#  The .pc files of openjpeg-1.4.0 are installed into /usr/lib/pkgconfig
# instead of install-prefix/lib/pkgconfig.
#  You should move these files into install-prefix/lib/pkgconfig.
mv /usr/lib/pkgconfig/libopenjpeg*.pc /mingw/i686-pc-mingw32/lib/pkgconfig/

#Compiling libx264
# Edit configure line assume r1995 or later(20110514)
cd ${MY_X86}/x264
./configure --prefix=/mingw/i686-pc-mingw32 --disable-cli --enable-static --disable-gpac --disable-swscale --enable-win32thread --enable-strip
make clean && make # or make fprofiled VIDS='/path/to/file.y4m'
make install

# ------------compiling 32bit ffmpeg----------------
# note:
#  If you want to redistribute your ffmpeg binaries,
# delete '--enable-nonfree' and '--enable-libfaac' from following configures.
#  Add enable-libvo-aacenc and enable-libvo-amrwbenc (22/04/2011).
cd ${MY_X86}/ffmpeg
FFMPEGVER=`./version.sh`
PKG_CONFIG_PATH=/mingw/i686-pc-mingw32/lib/pkgconfig/ \
 ./configure --prefix=/mingw/i686-pc-mingw32 --disable-doc --enable-gpl \
 --enable-version3 --enable-nonfree --enable-postproc --enable-w32threads \
 --enable-runtime-cpudetect --enable-memalign-hack --enable-avisynth \
 --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libfaac \
 --enable-libmp3lame --enable-libopenjpeg --enable-librtmp --enable-libspeex \
 --enable-libtheora --enable-libvorbis --enable-libvo-aacenc --enable-libvo-amrwbenc \
 --enable-libvpx --enable-libx264 --enable-libxvid --disable-decoder=libvpx \
 --disable-hwaccels --cpu=i686 --disable-debug --extra-cflags=-fno-strict-aliasing
make clean && make && make install
for i in ffmpeg ffplay ffprobe
do
  cp /mingw/i686-pc-mingw32/bin/${i}.exe /usr/local/bin/${i}_x86_${FFMPEGVER}.exe
done