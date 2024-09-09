
## Introduction
functions to speed up and ease file system navigation in bash

Your cd history will be saved to a local file at `$HOME/.cd_history` to facilitate retrieval

## Usage
 three basic user facing functions are provided.

```
lookahead
cdr
cdf
```

 they all will present you a menu of cd options but you can select and automatically seedy into. ` look ahead` does so relative to whip your current location. `cdr` and `cdf`  do so relative to your history,  sorted by most recent  or by most frequent respectively.

 they provide several regex options as well which I will explain later

