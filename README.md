
## Introduction
functions to speed up and ease file system navigation in bash

Your cd history will be saved to a local file at `$HOME/.cd_history` to facilitate retrieval

## Usage
 three basic user facing functions are provided.

```
goahead
cdr
cdf
```

they all will present you a menu of cd options from which you can select and automatically cd into. ` goahead` does so relative to your current location. `cdr` and `cdf` do so relative to your history, sorted either by most recent or by most frequent respectively.

they provide several regex options as well. a few examples are below:

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





