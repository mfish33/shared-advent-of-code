use anyhow::{anyhow, Result};
use nom::{
    branch::alt,
    bytes::complete::tag,
    combinator::{eof, opt},
    multi::many1,
    number::complete::double,
    sequence::{delimited, pair, terminated},
    IResult,
};

fn main() -> Result<()> {
    let input = include_str!("../../input.txt");

    let games = input
        .split('\n')
        .map(Game::parse)
        .collect::<Result<Vec<_>>>()?;

    let id_sum: u32 = games.iter().filter(|g| g.is_valid()).map(|g| g.id).sum();

    println!("Got id sum of {}", id_sum);
    Ok(())
}

fn parse_u32(i: &str) -> IResult<&str, u32> {
    let (i, fl) = double(i)?;
    Ok((i, fl as u32))
}

fn parse_color(i: &str) -> IResult<&str, &str> {
    alt((tag("green"), tag("red"), tag("blue")))(i)
}

#[derive(Debug, Clone)]
struct Game {
    id: u32,
    rounds: Vec<Round>,
}

impl Game {
    fn parse(i: &str) -> Result<Game> {
        let (i, id) = delimited(tag("Game "), parse_u32, tag(":"))(i)
            .map_err(|e| anyhow!("Failed to get game id: {:?}", e))?;
        let (_, rounds) = terminated(many1(Round::parse), eof)(i)
            .map_err(|e| anyhow!("Failed to parse rounds: {:?}", e))?;
        Ok(Game { id, rounds })
    }

    fn is_valid(&self) -> bool {
        self.rounds.iter().all(Round::is_valid)
    }
}

#[derive(Debug, Clone, Default)]
struct Round {
    red: u32,
    green: u32,
    blue: u32,
}

impl Round {
    fn parse(i: &str) -> IResult<&str, Self> {
        let (i, colors) = terminated(
            many1(pair(
                delimited(tag(" "), parse_u32, tag(" ")),
                terminated(parse_color, opt(tag(","))),
            )),
            alt((tag(";"), eof)),
        )(i)?;

        let mut round = Round::default();
        for (val, color) in colors {
            round.set(color, val);
        }

        Ok((i, round))
    }

    fn set(&mut self, attr: &str, val: u32) {
        match attr {
            "red" => self.red = val,
            "green" => self.green = val,
            "blue" => self.blue = val,
            _ => panic!("Tried to set invalid attr: {}", attr),
        }
    }

    fn is_valid(&self) -> bool {
        self.red <= 12 && self.green <= 13 && self.blue <= 14
    }
}
