use std::process::{ExitStatus, Stdio};

use eyre::{OptionExt, Result};
use tokio::io::{AsyncBufReadExt, BufReader, Lines};
use tokio::process::{Child, ChildStdout, Command};

pub struct CommandBuilder {
    c: Command,
}

impl CommandBuilder {
    pub fn new(name: &str) -> Self {
        Self {
            c: Command::new(name),
        }
    }

    pub fn args(&mut self, args: &[&str]) -> &mut Self {
        self.c.args(args);
        self
    }

    pub fn arg(&mut self, arg: &str) -> &mut Self {
        self.c.arg(arg);
        self
    }

    pub fn run_with_stream(&mut self) -> Result<CommandReader> {
        let child = self.c.stdout(Stdio::piped()).spawn()?;
        let reader = CommandReader::new(child)?;
        Ok(reader)
    }
}

pub struct CommandReader {
    child: Child,
    reader: Lines<BufReader<ChildStdout>>,
}

impl CommandReader {
    pub fn new(mut child: Child) -> Result<Self> {
        // Take ownership of the stdout stream
        let stdout = child
            .stdout
            .take()
            .ok_or_eyre("Failed to capture standard output handle")?;

        // Wrap stdout in an asynchronous BufReader
        let reader = BufReader::new(stdout).lines();

        Ok(Self { child, reader })
    }

    pub async fn next_line(&mut self) -> Result<Option<String>> {
        let next_line = self.reader.next_line().await?;
        Ok(next_line)
    }

    pub async fn wait(mut self) -> Result<ExitStatus> {
        let status = self.child.wait().await?;
        Ok(status)
    }
}
