defmodule Opml.Parser do
  @moduledoc """
  Documentation for `Opml`.
  """

  @doc """
  解析 OPML 文件，支持从 URL 或直接内容解析。

  ## 示例

      iex> Opml.Parser.parse("http://example.com/feed.opml")
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

  def parse_content(content) do
    # 使用正则表达式替换XML声明中的编码为UTF-8
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

  # 递归移除解析结果中的空白字符节点
  defp remove_whitespace(parsed) when is_binary(parsed) do
    # 只有当字符串全部由空白字符组成时才移除
    if String.match?(parsed, ~r/\A[\s\r\n\t]*\z/) do
      {:ok, nil}
    else
      {:ok, parsed}
    end
  end

  defp remove_whitespace({tag, attrs, children}) do
    # 递归处理子节点并过滤掉 nil 值
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

  # 处理其他类型的数据（如列表）
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

  # 处理其他类型的数据
  defp remove_whitespace(other), do: {:ok, other}

  # 将 OPML 结构转换为 JSON 结构
  defp to_json_structure({"opml", attrs, children}) do
    # 提取版本信息
    version =
      attrs
      |> Enum.find(fn {key, _} -> key == "version" end)
      |> case do
        # 默认版本
        nil -> "1.0"
        pair -> elem(pair, 1)
      end

    # 初始化结果结构
    result = %{
      "version" => version,
      "head" => %{},
      "body" => %{}
    }

    # 处理子节点
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

  # 处理 head 节点下的子节点
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

  # 处理 body 节点下的子节点（outline 元素）
  defp process_body_children(children) do
    Enum.map(children, fn
      {"outline", attrs, outline_children} ->
        # 将属性转换为 map
        attrs_map =
          Enum.reduce(attrs, %{}, fn {key, value}, acc ->
            Map.put(acc, key, value)
          end)

        # 如果有子 outline，递归处理
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

  def fetch_content(url) do
    req =
      Req.new(max_redirects: 5)

    case Req.get(req, url: url) do
      {:ok, %Req.Response{status: 200, body: body}} -> {:ok, body}
      {:ok, reason} -> {:error, reason}
      {:error, reason} -> {:error, reason}
    end
  end
end
