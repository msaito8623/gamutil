## Test environments
* Debian 10.2.1, R 4.3.1 (local machine)
* Windows Server 2022, R-devel, 64 bit (on rhub)
* Ubuntu Linux 20.04.1 LTS, R-release, GCC (on rhub)
* Fedora Linux, R-devel, clang, gfortran (on rhub)

## R CMD check results
There were no ERRORs or WARNINGs.

There were four NOTEs:

1. One note for a new submission:
```
* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Motoki Saito <motokisaito.8623@gmail.com>'

New submission
```
I understand that this note simply indicates that this is a new submission and therefore I believe I can ignore this note.

2. Another note related to "lastMikTeXException", found on Windows.
```
* checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'
```
I believe that this note is caused by a bug in MiKTeX on the testing machine, as noted in [R-hub issue #503](https://github.com/r-hub/rhub/issues/503), and therefore it can be ignored.

3. The third note about the directory/file named "NULL", found on Windows.
```
* checking for non-standard things in the check directory ... NOTE
Found the following files/directories:
  ''NULL''
```
I believe that this note is due to an issue on Rhub [(R-hub issue #560)](https://github.com/r-hub/rhub/issues/560) and therefore can be ignored.

4. The fourth note about the missing "tidy" command, found on Ubuntu and Fedora.
```
* checking HTML version of manual ... NOTE
Skipping checking HTML validation: no command 'tidy' found
```
I understand that this is also a recurring issue on Rhub [(R-hub issue #548)](https://github.com/r-hub/rhub/issues/548) and therefore can be ignored.
