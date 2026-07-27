use clap::{Parser, Subcommand};
use eyre::Result;

mod cmd;
mod core;

/// Shell scripting tool for development
#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand, Debug)]
enum Commands {
    /// Select a Git branch to check out
    GitCheckout(cmd::git_checkout::GitCheckoutArgs),
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::GitCheckout(args) => {
            args.run().await?;
        }
    }
    Ok(())
}
