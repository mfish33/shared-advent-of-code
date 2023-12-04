use std::collections::{HashMap, HashSet};

fn main() {
    let input = include_str!("../../input.txt");
    let lines = input.split("\n");

    let mut possible_gears = Vec::new();
    let mut num_positions = HashMap::new();

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
                for curr_j in start_j..j as i32 {
                    num_positions.insert(
                        Position {
                            i: i as i32,
                            j: curr_j,
                        },
                        val,
                    );
                }
            }

            if ch == '*' {
                possible_gears.push(Position {
                    i: i as i32,
                    j: j as i32,
                })
            }
        }

        if let Some((start_j, val)) = acc_num.take() {
            for curr_j in start_j..line.len() as i32 {
                num_positions.insert(
                    Position {
                        i: i as i32,
                        j: curr_j,
                    },
                    val,
                );
            }
        }
    }

    for (pos, val) in num_positions.iter() {
        if *val == 99 || *val == 131 {
            println!("Val: {}, pos: {:?}", val, pos)
        }
    }

    let num_sum: i32 = possible_gears
        .iter()
        .map(|num| {
            num.around()
                .filter_map(|pos| num_positions.get(&pos))
                .collect::<HashSet<_>>()
                .into_iter()
                .collect::<Vec<_>>()
        })
        .filter(|nums| {
            if nums.len() != 2 {
                println!("Rejecting got: {:?}", nums)
            }
            nums.len() == 2
        })
        .map(|nums| nums[0] * nums[1])
        .sum();

    println!("Got {}", num_sum)
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
struct Position {
    i: i32,
    j: i32,
}

impl Position {
    fn around(&self) -> impl Iterator<Item = Position> {
        // Put in endcaps
        let mut possible_positions = vec![
            Position {
                i: self.i,
                j: self.j - 1,
            },
            Position {
                i: self.i,
                j: self.j + 1,
            },
        ];

        for j_offset in -1..=1 {
            possible_positions.push(Position {
                i: self.i - 1,
                j: self.j + j_offset,
            });
            possible_positions.push(Position {
                i: self.i + 1,
                j: self.j + j_offset,
            });
        }

        possible_positions.into_iter()
    }
}
