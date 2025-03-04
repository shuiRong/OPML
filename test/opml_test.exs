defmodule OpmlTest do
  use ExUnit.Case
  doctest Opml.Parser

  test "parse opml from url" do
    assert {:ok, result} =
             Opml.Parser.parse("http://hosting.opml.org/dave/spec/subscriptionList.opml")

    # 验证版本
    assert result["version"] == "2.0"

    # 验证头部信息
    assert result["head"]["title"] == "mySubscriptions.opml"
    assert result["head"]["ownerName"] == "Dave Winer"
    assert result["head"]["ownerEmail"] == "dave@scripting.com"

    # 验证主体内容
    outlines = result["body"]["outlines"]
    assert is_list(outlines)
    assert length(outlines) == 13

    # 验证第一个订阅项
    first_item = Enum.at(outlines, 0)
    assert first_item["text"] == "CNET News.com"
    assert first_item["xmlUrl"] == "http://news.com.com/2547-1_3-0-5.xml"
    assert first_item["type"] == "rss"
  end
end
