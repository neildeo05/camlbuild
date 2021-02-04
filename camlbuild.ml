open Sys

module Camlbuild = struct
type ('a, 'b) status =
  | Success of 'a * 'b
  | Fail of 'a * 'b

let rec print_list l=
  match l with
  | [] -> print_string ""
  | x::xs -> let _ = print_endline x in print_list xs

let unwrap_command status =
  match status with
  | Success (x, y) -> Printf.printf "%s\n\n" ("command " ^ y ^ " was successful")
  | Fail (x, y) -> let _ =
                     Printf.printf "%s\n\n"
                       ("ERROR: command " ^ y ^ " failed with exit code " ^ (string_of_int x))
                   in exit 1

let construct_path (starting_directory: string) ?(sep="/") (path:string list) =
  starting_directory ^ sep ^ (String.concat sep path)

let makedir (path: string) =
  let command = ("mkdir -p " ^ path)
  in match Sys.command command with
  | 0 -> Success (0, command)
  | x -> Fail (x, command)

let readdir_file dir ext =
    Sys.readdir dir
     |> Array.to_list
    |> List.filter (fun x -> begin match (String.split_on_char '.' x) with
                             | [] -> false
                             | [x] -> false
                             | x::y::xs -> (y = ext)
                             end)
let append_path orig file =
  orig ^ "/" ^ file

let build_file_with_output comp ?(output_tag="-o") flags output_path input_path=
  let command = comp ^  " " ^ flags ^ " " ^ output_tag ^ " " ^ output_path ^ " " ^ input_path in
  match Sys.command command with
  | 0 -> Success (0, command)
  | x -> Fail (x, command)

let build_file_no_output comp flags input_path =
  let command = comp ^ " " ^ flags ^ " " ^ input_path in
  let _ = print_endline ("[OUTPUT] => " ^ input_path) in
  match Sys.command command with
  | 0 -> let _ = print_endline ("===========================") in Success (0, command)
  | x -> Fail (x, command)

(*******************************)


let _PATH = construct_path "."
let _MKDIR x = makedir x |> unwrap_command


let _INPUT_FROM_DIR dir ext  =
  readdir_file dir ext
  |> List.map(fun x -> append_path dir x)

let rec _OUTPUT_FROM_DIR output_dir input_dir ext =
  Sys.readdir input_dir
  |> Array.to_list
  |> List.filter (fun x -> begin match (String.split_on_char '.' x) with
                           | [] -> false
                           | [x] -> false
                           | x::y::xs -> (y = ext)
                           end)
  |> List.map (fun x -> begin match (String.split_on_char '.' x) with
                        | [] -> ""
                        | [x] -> x
                        | x::y::xs -> append_path output_dir x
                        end)

let rec _BUILD_ALL_OUTPUT compiler ?(flags="") (input_chain, output_chain) =
  match input_chain with
  | [] -> print_string ""
  | x::xs -> begin match output_chain with
             | [] -> print_string ""
             | y::ys -> let _ = unwrap_command  (build_file_with_output compiler flags y x) in
                        _BUILD_ALL_OUTPUT compiler ~flags:flags (xs, ys)
             end
let rec _BUILD_ALL ~cc:compiler ?(flags="") ~input:input_chain =
  match input_chain with
  | [] -> print_string ""
  | x::xs -> let _ = unwrap_command (build_file_no_output compiler flags x) in
             _BUILD_ALL ~cc:compiler ~flags:flags ~input:xs

let _CONSTRUCT_CHAIN input_path output_path ext =
  (_INPUT_FROM_DIR input_path ext, _OUTPUT_FROM_DIR output_path input_path ext)

let _BUILD_FILE_OUTPUT cc ?(flags="") ?(output_tag="-o") input_name output_name =
  (build_file_with_output cc ~output_tag:output_tag flags output_name input_name)
  |> unwrap_command
let _BUILD_FILE cc ?(flags="") input_name =
  build_file_no_output cc flags input_name
  |> unwrap_command
let _PRINT_HELP () =
  print_endline "camlbuild   run       => Runs the toolchain provided";
  print_endline "camlbuild   tests     => Runs the toolchain provided, and checks all of the asserts in the toolchain";
  print_endline "camlbuild   help      => Runs the help commmand"

let _RUN toolchain =
  match Array.get (Sys.argv) 1  with
  | "help" -> let _ = _PRINT_HELP () in exit 0
  | "build" -> toolchain ()
  | _ -> let _ = _PRINT_HELP () in exit 1

end

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


