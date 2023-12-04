open Core

let read_lines file =
  let contents = In_channel.read_all file in
  String.split contents ~on:'\n'

let lines = read_lines "input.txt"

let tagRemoved =
  List.map lines ~f:(fun line -> List.nth_exn (String.split line ~on:':') 1)

let gameSides = List.map tagRemoved ~f:(fun line -> String.split line ~on:'|')

type game = { winning_nums : int list; nums : int list } [@@deriving sexp]

let game_from_list ls =
  match ls with
  | [ winning_nums; nums ] -> { winning_nums; nums }
  | _ -> invalid_arg "Incorrect format for list"

let games =
  List.map gameSides ~f:(fun game ->
      List.map game ~f:(fun group ->
          String.split group ~on:' '
          |> List.filter ~f:(fun s -> not (String.is_empty s))
          |> List.map ~f:int_of_string)
      |> game_from_list)

let game_score { winning_nums; nums } =
  let rec num_matching nums_remaining =
    match nums_remaining with
    | [] -> 0
    | h :: rst ->
        if List.exists winning_nums ~f:(( = ) h) then 1 + num_matching rst
        else num_matching rst
  in
  let x = num_matching nums in
  if x = 0 then 0 else Int.pow 2 (x - 1)

let total_score = List.map games ~f:game_score |> List.fold ~init:0 ~f:( + )
let () = printf "Total score is %d\n" total_score
