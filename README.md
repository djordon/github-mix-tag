# Automatic Repo Tagging GitHub Action

This GitHub Action automatically tags your repository with a tag determined by a shell command, and you have control of the shell command. By default, the shell command is `cat VERSION`, so this action looks at the contents of a `VERSION` file in the repository when determining what the tag should be. Some notes:
1. By default, the final tag has a `v` prepended to the results of the shell command. Suppose the shell command is `cat VERSION` and the contents of the `VERSION` file is `1.2.3-rc1`, then the repo will be tagged with `v1.2.3-rc1` when this action is run. This can be disabled by setting `PREPEND_V` environment variable to `false`.
2. If the repo is already tagged with the version then no attempt is made to tag the repo and nothing happens.

Below are some example shell commands that determine the version.


## Getting the version from a file

This action allows the user to customize the command used to get the name of the tag. This is done by setting a `VERSION_COMMAND` environment variable. Some languages allow you (or require you) to set the version in some config file. I've included some example `main.yaml`s with an appropriate `VERSION_COMMAND`.


### Elixir

For `elixir`, the `main.yaml` below can be used to read the version defined in `mix.exs` (assuming the `version` key is on it's own line in the `project` section of `mix.exs`):
```yaml
name: Creates a tag for the repo
  push:
    branches:
      - master 
jobs:
  build:
    name: Tag repo using mix.exs file
    runs-on: ubuntu-20.04    
    steps:
    - name: Checkout master
      uses: actions/checkout@master
    - name: Tagging repo using version specified in mix.exs
      uses: djordon/git-autotag-action@v0.5.0
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        VERSION_COMMAND: >
          cat mix.exs
            | grep --line-buffer "version: "
            | grep --extended-regexp --only-matching "\"[-0-9\.\+a-zA-Z]+\""
            | grep --extended-regexp --only-matching "[-0-9\.\+a-zA-Z]+"
```


### Rust

For `rust`, you can do something like the following:
```yaml
...
    - name: Tagging repo using version specified in Cargo.toml
      uses: djordon/git-autotag-action@v0.5.0
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        VERSION_COMMAND: >
          cat Cargo.toml
            | grep --extended-regexp "^version ="
            | grep --extended-regexp --only-matching "[-0-9\.\+a-zA-Z]+"
            | head --lines=1
```
