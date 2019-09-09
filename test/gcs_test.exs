defmodule GCSTest do
  use ExUnit.Case

  describe "delete_object/4" do
    test "Makes request to correct url" do
      assert {:ok, url} = GCS.delete_object("a_bucket", "a_path", [], return: :url)
      assert "https://www.googleapis.com/storage/v1/b/a_bucket/o/a_path" == url
    end
  end
end
