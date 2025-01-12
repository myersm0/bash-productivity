
## Introduction
A collection of convenience funtions to reduce typing in bash. These are things I always wished I could do in bash, but was not motivated enough to implement until recently when I lost much of the use of my hands and had to find ways to become efficient at the terminal again with little ability to type.

I consider the `navigation.sh` functions here to be by far the most valuable. Basically, with these functions, navigation around a filesystem in bash simplifies to entering a quick command and then selecting your destination from a menu. Your favorite and recent locations are remembered. This is invaluable if you often have to jump around a complicated filesystem with many, long paths.

## Installation
Source the files here from which you want to use the functions, for example:

```
git clone https://github.com/myersm0/bash-productivity
cd bash-productivity
source file_im_interested_in.sh # change name appropriately, or source all of them from your .bashrc
```

## Overview

### clip.sh
Contains a user-facing function `clip` to copy file contents to the system clipboard.

#### Usage
```
# grab all txt files and copy them to the clipboard, each with a header (specified by `-h` here)
find . | grep txt$ | clip -h

# grab a few specific files and do the same, but also impose a limit of 10 lines copied per file
clip -h -n10 a.txt b.txt c.txt

# similarly:
clip -h -n10 *txt
```

### grab.sh
Contains a function `grab` to find a file from your current directory (or up to `d` levels deep) and copy its full path to your system clipboard.

#### Usage
```
# look up to three levels deep for files ending in txt
grab -d 3 -r "txt$"

# as above, but this time search from /dir/to/search instead of from your current directory
grab -d 3 -r "txt$" -f /dir/to/search
```

### navigation.sh
Functions to speed up and ease file system navigation in bash. A history of the directories you visit will be saved to a local file at `$HOME/.cd_history` to facilitate retrieval.

Some of this code, especially the `menu` function which is used internally, was adapted from the book Pro Bash Programming by Chris F.A. Johnson.

#### Usage
First source the file `navigation.sh` or add it to your .bashrc.

Three basic user-facing functions are then available to you:
```
goahead
cdr
cdf
```

They all will present you a menu of cd options from which you can select and automatically cd into. `goahead` does so relative to your current location. `cdr` and `cdf` do so relative to your history, sorted either by most recent or by most frequent respectively.

They provide several regex options as well. A few examples are below:

```
# look ahead three levels deep but show only directories that contain txt files
goahead -d 3 -c "txt$"

# out of the 100 most recently visited directories (by default),
# show only the ones that have your current working directory as a prefix
cdr -p

# out of the 100 most recently visited directories (by default),
# show only the ones that match a provided regex pattern
cdr -r "my_regex"

#  as above, but show up to 50 results instead of just 15 by default
cdr -r "my_regex" -n 50
```



