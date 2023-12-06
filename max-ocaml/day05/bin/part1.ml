open Core

(* Helpers *)
let neg_pred p x = not (p x)
let input = In_channel.read_all "input.txt"

(* Hack to get behavior I want *)
let sections =
  String.substr_replace_all ~pattern:"\n\n" ~with_:"\r" input
  |> String.split ~on:'\r'

let seeds_str = List.hd_exn sections

let seeds =
  (String.split ~on:':' seeds_str |> List.nth_exn) 1
  |> String.split ~on:' '
  |> List.filter ~f:(neg_pred String.is_empty)
  |> List.map ~f:int_of_string

type mapping = { dest_start : int; source_start : int; range : int }
[@@deriving sexp]

type map = { source : string; destination : string; mappings : mapping list }
[@@deriving sexp]

let parse_header s =
  let header_parts =
    String.substr_replace_all ~pattern:"-to-" ~with_:"," s
    |> String.substr_replace_all ~pattern:" map:" ~with_:""
    |> String.split ~on:','
  in
  (List.nth_exn header_parts 0, List.nth_exn header_parts 1)

let parse_mapping s =
  let mapping_lst = String.split ~on:' ' s |> List.map ~f:int_of_string in
  let dest_start = List.nth_exn mapping_lst 0 in
  let source_start = List.nth_exn mapping_lst 1 in
  let range = List.nth_exn mapping_lst 2 in
  { dest_start; source_start; range }

let parse_map s =
  let lines = String.split ~on:'\n' s in
  let source, destination = parse_header (List.hd_exn lines) in
  let mappings = List.tl_exn lines |> List.map ~f:parse_mapping in
  { source; destination; mappings }

let maps_str = List.tl_exn sections
let maps = List.map ~f:parse_map maps_str

let in_mapping value { dest_start = _; source_start; range } =
  value >= source_start && value < source_start + range

let find_mapping value mappings =
  match List.find mappings ~f:(in_mapping value) with
  | Some { dest_start; source_start; range = _ } ->
      dest_start + (value - source_start)
  | None -> value

let do_mapping_step in_val in_source =
  let { source = _; destination; mappings } =
    List.find_exn maps ~f:(fun { source; destination = _; mappings = _ } ->
        String.equal source in_source)
  in
  let dest_val = find_mapping in_val mappings in
  (dest_val, destination)

let get_location seed =
  let rec internal in_val in_source =
    if String.equal in_source "location" then in_val
    else
      let out_val, dest = do_mapping_step in_val in_source in
      internal out_val dest
  in
  internal seed "seed"

let seed_locations = List.map seeds ~f:get_location
let min_location = List.reduce_exn seed_locations ~f:min
let () = printf "The min location is %d\n" min_location
