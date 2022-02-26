
Instructions for creating the Matrix C shared library file
=======================================================================

0. Using Iceberg, load the 'Matrix' package in a Pharo image
   This will clone the library repo, including the C source

1. Install the gcc compiler:
   $ sudo apt update && sudo apt upgrade
   $ sudo apt install build-essential
   $ sudo apt install software-properties-common
   $ sudo apt install gcc 

2. Compile the source code:
   $ cd ~/Pharo/images
   $ cd 'Pharo 9.0 - 64bit (Pharo Matrices)'
   $ cd pharo-local/iceberg/Pharo-Matrices/c
   $ ls -al  # To verify correct location
   $ gcc -c -Wall -Werror -fpic matrix.c
   $ gcc -shared -o libmatrix.so matrix.o

3. Move the shared library file into place:
   $ mv libmatrix.so ../../../../ 

4. Verify the file is co-located with the image:
   $ cd ../../../..
   $ ls -al
   -rwxr-xr-x 1 user  group     15792 Feb 25 08:05  libmatrix.so*
   -rw-r--r-- 1 user  group 296063264 Feb 26 09:38 'Pharo 9.0 - 64bit (Pharo Matrices).image'  

-----

