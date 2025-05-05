defmodule Opml.Builder do
  @moduledoc """
  Module for building OPML files.

  This module provides functionality to convert Elixir data structures into XML strings conforming to the OPML 2.0 specification.
  """

  @doc """
  Converts a data structure into an OPML XML string.

  ## Parameters
    * `outlines` - list of outline elements
    * `options` - optional configuration
      * `:version` - OPML version, defaults to "2.0"
      * `:title` - document title
      * `:date_created` - creation date
      * `:date_modified` - modification date
      * `:owner_name` - owner name
      * `:owner_email` - owner email
      * other head element attributes

  ## Returns
    * XML string conforming to OPML 2.0 specification
  """
  def build(outlines, options \\ []) do
    # Default version is 2.0
    version = Keyword.get(options, :version, "2.0")

    # Process head element
    head_data = build_head_from_options(options)

    # Build XML structure
    opml_elem =
      {"opml", [{"version", version}],
       [
         head_data,
         {"body", [], build_outlines(outlines)}
       ]}

    # Generate XML string
    xml_declaration = ~s(<?xml version="1.0" encoding="UTF-8"?>)
    xml_content = SimpleXml.XmlNode.to_string(opml_elem)

    # Convert tags without child elements to self-closing format
    xml_content = convert_to_self_closing_tags(xml_content)

    xml_declaration <> "\n" <> xml_content
  end

  # Convert tags without content to self-closing format
  defp convert_to_self_closing_tags(xml) do
    Regex.replace(
      ~r/<(\w+:?\w*)((?:\s+\w+(?::\w+)?="[^"]*")*)\s*><\/\1>/,
      xml,
      "<\\1\\2/>"
    )
  end

  # Generate head element from options
  defp build_head_from_options(options) do
    # Define head attributes and their key mappings
    head_keys = [
      {:title, "title"},
      {:date_created, "dateCreated"},
      {:date_modified, "dateModified"},
      {:owner_name, "ownerName"},
      {:owner_email, "ownerEmail"},
      {:expansion_state, "expansionState"},
      {:vert_scroll_state, "vertScrollState"},
      {:window_top, "windowTop"},
      {:window_left, "windowLeft"},
      {:window_bottom, "windowBottom"},
      {:window_right, "windowRight"}
    ]

    # Extract head elements from options
    head_children =
      Enum.reduce(head_keys, [], fn {option_key, xml_key}, acc ->
        case Keyword.get(options, option_key) do
          nil -> acc
          value -> [{xml_key, [], [to_string(value)]} | acc]
        end
      end)

    # Handle auto-generated dates
    head_children =
      if Keyword.has_key?(options, :date_created) or not Keyword.get(options, :auto_dates, true) do
        head_children
      else
        now = format_date(DateTime.utc_now())
        [{"dateCreated", [], [now]} | head_children]
      end

    {"head", [], head_children}
  end

  # Recursively build outline elements
  defp build_outlines(outlines) when is_list(outlines) do
    Enum.map(outlines, fn outline ->
      # Extract children, if any
      {children, attrs} = extract_children(outline)

      # Convert all key-value pairs to attributes
      attrs_list =
        Enum.map(attrs, fn
          {key, value} when is_atom(key) -> {Atom.to_string(key), to_string(value)}
          {key, value} -> {key, to_string(value)}
        end)

      {"outline", attrs_list, build_outlines(children)}
    end)
  end

  defp build_outlines(_), do: []

  # Extract children from outline data
  defp extract_children(outline) when is_map(outline) do
    children = Map.get(outline, :children, Map.get(outline, "children", []))

    # Remove "children" key, the rest are attributes
    attrs =
      outline
      |> Map.drop([:children, "children"])

    {children, attrs}
  end

  # Handle outline in keyword list form
  defp extract_children(outline) when is_list(outline) do
    children = Keyword.get(outline, :children, [])
    attrs = Keyword.delete(outline, :children)
    {children, attrs}
  end

  # Format date to RFC 822 format
  defp format_date(%DateTime{} = date) do
    Calendar.strftime(date, "%a, %d %b %Y %H:%M:%S GMT")
  end

  defp format_date(date) when is_binary(date), do: date
end
