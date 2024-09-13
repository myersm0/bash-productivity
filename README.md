
## Introduction
Functions to speed up and ease file system navigation in bash. A history of the directories you visit will be saved to a local file at `$HOME/.cd_history` to facilitate retrieval.

Some of this code, especially the `menu` function which is used internally, was adapted from the book Pro Bash Programming by Chris F.A. Johnson.

## Usage
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
goahead -d 3 -c "\.txt$"

# out of the 100 most recently visited directories,
# show only the ones that have your current working directory as a prefix
cdr 100 -p

# out of the 100 most recently visited directories,
# show only the ones that match a provided regex pattern
cdr 100 -r "my_regex"
```





