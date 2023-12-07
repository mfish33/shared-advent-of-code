open Core

(* Helpers *)
let neg_pred p x = not (p x)
let input = In_channel.read_all "input.txt"
let lines = String.split_lines input

let getNums line =
  String.split ~on:':' line
  |> (fun lst -> List.nth_exn lst 1)
  |> String.split ~on:' '
  |> List.filter ~f:(neg_pred String.is_empty)
  |> List.map ~f:float_of_string

let times = List.nth_exn lines 0 |> getNums
let distances = List.nth_exn lines 1 |> getNums
let () = print_s (sexp_of_list sexp_of_float times)
let () = print_s (sexp_of_list sexp_of_float distances)
let races = List.zip_exn times distances

let weird_round_up x =
  if Float.equal x (Float.round_up x) then (x +. 1.0) else Float.round_up x 

let weird_round_down x =
  if Float.equal x (Float.round_down x) then (x -. 1.0) else Float.round_down x 

let findInterval (race_time, distance) =
  let c_part = sqrt ((race_time **. 2.0) -. (4.0 *. distance)) in
  ( int_of_float (weird_round_up ((race_time -. c_part) /. 2.0)),
    int_of_float (weird_round_down ((race_time +. c_part) /. 2.0)) )

let intervals = List.map races ~f:findInterval

type interval = int * int [@@deriving sexp]

let () = print_s (sexp_of_list sexp_of_interval intervals)
let amountToWin = List.map intervals ~f:(fun (x, y) -> y - x + 1)
let result = List.fold amountToWin ~init:1 ~f:Int.( * )
let () = printf "The result is %d\n" result
