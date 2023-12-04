open Core

let rec range a b = if a >= b then [] else a :: range (a + 1) b

let read_lines file =
  let contents = In_channel.read_all file in
  String.split contents ~on:'\n'

let lines = read_lines "input.txt"

let tagRemoved =
  List.map lines ~f:(fun line -> List.nth_exn (String.split line ~on:':') 1)

let gameSides = List.map tagRemoved ~f:(fun line -> String.split line ~on:'|')

type game = { idx : int; winning_nums : int list; nums : int list }
[@@deriving sexp]

let game_from_list idx ls =
  match ls with
  | [ winning_nums; nums ] -> { winning_nums; nums; idx }
  | _ -> invalid_arg "Incorrect format for list"

let games =
  List.mapi gameSides ~f:(fun idx game ->
      List.map game ~f:(fun group ->
          String.split group ~on:' '
          |> List.filter ~f:(fun s -> not (String.is_empty s))
          |> List.map ~f:int_of_string)
      |> game_from_list idx)

(* let () = print_s (sexp_of_list sexp_of_game games) *)

let game_score { winning_nums; nums; idx = _ } =
  let rec num_matching nums_remaining =
    match nums_remaining with
    | [] -> 0
    | h :: rst ->
        if List.exists winning_nums ~f:(( = ) h) then 1 + num_matching rst
        else num_matching rst
  in
  num_matching nums

let process_round round =
  List.map round ~f:(fun game ->
      range (game.idx + 1) (game_score game + 1 + game.idx))
  |> List.concat
  |> List.map ~f:(List.nth_exn games)

let total_rounds =
  let rec process_rounds round =
    match round with
    | [] -> 0
    | round ->
        let round_result = process_round round in
        List.length round_result + process_rounds round_result
  in
  process_rounds games + List.length games

let () = printf "Total rounds is %d\n" total_rounds
