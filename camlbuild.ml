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
  | Success (x, y) -> print_endline ("command " ^ y ^ " was successful")
  | Fail (x, y) -> print_endline ("ERROR: command " ^ y ^ " failed with exit code " ^ (string_of_int x))

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
  match Sys.command command with
  | 0 -> Success (0, command)
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
let rec _BUILD_ALL compiler ?(flags="") input_chain =
  match input_chain with
  | [] -> print_string ""
  | x::xs -> let _ = unwrap_command (build_file_no_output compiler flags x) in
             _BUILD_ALL compiler ~flags:flags xs

end

let () =
  (* Make the output directories *)
  (*
   * _INPUT_FROM_DIR "tests" "c"
   * |> print_list; *)
  (* build_file_with_output "cc" "./tests/main.c" "./build/main" *)
  (* print_list (_OUTPUT_FROM_DIR (_PATH ["build"]) (_PATH ["tests"]) "c");
   * print_list (_INPUT_FROM_DIR (_PATH ["tests"]) "c"); *)

  (* Make build directory *)
  Camlbuild._MKDIR(Camlbuild._PATH (["cbuild"]));

  (* Build all with compiler *)
  Camlbuild._BUILD_ALL_OUTPUT "cc" ~flags:"-Wall -Werror"
    ((Camlbuild._INPUT_FROM_DIR (Camlbuild._PATH ["ctests"]) "c"),
     (Camlbuild._OUTPUT_FROM_DIR (Camlbuild._PATH ["cbuild"]) (Camlbuild._PATH ["ctests"]) "c"));
  (* let files = "ml" in
   * let path = (Camlbuild._PATH ["ocamltests"]) in
   * Camlbuild._INPUT_FROM_DIR path files
   * |> Camlbuild._BUILD_ALL "ocaml";
   * 
   * (\* let files = "py" in
   *  * let path = (_PATH ["pytests"]) in
   *  *   _INPUT_FROM_DIR path files
   *  * |> _BUILD_ALL "python"; *\)
   * 
   * Camlbuild._PATH (["gobuild"]) |> Camlbuild._MKDIR;
   * let files = "go" in
   * let path = (Camlbuild._PATH ["gotests"]) in
   * ((Camlbuild._INPUT_FROM_DIR path files),
   *  (Camlbuild._OUTPUT_FROM_DIR (Camlbuild._PATH ["gobuild"]) path files))
   * |> Camlbuild._BUILD_ALL_OUTPUT "go" ~flags:"build"; *)
