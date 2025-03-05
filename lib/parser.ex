defmodule Opml do
  @moduledoc """
  Parser module for OPML (Outline Processor Markup Language) files.

  This module provides functionality to parse OPML files from either URLs or direct XML content,
  and converts the OPML structure into a more usable JSON-like map structure.
  """

  @doc """
  Parses an OPML file from either a URL or direct XML content.
  Returns a structured map representation of the OPML data.

  ## Parameters
    * `data` - A URL string pointing to an OPML file or a string containing OPML XML content

  ## Returns
    * `{:ok, map}` - Successfully parsed OPML data as a map
    * `{:error, reason}` - Error occurred during parsing
  """
  def parse(data) do
    case is_url(data) do
      true ->
        with {:ok, body} <- fetch_content(data),
             {:ok, opml} <- parse_content(body) do
          {:ok, opml}
        end

      false ->
        parse_content(data)
    end
  end

  defp is_url(url) do
    case URI.new(url) do
      {:ok, uri} ->
        uri.scheme != nil && uri.host != nil

      {:error, _} ->
        false
    end
  end

  defp parse_content(content) do
    # Use regular expression to replace encoding in XML declaration with UTF-8
    content =
      Regex.replace(~r/(<\?xml[^>]*encoding=["'])([^"']+)(["'][^>]*\?>)/i, content, fn _,
                                                                                       start,
                                                                                       _,
                                                                                       ending ->
        "#{start}UTF-8#{ending}"
      end)

    with {:ok, parsed} <- SimpleXml.parse(content),
         {:ok, trimed_opml} <- remove_whitespace(parsed),
         {:ok, json_opml} <- to_json_structure(trimed_opml) do
      {:ok, json_opml}
    end
  end

  # Recursively remove whitespace nodes from the parsed result
  defp remove_whitespace(parsed) when is_binary(parsed) do
    # Only remove if the string is entirely whitespace
    if String.match?(parsed, ~r/\A[\s\r\n\t]*\z/) do
      {:ok, nil}
    else
      {:ok, parsed}
    end
  end

  defp remove_whitespace({tag, attrs, children}) do
    # Recursively process child nodes and filter out nil values
    filtered_children =
      children
      |> Enum.map(&remove_whitespace/1)
      |> Enum.filter(fn
        {:ok, nil} -> false
        {:ok, _} -> true
        _ -> false
      end)
      |> Enum.map(fn {:ok, value} -> value end)

    {:ok, {tag, attrs, filtered_children}}
  end

  # Process other types of data (e.g. lists)
  defp remove_whitespace(list) when is_list(list) do
    processed =
      list
      |> Enum.map(&remove_whitespace/1)
      |> Enum.filter(fn
        {:ok, nil} -> false
        {:ok, _} -> true
        _ -> false
      end)
      |> Enum.map(fn {:ok, value} -> value end)

    {:ok, processed}
  end

  # Process other types of data
  defp remove_whitespace(other), do: {:ok, other}

  # Convert OPML structure to JSON structure
  defp to_json_structure({"opml", attrs, children}) do
    # Extract version information
    version =
      attrs
      |> Enum.find(fn {key, _} -> key == "version" end)
      |> case do
        # Default version
        nil -> "1.0"
        pair -> elem(pair, 1)
      end

    # Initialize result structure
    result = %{
      "version" => version,
      "head" => %{},
      "body" => %{}
    }

    # Process child nodes
    result =
      Enum.reduce(children, result, fn
        {"head", _, head_children}, acc ->
          head_map = process_head_children(head_children)
          Map.put(acc, "head", head_map)

        {"body", _, body_children}, acc ->
          outlines = process_body_children(body_children)
          Map.put(acc, "body", %{"outlines" => outlines})

        _, acc ->
          acc
      end)

    {:ok, result}
  end

  # Process child nodes of the head element
  defp process_head_children(children) do
    Enum.reduce(children, %{}, fn
      {tag, _, [value]}, acc when is_binary(value) ->
        Map.put(acc, tag, value)

      {tag, _, []}, acc ->
        Map.put(acc, tag, "")

      _, acc ->
        acc
    end)
  end

  # Process child nodes of the body element (outline elements)
  defp process_body_children(children) do
    Enum.map(children, fn
      {"outline", attrs, outline_children} ->
        # Convert attributes to map
        attrs_map =
          Enum.reduce(attrs, %{}, fn {key, value}, acc ->
            Map.put(acc, key, value)
          end)

        # If there are child outlines, recursively process them
        if Enum.empty?(outline_children) do
          attrs_map
        else
          Map.put(attrs_map, "children", process_body_children(outline_children))
        end

      _ ->
        nil
    end)
    |> Enum.filter(&(&1 != nil))
  end

  defp fetch_content(url) do
    req =
      Req.new(max_redirects: 5)

    case Req.get(req, url: url) do
      {:ok, %Req.Response{status: 200, body: body}} -> {:ok, body}
      {:ok, reason} -> {:error, reason}
      {:error, reason} -> {:error, reason}
    end
  end
end
