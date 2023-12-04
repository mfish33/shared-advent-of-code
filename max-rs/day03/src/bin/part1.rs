use std::collections::HashSet;

fn main() {
    let input = include_str!("../../input.txt");
    let lines = input.split("\n");

    let mut positions = HashSet::new();
    let mut numbers = Vec::new();

    for (i, line) in lines.enumerate() {
        let mut acc_num = None;

        for (j, ch) in line.chars().enumerate() {
            if ch.is_digit(10) {
                let curr_num = ch.to_digit(10).unwrap() as i32;
                if let Some((start_j, val)) = acc_num {
                    acc_num = Some((start_j, val * 10 + curr_num))
                } else {
                    acc_num = Some((j as i32, curr_num))
                }
                continue;
            }

            if let Some((start_j, val)) = acc_num.take() {
                numbers.push(Number {
                    val,
                    pos: Position {
                        i: i as i32,
                        j: start_j,
                    },
                });
            }

            if ch == '.' {
                continue;
            }

            positions.insert(Position {
                i: i as i32,
                j: j as i32,
            });
        }

        if let Some((start_j, val)) = acc_num.take() {
            numbers.push(Number {
                val,
                pos: Position {
                    i: i as i32,
                    j: start_j,
                },
            });
        }
    }

    println!("{:#?}", numbers);
    println!("{:#?}", positions);

    let num_sum: i32 = numbers
        .iter()
        .filter(|num| num.around().any(|pos| positions.contains(&pos)))
        .map(|num| num.val)
        .sum();

    println!("Got {}", num_sum)
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
struct Position {
    i: i32,
    j: i32,
}

#[derive(Debug, Clone)]
struct Number {
    pos: Position,
    val: i32,
}

impl Number {
    fn around(&self) -> impl Iterator<Item = Position> {
        let num_length = num_length(self.val);
        // Put in endcaps
        let mut possible_positions = vec![
            Position {
                i: self.pos.i,
                j: self.pos.j - 1,
            },
            Position {
                i: self.pos.i,
                j: self.pos.j + num_length,
            },
        ];

        for j_offset in -1..=(num_length as i32) {
            possible_positions.push(Position {
                i: self.pos.i - 1,
                j: self.pos.j + j_offset,
            });
            possible_positions.push(Position {
                i: self.pos.i + 1,
                j: self.pos.j + j_offset,
            });
        }


        possible_positions.into_iter()
    }
}

fn num_length(num: i32) -> i32 {
    (num as f64).log10() as i32 + 1
}
