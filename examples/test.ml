open Camlbuild
let toolchain () =
    Camlbuild._BUILD_ALL
    "python"
    (Camlbuild._INPUT_FROM_DIR (Camlbuild._PATH ["pytests"]) "py");

    Camlbuild._BUILD_ALL_OUTPUT "cc" ~flags:"-Wall -Werror"
      (Camlbuild._CONSTRUCT_CHAIN
         (Camlbuild._PATH ["ctests"])
         (Camlbuild._PATH ["cbuild"])
         "c"
      );

    Camlbuild._MKDIR (Camlbuild._PATH ["cbuild"; "otherbuild"]);

    Camlbuild._BUILD_ALL_OUTPUT "cc" ~flags: "-Wall -Werror"
      (Camlbuild._CONSTRUCT_CHAIN
         (Camlbuild._PATH ["ctests"; "othertests"])
         (Camlbuild._PATH ["cbuild"; "otherbuild"])
         "c"
      );

    Camlbuild._BUILD_FILE "python" (Camlbuild._PATH ["pytests"; "additional"; "add.py"])

let () =
  Camlbuild._RUN toolchain
