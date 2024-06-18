# GitHub Issue Aggregator

Some scripts to convert all discussions and issues on a GitHub repository into JSON files so you can put them in a vector database.

### Background

[PySR](https://github.com/MilesCranmer/PySR) has a lot of discussions threads. I often will try to point users to relevant ones, but as there are 650+ threads, it's hard to search through them manually. So I made this to help.

### Usage

Make sure you have set up the GitHub CLI with `gh auth login`.

You can download all discussions or issues for a given repository with:

```shell
for i in {1..1000}; do
  for type in "issue" "discussion"; do
    ./download.sh -t $type -n $i -r "PySR" -u "MilesCranmer"
  done
done
```

where `1000` is some number above the maximum number of discussions/issues/PRs for a repository.
Since GitHub enumerates all of these types together, this script will simply skip over any that don't exist.


You can also do this with a nushell version:

```nushell
source download.nu
for i in 1..1000 {
    for type in ["issue" "discussion"] {
        get_issue -t $type -n $i -r "PySR" -u "MilesCranmer"
    }
}
```

### Examples

You can see all the threads as of June 18, 2024 for PySR stored in the `pysr` directory. Basically I will just start a vector database on this folder, and efficiently search through and aggregate the threads with an LLM.
