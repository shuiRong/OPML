defmodule Opml.BuilderTest do
  use ExUnit.Case
  doctest Opml

  test "build opml" do
    outlines = [
      %{
        text: "washingtonpost.com - Politics",
        description: "Politics",
        htmlUrl: "http://www.washingtonpost.com/wp-dyn/politics?nav=rss_politics",
        language: "unknown",
        title: "washingtonpost.com - Politics",
        type: "rss",
        version: "RSS2",
        xmlUrl: "http://www.washingtonpost.com/wp-srv/politics/rssheadlines.xml"
      },
      %{
        text: "CNET News.com",
        description:
          "Tech news and business reports by CNET News.com. Focused on information technology, core topics include computers, hardware, software, networking, and Internet media.",
        htmlUrl: "http://news.com.com/",
        language: "unknown",
        title: "CNET News.com",
        type: "rss",
        version: "RSS2",
        xmlUrl: "http://news.com.com/2547-1_3-0-5.xml"
      }
    ]

    options = [
      title: "mySubscriptions.opml",
      date_created: "Sat, 18 Jun 2005 12:11:52 GMT",
      date_modified: "Tue, 02 Aug 2005 21:42:48 GMT",
      owner_name: "Dave Winer",
      owner_email: "dave@scripting.com",
      expansion_state: "",
      vert_scroll_state: "1",
      window_top: "61",
      window_left: "304",
      window_bottom: "562",
      window_right: "842"
    ]

    result = Opml.build(outlines, options)

    # 验证结果是XML字符串
    assert is_binary(result)
  end
end
