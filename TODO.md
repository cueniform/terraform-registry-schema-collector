# TODO

- Stop using GHA runner's built-in `terraform`.

- Use for provider polling age-related queue:

```
git ls-tree -rtz --name-only HEAD . | xargs -0 -I{} sh -xc 'touch --date "$(git log -1 --pretty="format:%aD" {})" {}' 2>&1 | fgrep -v '+ git log'
```

- Add tests for top-level `desiderata DESIDERATA=bucket-X` make target
- Add tests for `make schemata/providers/NEW/NEW/metadata`
- Add tests for `make schemata/providers/EXISTING/NEW/metadata`
- Add new target for a new provider:
  - add to desiderata/Makefile.PROVIDERS
  - use `make schemata/providers/???/NEW/metadata`
  - add tests
