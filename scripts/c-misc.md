
# Install perf
```bash
sudo apt install linux-tools-generic
```

If in WSL:
```bash
rm /usr/bin/perf
ln -s /usr/lib/linux-tools/*-generic/perf /usr/bin/perf
```

# Markdown to pdf
```bash
sudo apt install pandoc texlive-latex-base texlive-latex-extra
pandoc README.md -o readme.pdf"
```

# Antlr
## Main Antlr
```sh
mkdir ~/.otcova-setup/.local/antlr4
wget -qO- http://www.antlr.org/download/antlr-4.13.2-complete.jar > ~/.otcova-setup/.local/antlr4/antlr-4.13.2-complete.jar
```

File `~/.otcova-setup/.bin/antlr4` with:
```bash
#! /bin/bash
export CLASSPATH=".:$HOME/.otcova-setup/.local/antlr4/antlr-4.13.2-complete.jar:$CLASSPATH"
java -jar ~/.otcova-setup/.local/antlr4/antlr-4.13.2-complete.jar "$@"
```

```sh
chmod +x ~/.otcova-setup/.bin/antlr4
```

## C++ Runtime

```bash
sudo apt-get install cmake

# Go to install folder
mkdir ~/.otcova-setup/.local/antlr4_cpp_runtime/
cd ~/.otcova-setup/.local/antlr4_cpp_runtime/

# download source
wget http://www.antlr.org/download/antlr4-cpp-runtime-4.13.2-source.zip

# unzip file
unzip antlr4-cpp-runtime-4.13.2-source.zip
rm antlr4-cpp-runtime-4.13.2-source.zip

# create build directory for cmake
mkdir build
mkdir install

# create makefiles
cd ~/.otcova-setup/.local/antlr4_cpp_runtime/build
cmake .. -DCMAKE_INSTALL_PREFIX=~/.otcova-setup/.local/antlr4_cpp_runtime/install -DCMAKE_BUILD_TYPE=Release

# build and install
make
make install

# Link antlr install with runtime
cd ~/.otcova-setup/.local/antlr4_cpp_runtime/install
mkdir bin
ln ~/.otcova-setup/.local/antlr4/antlr-4.13.2-complete.jar ./lib
ln ~/.otcova-setup/.bin/antlr4 ./bin

# Relevant folders
echo 'You might want to:'
echo '--- Add to ~/.bashrc ----'
echo 'export ANTLR4_ROOT="$HOME/.otcova-setup/.local/antlr4_cpp_runtime/install"'
echo 'export CLASSPATH=".:$ANTLR4_ROOT/lib/antlr-4.13.2-complete.jar${CLASSPATH:+:$CLASSPATH}"'
echo 'export LD_LIBRARY_PATH="$ANTLR4_ROOT/lib"'
echo 
echo '--- Update Makefile ----'
echo 'ANTLR_ROOT := $(HOME)/.otcova-setup/.local/antlr4_cpp_runtime/install'
```











