return {
  cmd = { "clangd", "--background-index", "--clang-tidy" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_markers = {"compile_commands.json", "compile_flags.txt", ".git"},
  settings = {},
  on_attach = on_attach
}
