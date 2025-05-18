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

## Hugo theme

This Hugo site is built using the [Hextra](https://github.com/imfing/hextra) documentation theme as a module.

To [Update the module](https://gohugo.io/hugo-modules/use-modules/#update-modules)
 
 ```shell
 hugo mod get -u
 hugo mod tidy
 ```
 
