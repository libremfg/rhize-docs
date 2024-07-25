# Rhize documentation

Website and content files for documentation at [docs.rhize.com](https://docs.rhize.com).

## Build locally

**Prerequisites**:
- [Hugo Installed](https://gohugo.io/installation/)


To serve locally, follow these steps:

1. Navigate to the root of this repository.
2. Run `hugo server`. Or, to build draft pages, run `hugo server -D`
3. Inspect the terminal to find what URL Hugo is serving to. The default is `localhost:1313`
4. Most changes should update live.

To stop Hugo, use `ctrl+c`.

## Authoring:

Refer to [Contributing](CONTRIBUTING.md).


## Troubleshooting

### Page is not showing

Check whether the page frontmatter has `draft: true`.
To view a draft locally, use the `hugo server -D` command.
To make it so the page appears on the published site, change the value to `false`.

### Page is in the wrong place in the sidebar

Each nested page has a `parent`. Make sure the value of the page's `menu.main.parent` property has the `identifier` of its parent directory `_index.md` file.
