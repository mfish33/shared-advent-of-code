fn main() {
    let input = include_str!("../../input.txt");

    let lines = input.split('\n');

    let nums = lines.map(|line| {
        let first_num = line
            .chars()
            .find(|c| c.is_digit(10))
            .unwrap()
            .to_digit(10)
            .unwrap();
        let second_num = line
            .chars()
            .rev()
            .find(|c| c.is_digit(10))
            .unwrap()
            .to_digit(10)
            .unwrap();
        first_num * 10 + second_num
    });

    let sum: u32 = nums.sum();

    println!("Total sum {}", sum)
}
