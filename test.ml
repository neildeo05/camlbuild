open Camlbuild
let () =
  (* Make the output directories *)
  (*
   * _COLLECT_FROM_DIR "tests" "c"
   * |> print_list; *)
  (* build_file_with_output "cc" "./tests/main.c" "./build/main" *)
  (* print_list (_OUTPUT_FROM_DIR (_PATH ["build"]) (_PATH ["tests"]) "c");
   * print_list (_COLLECT_FROM_DIR (_PATH ["tests"]) "c"); *)
  Camlbuild._PATH (["cbuild"]) |> Camlbuild._MKDIR;
  let files = "c" in let path = (Camlbuild._PATH ["ctests"]) in
                     ((Camlbuild._COLLECT_FROM_DIR path files),
                      (Camlbuild._OUTPUT_FROM_DIR (Camlbuild._PATH ["cbuild"]) path files))
                     |> Camlbuild._BUILD_ALL_OUTPUT "cc" ~flags:"-Wall -Werror";
  let files = "ml" in
  let path = (Camlbuild._PATH ["ocamltests"]) in
  Camlbuild._COLLECT_FROM_DIR path files
  |> Camlbuild._BUILD_ALL "ocaml";

  (* let files = "py" in
   * let path = (_PATH ["pytests"]) in
   *   _COLLECT_FROM_DIR path files
   * |> _BUILD_ALL "python"; *)
  Camlbuild._PATH (["gobuild"]) |> Camlbuild._MKDIR;
  let files = "go" in let path = (Camlbuild._PATH ["gotests"]) in
                      ((Camlbuild._COLLECT_FROM_DIR path files),
                       (Camlbuild._OUTPUT_FROM_DIR (Camlbuild._PATH ["gobuild"]) path files))
                      |> Camlbuild._BUILD_ALL_OUTPUT "go" ~flags:"build";
