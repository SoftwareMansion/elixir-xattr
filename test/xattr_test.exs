defmodule XattrTest do
  use ExUnit.Case, async: true

  describe "with fresh file" do
    setup [:new_file]

    test "ls/1 returns empty list", %{path: path} do
      assert {:ok, []} == Xattr.ls(path)
    end

    test "has/2 anyway returns false", %{path: path} do
      assert {:ok, false} == Xattr.has(path, "test")
    end

    test "rm/2 returns {:error, :enoattr}", %{path: path} do
      assert {:error, :enoattr} == Xattr.rm(path, "test")
    end

    test "set(path, \"hello\", ...) creates new tag", %{path: path} do
      assert :ok == Xattr.set(path, "hello", "world")
      assert {:ok, "world"} == Xattr.get(path, "hello")
    end
  end

  describe "with foobar tags" do
    setup [:new_file, :with_foobar_tags]

    test "rm(path, \"foo\") removes this xattr and only \"bar\" remains",
      %{path: path}
    do
      assert :ok == Xattr.rm(path, "foo")
      assert {:ok, ["bar"]} == Xattr.ls(path)
    end

    test "set(path, \"hello\", ...) creates new tag", %{path: path} do
      assert :ok == Xattr.set(path, "hello", "world")
      assert {:ok, "world"} == Xattr.get(path, "hello")
    end

    test "has(path, \"foo\") returns true", %{path: path} do
      assert {:ok, true} == Xattr.has(path, "foo")
    end

    test "has(path, \"hello\") returns false", %{path: path} do
      assert {:ok, false} == Xattr.has(path, "hello")
    end

    test "get(path, \"foo\") returns \"foo\"", %{path: path} do
      assert {:ok, "foo"} == Xattr.get(path, "foo")
    end

    test "get(path, \"bar\") returns \"bar\"", %{path: path} do
      assert {:ok, "bar"} == Xattr.get(path, "bar")
    end

    test "set(path, \"foo\", \"hello\") overrides foo", %{path: path} do
      assert :ok == Xattr.set(path, "foo", "hello")
      assert {:ok, "hello"} == Xattr.get(path, "foo")
    end

    test "set(path, \"foo\", \"\") overrides foo", %{path: path} do
      assert :ok == Xattr.set(path, "foo", "")
      assert {:ok, ""} == Xattr.get(path, "foo")
    end
  end

  describe "with empty tag" do
    setup [:new_file, :with_empty_tag]

    test "get(path, \"empty\") returns \"\"", %{path: path} do
      assert {:ok, ""} == Xattr.get(path, "empty")
    end

    test "has(path, \"empty\") returns true", %{path: path} do
      assert {:ok, true} == Xattr.has(path, "empty")
    end

    test "set(path, \"empty\", \"hello\") overrides empty", %{path: path} do
      assert :ok == Xattr.set(path, "empty", "hello")
      assert {:ok, "hello"} == Xattr.get(path, "empty")
    end

    test "rm(path, \"empty\") removes empty", %{path: path} do
      assert :ok == Xattr.rm(path, "empty")
      assert {:error, :enoattr} == Xattr.get(path, "empty")
    end

    test "rm(path, \"hello\") returns {:error, :enoattr}", %{path: path} do
      assert {:error, :enoattr} == Xattr.rm(path, "hello")
    end
  end

  describe "with foobar and empty tags" do
    setup [:new_file, :with_foobar_tags, :with_empty_tag]

    test "ls/1 lists all of 'em", %{path: path} do
      assert {:ok, list} = Xattr.ls(path)
      assert ["bar", "empty", "foo"] == Enum.sort(list)
    end
  end

  describe "with UTF-8 file name and foobar & empty tags" do
    setup [:new_utf8_file, :with_foobar_tags, :with_empty_tag]

    test "ls/1 lists all tags", %{path: path} do
      assert {:ok, list} = Xattr.ls(path)
      assert ["bar", "empty", "foo"] == Enum.sort(list)
    end

    test "set(path, \"empty\", \"hello\") overrides empty", %{path: path} do
      assert :ok == Xattr.set(path, "empty", "hello")
      assert {:ok, "hello"} == Xattr.get(path, "empty")
    end
  end

  describe "with UTF-8 file name and tags" do
    setup [:new_utf8_file, :with_utf8_tags]

    test "ls/1 lists all tags", %{path: path} do
      assert {:ok, list} = Xattr.ls(path)
      assert Enum.sort(["ᚠᛇᚻ", "Τη γλώσσα", "我能吞"]) == Enum.sort(list)
    end

    test "get/2 works", %{path: path} do
      assert {:ok, "我能吞下玻璃而不伤身体。"} == Xattr.get(path, "我能吞")
    end

    test "set/3 works", %{path: path} do
      assert :ok == Xattr.set(path, "我能吞", "ᚠᛇᚻ᛫ᛒᛦᚦ᛫ᚠᚱᚩᚠᚢᚱ᛫ᚠᛁᚱᚪ᛫ᚷᛖᚻᚹᛦᛚᚳᚢᛗ")
      assert {:ok, "ᚠᛇᚻ᛫ᛒᛦᚦ᛫ᚠᚱᚩᚠᚢᚱ᛫ᚠᛁᚱᚪ᛫ᚷᛖᚻᚹᛦᛚᚳᚢᛗ"} == Xattr.get(path, "我能吞")
    end

    test "rm/2 works", %{path: path} do
      assert :ok == Xattr.rm(path, "Τη γλώσσα")
      assert {:error, :enoattr} == Xattr.get(path, "Τη γλώσσα")
    end
  end

  describe "with non-existing file" do
    test "any function should return {:error, :enoent}" do
      path = "#{:erlang.unique_integer([:positive])}.test"
      assert {:error, :enoent} == Xattr.ls(path)
      assert {:error, :enoent} == Xattr.has(path, "test")
      assert {:error, :enoent} == Xattr.get(path, "test")
      assert {:error, :enoent} == Xattr.set(path, "test", "hello")
      assert {:error, :enoent} == Xattr.rm(path, "test")
    end
  end

  defp new_file(_context) do
    path = "#{:erlang.unique_integer([:positive])}.test"
    do_new_file(path)
  end

  defp new_utf8_file(_context) do
    path = "#{:erlang.unique_integer([:positive])}_சுப்ரமணிய.test"
    do_new_file(path)
  end

  defp do_new_file(path) do
    File.open!(path, [:read, :write], fn file ->
      IO.write(file, "hello world!")
    end)

    on_exit fn ->
      File.rm!(path)
    end

    {:ok, [path: path]}
  end

  defp with_foobar_tags(%{path: path}) do
    :ok = Xattr.set(path, "foo", "foo")
    :ok = Xattr.set(path, "bar", "bar")
    {:ok, [path: path]}
  end

  defp with_empty_tag(%{path: path}) do
    :ok = Xattr.set(path, "empty", "")
    {:ok, [path: path]}
  end

  defp with_utf8_tags(%{path: path}) do
    :ok = Xattr.set(path, "ᚠᛇᚻ", "ᚠᛇᚻ᛫ᛒᛦᚦ᛫ᚠᚱᚩᚠᚢᚱ᛫ᚠᛁᚱᚪ᛫ᚷᛖᚻᚹᛦᛚᚳᚢᛗ")
    :ok = Xattr.set(path, "Τη γλώσσα", "Τη γλώσσα μου έδωσαν ελληνική")
    :ok = Xattr.set(path, "我能吞", "我能吞下玻璃而不伤身体。")
    {:ok, [path: path]}
  end
end
