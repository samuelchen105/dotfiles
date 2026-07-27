use std::ffi::OsStr;
use std::io::ErrorKind;
use std::process::Stdio;

use eyre::{Result, WrapErr, bail};
use tokio::io::AsyncWriteExt;
use tokio::process::Command;

pub struct CommandBuilder {
    command: Command,
}

impl CommandBuilder {
    pub fn new<S>(command: S) -> Self
    where
        S: AsRef<OsStr>,
    {
        Self {
            command: Command::new(command),
        }
    }

    pub fn arg<S>(mut self, arg: S) -> Self
    where
        S: AsRef<OsStr>,
    {
        self.command.arg(arg);
        self
    }

    pub fn args<I, S>(mut self, args: I) -> Self
    where
        I: IntoIterator<Item = S>,
        S: AsRef<OsStr>,
    {
        self.command.args(args);
        self
    }

    /// Runs a command with inherited standard streams.
    pub async fn run(self) -> Result<()> {
        let mut command = self.command;

        let status = command
            .status()
            .await
            .wrap_err_with(|| format!("failed to run {command:?}"))?;

        if !status.success() {
            bail!("{command:?} exited with {status}");
        }

        Ok(())
    }

    /// Runs a command with inherited stdout/stderr and writes `input` to its stdin.
    pub async fn run_with_input(self, input: impl AsRef<[u8]>) -> Result<()> {
        let mut command = self.command;

        let mut child = command
            .stdin(Stdio::piped())
            .spawn()
            .wrap_err_with(|| format!("failed to run {command:?}"))?;

        let write_result = async {
            let mut stdin = child
                .stdin
                .take()
                .expect("stdin was configured to be piped");
            stdin.write_all(input.as_ref()).await?;
            stdin.shutdown().await
        }
        .await;

        let status = child
            .wait()
            .await
            .wrap_err_with(|| format!("failed to wait for {command:?}"))?;

        if let Err(error) = write_result
            && error.kind() != ErrorKind::BrokenPipe
        {
            return Err(error).wrap_err_with(|| format!("failed to write to {command:?} stdin"));
        }
        if !status.success() {
            bail!("{command:?} exited with {status}");
        }

        Ok(())
    }

    /// Runs a command and returns its stdout as UTF-8.
    pub async fn output(self) -> Result<String> {
        let mut command = self.command;
        let output = command
            .output()
            .await
            .wrap_err_with(|| format!("failed to run {command:?}"))?;

        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr);
            let stderr = stderr.trim();

            if stderr.is_empty() {
                bail!("{command:?} exited with {}", output.status);
            }
            bail!("{command:?} exited with {}: {stderr}", output.status)
        }

        String::from_utf8(output.stdout)
            .wrap_err_with(|| format!("{command:?} returned non-UTF-8 output"))
    }

    pub async fn output_lines(self) -> Result<Vec<String>> {
        Ok(self
            .output()
            .await?
            .lines()
            .map(str::trim)
            .filter(|line| !line.is_empty())
            .map(str::to_owned)
            .collect())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn runs_with_inherited_standard_streams() {
        CommandBuilder::new("true").run().await.unwrap();
    }

    #[tokio::test]
    async fn captures_stdout_as_string() {
        let output = CommandBuilder::new("printf")
            .arg("hello")
            .output()
            .await
            .unwrap();

        assert_eq!(output, "hello");
    }

    #[tokio::test]
    async fn captures_stdout_as_lines() {
        let lines = CommandBuilder::new("printf")
            .arg("alpha\nbeta\n")
            .output_lines()
            .await
            .unwrap();

        assert_eq!(lines, ["alpha", "beta"]);
    }

    #[tokio::test]
    async fn includes_stderr_when_command_fails() {
        let error = CommandBuilder::new("sh")
            .arg("-c")
            .arg("printf 'failure detail' >&2; exit 7")
            .output()
            .await
            .unwrap_err();

        assert!(error.to_string().contains("failure detail"));
    }

    #[tokio::test]
    async fn writes_to_stdin() {
        CommandBuilder::new("sh")
            .arg("-c")
            .arg("read value; test \"$value\" = hello")
            .run_with_input("hello\n")
            .await
            .unwrap();
    }

    #[tokio::test]
    async fn ignores_broken_stdin_pipe_when_command_succeeds() {
        CommandBuilder::new("sh")
            .arg("-c")
            .arg("exec 0<&-; sleep 0.1")
            .run_with_input(vec![0; 1024 * 1024])
            .await
            .unwrap();
    }
}
