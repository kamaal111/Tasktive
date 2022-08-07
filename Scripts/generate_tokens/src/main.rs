use std::path::Path;
use clap::Parser;
use serde::{Serialize, Deserialize};

#[derive(Parser, Debug, Serialize, Deserialize)]
#[clap(author, version, about, long_about = None)]
struct Args {
   #[clap(short, long, value_parser)]
   github_token: Option<String>,
}

fn main() {
    let tokens_file_path =  Path::new("Tasktive/Resources/Tokens.json");

    let args = Args::parse();
    let serialized_args = serde_json::to_string_pretty(&args).unwrap();

    std::fs::write(tokens_file_path, serialized_args).unwrap();

    println!("successfully created tokens file ✨");
}
