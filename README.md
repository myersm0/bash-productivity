
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

they all will present you a menu of cd options from which you can select and automatically cd into. ` look ahead` does so relative to your current location. `cdr` and `cdf` do so relative to your history, sorted either by most recent or by most frequent respectively.

they provide several regex options as well which I will explain later

