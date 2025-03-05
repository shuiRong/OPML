defmodule OpmlTest do
  use ExUnit.Case
  doctest Opml

  test "parse opml from url" do
    assert {:ok, result} =
             Opml.parse("http://hosting.opml.org/dave/spec/subscriptionList.opml")

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

  test "parse xml without encoding attribute" do
    assert {:ok, result} =
             Opml.parse(~S{<?xml version="1.0" encoding="ISO-8859-1"?>
                                  <opml version="2.0">
                                    <head>
                                      <title>states.opml</title>
                                      <dateCreated>Tue, 15 Mar 2005 16:35:45 GMT</dateCreated>
                                      <dateModified>Thu, 14 Jul 2005 23:41:05 GMT</dateModified>
                                      <ownerName>Dave Winer</ownerName>
                                      <ownerEmail>dave@scripting.com</ownerEmail>
                                      <expansionState>1, 6, 13, 16, 18, 20</expansionState>
                                      <vertScrollState>1</vertScrollState>
                                      <windowTop>106</windowTop>
                                      <windowLeft>106</windowLeft>
                                      <windowBottom>558</windowBottom>
                                      <windowRight>479</windowRight>
                                      </head>
                                    <body>
                                    </body>
                                    </opml>
                                  })

    assert result["head"]["title"] == "states.opml"
  end
end
