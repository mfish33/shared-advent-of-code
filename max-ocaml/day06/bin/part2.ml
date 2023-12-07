open Core

let input = In_channel.read_all "input.txt"
let lines = String.split_lines input

let getNum line =
  String.split ~on:':' line
  |> (fun lst -> List.nth_exn lst 1)
  |> String.substr_replace_all ~pattern:" " ~with_:""
  |> float_of_string

let time = List.nth_exn lines 0 |> getNum
let distance = List.nth_exn lines 1 |> getNum
let race = (time, distance)

let weird_round_up x =
  if Float.equal x (Float.round_up x) then (x +. 1.0) else Float.round_up x 

let weird_round_down x =
  if Float.equal x (Float.round_down x) then (x -. 1.0) else Float.round_down x 

let findInterval (race_time, distance) =
  let c_part = sqrt ((race_time **. 2.0) -. (4.0 *. distance)) in
  ( int_of_float (weird_round_up ((race_time -. c_part) /. 2.0)),
    int_of_float (weird_round_down ((race_time +. c_part) /. 2.0)) )

let interval = findInterval race

type interval = int * int [@@deriving sexp]

let result = interval |> (fun (x, y) -> y - x + 1)
let () = printf "The result is %d\n" result
