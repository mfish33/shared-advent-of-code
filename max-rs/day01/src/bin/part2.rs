
const NUMS: [(&'static str, u32); 18] = [
    ("one", 1),
    ("two", 2),
    ("three", 3),
    ("four", 4),
    ("five", 5),
    ("six", 6),
    ("seven", 7),
    ("eight", 8),
    ("nine", 9),
    ("1", 1),
    ("2", 2),
    ("3", 3),
    ("4", 4),
    ("5", 5),
    ("6", 6),
    ("7", 7),
    ("8", 8),
    ("9", 9),
];

fn main() {
    let input = include_str!("../../input.txt");

    let lines = input.split('\n');

    let nums = lines.map(|line| {
        let positions: Vec<_> = NUMS
            .iter()
            .flat_map(|(name, value)| line.match_indices(name).map(move |(idx, _)| (idx, value)))
            .collect();
        let first_num = positions
            .iter()
            .min_by(|(idx_a, _), (idx_b, _)| idx_a.cmp(idx_b))
            .unwrap()
            .1;
        let second_num = positions
            .iter()
            .max_by(|(idx_a, _), (idx_b, _)| idx_a.cmp(idx_b))
            .unwrap()
            .1;
        first_num * 10 + second_num
    });

    let sum: u32 = nums.sum();

    println!("Total sum {}", sum)
}
