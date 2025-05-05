# OPML

[![Hex.pm](https://img.shields.io/hexpm/v/opml.svg)](https://hex.pm/packages/opml)
[![Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/opml)

An Elixir library for parsing OPML (Outline Processor Markup Language) content from URLs or direct XML content. Outputs programmer-friendly, parsed JSON data structures.

## Installation

The package can be installed, via [Hex](https://hex.pm/packages/opml), by adding `opml` to your list of dependencies in `mix.exs`:```elixir
def deps do
[
{:opml, "~> 0.1.0"}
]
end

````

## Usage

### Parsing with URL

Parsing is as straightforward as invoking the following command:

```elixir
> Opml.parse("http://hosting.opml.org/dave/spec/subscriptionList.opml")
````

And it will be return

```elixir
{:ok, %{
    "body" => %{
      "outlines" => [
        %{
          "description" => "Technology, and the way we do business, is changing the world we know. Wired News is a technology - and business-oriented news service feeding an intelligent, discerning audience. What role does technology play in the day-to-day living of your life? Wired News tells you. How has evolving technology changed the face of the international business world? Wired News puts you in the picture.",
          "htmlUrl" => "http://www.wired.com/",
          "language" => "unknown",
          "text" => "Wired News",
          "title" => "Wired News",
          "type" => "rss",
          "version" => "RSS",
          "xmlUrl" => "http://www.wired.com/news_drop/netcenter/netcenter.rdf"
        }
        ... ignore other lines
      ]
    },
    "head" => %{
      "dateCreated" => "Sat, 18 Jun 2005 12:11:52 GMT",
      "dateModified" => "Tue, 02 Aug 2005 21:42:48 GMT",
      "expansionState" => "",
      "ownerEmail" => "dave@scripting.com",
      "ownerName" => "Dave Winer",
      "title" => "mySubscriptions.opml",
      "vertScrollState" => "1",
      "windowBottom" => "562",
      "windowLeft" => "304",
      "windowRight" => "842",
      "windowTop" => "61"
    },
    "version" => "2.0"
  }
}
```

or return

```elixir
{:error, reason}
```

### Parsing with xml content

```elixir
> Opml.parse(~S{<?xml version="1.0" encoding="ISO-8859-1"?>
                <opml version="2.0">
                  <head>
                    <title>states.opml</title>
                    <dateCreated>Tue, 15 Mar 2005 16:35:45 GMT</dateCreated>
                    </head>
                  <body>
                  </body>
                  </opml>
                })
```

### Building OPML

To generate OPML content from Elixir data structures, use the `build` function:

```elixir
> outlines = [
  %{
    text: "Example Feed",
    description: "An example RSS feed",
    htmlUrl: "https://example.com",
    type: "rss",
    xmlUrl: "https://example.com/feed.xml"
  }
]

> options = [
  title: "My Subscriptions",
  owner_name: "John Doe",
  owner_email: "john@example.com"
]

> Opml.build(outlines, options)
```

This will return an XML string conforming to the OPML 2.0 specification:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head>
    <title>My Subscriptions</title>
    <dateCreated>Wed, 05 Jun 2024 12:00:00 GMT</dateCreated>
    <ownerName>John Doe</ownerName>
    <ownerEmail>john@example.com</ownerEmail>
  </head>
  <body>
    <outline text="Example Feed" description="An example RSS feed" htmlUrl="https://example.com" type="rss" xmlUrl="https://example.com/feed.xml"/>
  </body>
</opml>
```

#### Build Options

The `build` function accepts these options:

- `:version` - OPML version (defaults to "2.0")
- `:title` - document title
- `:date_created` - creation date (RFC 822 format)
- `:date_modified` - modification date (RFC 822 format)
- `:owner_name` - owner name
- `:owner_email` - owner email
- `:expansion_state` - expansion state
- `:vert_scroll_state` - vertical scroll state
- `:window_top` - window top position
- `:window_left` - window left position
- `:window_bottom` - window bottom position
- `:window_right` - window right position
- `:auto_dates` - automatically add creation date if not specified (defaults to true)

### LICENSE

[MIT](LICENSE)
