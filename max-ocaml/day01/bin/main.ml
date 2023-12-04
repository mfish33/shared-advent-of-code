open Core

let read_lines file = 
  let contents = In_channel.read_all file in
  String.split contents ~on:'\n'

let extract o =
  match o with
  | Some x -> x
  | None -> raise (Failure "Option is empty")

let rec window_fold_left str ~init ~f =
  if String.is_empty str then
    init
  else
    window_fold_left (String.slice str 1 (String.length str)) ~init:(f init str) ~f:f

let chop_last str = 
  if String.length str = 1 then
    ""
  else
    (String.slice str 0 (String.length str - 1))
  
let rec window_fold_right str ~init ~f =
  if String.is_empty str then
    init
  else
    window_fold_right (chop_last str) ~init:(f init str) ~f:f

let starts_with str other = 
  let min_length = (min (String.length str) (String.length other)) in
  String.(=) (String.slice str 0 min_length) other
  
let ends_with str other = 
  let min_length = (max 0 ((String.length str) - (String.length other))) in
  String.(=) (String.slice str min_length (String.length str)) other
  

let input = read_lines "input.txt"

let nums = [
  ("one", '1');
  ("two", '2');
  ("three", '3');
  ("four", '4');
  ("five", '5');
  ("six", '6');
  ("seven", '7');
  ("eight", '8');
  ("nine", '9');
]

let char_digit_opt c = 
  if Char.is_digit c then
    Some c
  else
    None

let str_digit_opt_left str = match List.find nums ~f:(fun p -> match p with (name, _) -> starts_with str name) with
 | Some (_, num) -> Some num
 | None -> char_digit_opt (String.get str 0)

let str_digit_opt_right str = match List.find nums ~f:(fun p -> match p with (name, _) -> ends_with str name) with
 | Some (_, num) -> Some num
 | None -> char_digit_opt (String.get str (String.length str - 1))

let get_left lst = window_fold_left lst ~init:None ~f:(fun acc curr -> Option.first_some acc (str_digit_opt_left curr))
let get_right lst = window_fold_right lst ~init:None ~f:(fun acc curr  -> Option.first_some acc (str_digit_opt_right curr))

let process_str s =
  let left_num = extract (get_left s) in
  let right_num = extract (get_right s) in
  let num_str = String.of_char_list [left_num; right_num] in
  int_of_string num_str

let nums = List.map input ~f:process_str

let total = List.fold nums ~init:0 ~f:(+)

let () = print_endline (string_of_int total)
