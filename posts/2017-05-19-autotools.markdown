---
title: Getting Started with Autotools
---
## Installation
### Linux
You should be able to install Autotools through your package manager.

#### Debian
    sudo apt-get install autotools

#### Ubuntu
    sudo apt-get install autotools-dev autoconf

#### Fedora
    sudo dnf install autoconf automake

#### Arch
    sudo pacman -S autoconf automake libtool

### macOS
First install [Homebrew](https://brew.sh/), a package manager for macOS. Then just run the commands,

    brew install autoconf
    brew install automake

### Windows
First install [Cygwin](https://cygwin.com) then install automake and autoconf from the cygwin packages.

## Creating our project

We will use C as the programming language, but don’t worry if you do not know C. It is not the focus of the tutorial. First we will need to create a directory somewhere to hold our project. Using Linux, macOS, or Cygwin enter the commands
    mkdir tutorial
    cd tutorial
into a terminal. The first command creates the directory named tutorial, the second one moves into that directory. Notice that autotools is plural. Autotools is a collection of programs that work together to build software. First we will look at autoconf. The purpose of autoconf is to look at the computer it runs on a determine what features it has. For example, it will try to figure out what compiler is installed on your system. Based on the test that autoconf performs it will tell the other tools in autotools to build the software differently. Now that we are here lets create a file named `configure.ac` in that same directory with our favorite text editor. This is the file that tells autoconf what to do. Enter
    AC_INIT([tutorial], [0.1.0], [example@example.com])
    AC_PREREQ([2.67])
    AC_CONFIG_AUX_DIR([aux-build])
    AM_INIT_AUTOMAKE([-Wall -Werror subdir-objects foreign])
    AC_PROG_CC
    AC_CONFIG_HEADERS([config.h])
    AC_CONFIG_FILES([Makefile])
    AC_OUTPUT
into the `configure.ac` file

One important thing to remember is that autoconf files are actually shell scripts. All of the commands are actually macros that get expanded to full shell commands. The first command initializes autoconf. All parameters to macros must be enclosed in square brackets. The parameter `[tutorial]` is the name of the project and you should change it to match whatever project you are using. The second parameter is the version of the program, and the third parameter is optional and is an email address to contact with bug reports. You will want to remove this or change it to your email address. Command `AC_PREREQ` tells autoconf what version of autoconf is required. If the version of autoconf that processes this file is less than the version it will quit with an error. One downside of Autotools is that it does generate many intermediate and temporary files. We can put some of those files in a separate directory. First we should make that directory, which in this case I called "aux-build", with the command,
    mkdir aux-build
from the project directory. The autoconfig command `AC_CONFIG_AUX_DIR([aux-build])` tells autoconf to use the directory "aux-build" to store some temporary files. You will also need to create that directory with the command mkdir aux-build. We will use automake to do the actual compilation of our code so we need to tell autoconf to get automake setup. `-Wall` makes it so that automake will check for more warnings that it normally would. `-Werror` tells automake to turn any warnings into errors. We do this so that we cannot simply ignore a warning. Finally, we will put all of our source files in a subdirectory called `src` in order to keep our project more organized. Lets create that directory now. From the project directory run the command `mkdir src`. The parameter `subdir-objects` tells automake to put the compiled `.o` files in the same directory as the source files and not in the root directory. This helps the project directory from becoming too cluttered. The final parameter, `foreign` is used because by default automake expects your project to have a certain structure. Foreign tells automake to accept any structure for the project. Since we will use C for this project we need to tell autoconf to check for things like a C compiler and linker and that is what the `AC_PROG_CC` command does. We will want to communicate the results of tests performed by autoconf to our program through a file called config.h. In this file autoconf will place several different `#define ...` directives. Then in our code we can place `#ifdef` in order to compile the code differently depending on the underlying system. The next command, `AC_CONFIG_HEADERS` tells autoconf to create that `config.h` file. Since we are using autotools we will not directly create our Makefile. Instead, we will create a file called `Makefile.am` and from that a makefile is generated. So, the command `AC_CONFIG_FILES([Makefile])` tells autoconf to generate the makefile. Finally, so far we have only told autoconf, if we were to build the project, how we would like it done. `AC_OUTPUT` is the command that acutally does the building of the project.

Now we are done with autoconf! Lets move on to automake. Create a file called `Makefile.am`. The purpose of automake is to perform the compilation of your program and keep track of dependencies between files and libraries in your program. The `Makefile.am` should contain
    bin_PROGRAMS = tutorial
    tutorial_SOURCES = \
        src/main.c
The first line contains the names of all of the exectuables that should be compiled as part of your project. In this case we only want to create one executable named, `tutorial`. The next line contains the names of all of the source files in your program, both the header files as well as any `.c` files. Notice the backslash, makefiles are whitespace sensitive so the back slash tells automake that the line following the line with a backslash is really a continuation of the same line. Without the backslash the programmer would have to put all of the source file names on the same line. We wrote `src/main.c` as one of the source files but that file does not exist! Lets fix that. In a text editor create a file, `main.c` in the `src` directory. The contents of the file will be a simple Hello World program.

    #include <stdio.h>
    
    int
    main ()
    {
      puts ("Hello, World!");
    }

We are almost ready now. There are a few minor files that automake still needs but it can create those files for us. Run,
    autoreconf
After running this command you will notice that it fails and complains about missing files. To add those files run,
    automake --add-missing
and automake will create those files. Finally, run
    autoreconf
Since autotools is a collection of tools they must be run in the correct order. The program autoreconf will call all of the other autotools programs in the correct order. Now our project source code is in a state where we could distribute it. In order to compile our program we can run the commands,
    ./configure
    make
After we have run configure once we don’t have to do it again and can just recompile with
    make
One benefit of using autotools is that many targets have been provided for us. For example to install the program we can just run
    make install
or if we want to distribute the executable,
    make dist
If we want to add more files we simply add them to the “Makefile.ac” file like this,
    bin_PROGRAMS = tutorial
    tutorial_SOURCES = \
            src/main.c \
            src/foo.h \
            src/foo.c
and then just recompile with,
    make
