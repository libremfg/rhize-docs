# libremfg.github.io

Documentation pages

## Build locally

**Prerequisites**:
- [Hugo Installed](https://gohugo.io/installation/)


To serve locally, follow these steps:

1. Navigate to the root of this repository.
2. Run `hugo server`. Or, to build draft pages, run `hugo server -D`
3. Inspect the terminal to find what URL Hugo is serving to. The default is `localhost:1313`
4. Most changes should update live.

To stop Hugo, use `ctrl+c`.

## Use a template

Each document should have a specific purpose.
Each general purpose has template defined in the `archetypes` directory.

For your convenience, use the `archetypes` to avoid writing bolerplate properties:

1. Navigate to the root of this repository.
2. Run `hugo new content/<type>/<name-of-document>.md`

At the time of writing, the templated types are `concepts`, `how-to`, `reference`, and `releases`.
To decide which topic you want to write, consult [this Diagram](https://wellshapedwords.com/images/diataxis.svg "diataxis-topic picker")

Topics are clustered in groups of the sidebar, corresponding to directories of the same name.
If you want to make a type in a different content directory, use the `--kind` flag:

```sh
hugo new content --kind reference get-started/fake-reference-page.md
```

To learn how to update templates, read the [Hugo Archetypes documentation](https://gohugo.io/content-management/archetypes/). 

## Troubleshooting

### Page is not showing

One possible reason is that the page has the `draft: true` property in it's frontmatter. If you want to keep it in draft and view it locally, use the `hugo server -D` command.
To make it so the page appears on the published site, change the value to `false`.

### Page is in the wrong place in the sidebar

Each nested page has a `parent`. Make sure the value of the page's `menu.main.parent` property has the `identifier` of its parent directory `_index.md` file.
