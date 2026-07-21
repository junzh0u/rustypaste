#!/usr/bin/env bash

content="unicode filename test"

setup() {
  echo "$content" > file
}

run_test() {
  # Test percent-encoded Chinese filename (测试文件.txt)
  file_url=$(curl -s -F "file=@file" -H "filename:%E6%B5%8B%E8%AF%95%E6%96%87%E4%BB%B6.txt" localhost:8000)
  test "$file_url" = "http://localhost:8000/测试文件.txt"
  test "$content" = "$(cat 'upload/测试文件.txt')"
  test "$content" = "$(curl -s 'http://localhost:8000/%E6%B5%8B%E8%AF%95%E6%96%87%E4%BB%B6.txt')"

  # Test percent-encoded emoji filename (📎attachment.txt)
  file_url=$(curl -s -F "file=@file" -H "filename:%F0%9F%93%8Eattachment.txt" localhost:8000)
  test "$file_url" = "http://localhost:8000/📎attachment.txt"
  test "$content" = "$(cat 'upload/📎attachment.txt')"
  test "$content" = "$(curl -s 'http://localhost:8000/%F0%9F%93%8Eattachment.txt')"

  # Test plain ASCII filename still works
  file_url=$(curl -s -F "file=@file" -H "filename:plain.txt" localhost:8000)
  test "$file_url" = "http://localhost:8000/plain.txt"
  test "$content" = "$(cat upload/plain.txt)"
  test "$content" = "$(curl -s http://localhost:8000/plain.txt)"
}

teardown() {
  rm file
  rm -r upload
}
