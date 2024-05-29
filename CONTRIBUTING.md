# Rhize documentation author's guide

How to contribute to the Rhize docs.

## Create new page

To create a new page, run this command:

```shell
hugo new content/<PATH>/<TO>/<PAGE>.md
```

### Frontmatter

Each page has the following frontmatter:

- `title`: The name of the page as it appears in the H1
- `description`: The text that is displayed in social media previews
- `weight`: The page's relative position in the menu. Heavier weights "sink" to lower on the page.
- `categories`: (Optional) Meta-data about the topic
- `aliases`: URIs from old pages. Configure redirects here.
- `menu.main`: An object that configures the sidebar main menu properties
  - `name`:  (Optional) The title of the page as it appears in the sidebar. Default is `title`
  - `identifier`: How to reference the page in menu configs, and relrefs and other shortcodes
  - `parent`: The parent page (use its `identifier`)
 


Example config:
```yaml
title: GraphQL types and filters
description: A reference of the data types in the Rhize API and of the filters available for each type.
categories: ["reference"]
weight: 930
aliases:
  - "/old/page/" # use trailing slash
menu:
  main:
    name: GQL types and filters
    identifier: gql-filters
    parent: reference
```


## Images

Hugo evaluates links relative to the published site, which can create some confusion when linking images.

To avoid worrying about relative positions, put all images in `/static/images/<SUB_DIRECTORY>`.

Then Reference the image as if `static` did not exist.

```
src="/images/bpmn/screenshot-rhize-bpmn-error-handling-custom-response.png"
```

### Image naming conventions

Images filepaths provide info for humans and crawlers, so adopt standardized conventions:

Each image should have this structure

`<TYPE>-rhize-<DESCRIPTION>.<EXTENSION>`

Type should be one of `screenshot`, `graphic`, or `diagram`.

## Style

The docs follow the [Google Developer's Style Guide](https://developers.google.com/), a widely used standard for developer docs. 

The Vale CI checker also has a spellchecker for our specific special terms. Check `github/workflows/Vocabularies`.

## Shortcodes

_Shortcodes_ are built in functions that you call in the markdown file.
Hugo processes their instructions to render something on the page.

Common use cases are for style, as with notices, and for templating.

### Abbreviation

The abbreviation provides tooltips, using definitions given in `data/termbase.yaml`.

The `abbr`  syntax is as follows:

```html
{{< abbr "<TERM>" >}} 
```

For example:

```
These pages describe the elements to make a Rhize {{< abbr "bpmn" >}} workflow,
```

Renders as:

![image](https://github.com/libremfg/libremfg.github.io/assets/47385188/2394da77-821b-4379-8814-df2476f6e25c)

### bigFigure

Center images and have them open in a new tab.
Optional parameters for `width` and `caption`.

```html
{{< bigFigure
width="65%"
alt="Diagram simplifying flows depicted in part 1 of ISA-95"
src="/images/arch/diagram-rhize-l3-l4-information-flows.png"
caption="A simplified view of how information might exchange between level 3 and 4 systems in a point-to-point topology."
>}}
```


### Compatibility

List the compatible versions of a third party software for a specified version of Rhize.

To use:
1. Update `data/versionCompat.yaml` with the version and tested compatibility.
2. Call the compatibility shortcode using the Rhize version as an argument.

```html
{{< compatible "1" >}}
```

Renders as:

![image](https://github.com/libremfg/libremfg.github.io/assets/47385188/5b5ad2a7-e2e7-4e1f-88f5-0005dbdb355d)


### Expandable

Hide extensive details in an accordion:

```html
{{< expandable title="Click for more details" >}}
This text should be hidden initially.

Put markdown here

{{< /expandable >}}

```

### Notices

Use notices with ```{{% notice $TYPE %}}```:

For example:

```html
{{% notice note %}}

Just keep this in mind.

{{% /notice %}}
```

Rhize docs have three types of notices:

- **Note**. For side information
- **Caution**. To tell people to be careful or understand limitations
- **Warning**. When an action is irreversible.

For example:


![](https://user-images.githubusercontent.com/47385188/282773723-3ac4671a-3cc1-42fe-b27c-340402704fd5.png)

is rendered from:

```html

{{% notice note %}}

Just keep this in mind.

{{% /notice %}}

{{% notice caution %}}

Be careful, this library could change.

{{% /notice %}}

{{% notice warning %}}

This action is irreversible.

{{% /notice %}}
```



### Reusable

Insert a text snippet to use in multiple places.
To create a snippet, add it to an HTML or MD file in `layouts/shortcodes/reusable`.
Call it with `{{% reusable/<FILE_NAME> %}}`.

## Use templates

Each document should have a specific purpose:
At the time of writing, the templated types are `concepts`, `how-to`, `reference`, and `releases`.
To decide which topic you want to write, consult [this Diagram](https://wellshapedwords.com/images/diataxis.svg "diataxis-topic picker")

Each general purpose has template defined in the `archetypes` directory.
For your convenience, use the `archetypes` to avoid writing bolerplate properties:

1. Navigate to the root of this repository.
2. Run `hugo new content/<type>/<name-of-document>.md`


Topics are clustered in groups of the sidebar, corresponding to directories of the same name.
If you want to make a type in a different content directory, use the `--kind` flag:

```sh
hugo new content --kind reference get-started/fake-reference-page.md
```

To learn how to update templates, read the [Hugo Archetypes documentation](https://gohugo.io/content-management/archetypes/). 
