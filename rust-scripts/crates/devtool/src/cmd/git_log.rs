use std::collections::HashSet;

use clap::Args;
use comfy_table::{Cell, Color};
use crossterm::style::{Color as TerminalColor, Stylize};
use eyre::{OptionExt, Result, WrapErr, bail};
use tokio::process::Command;

use crate::core::terminal::table_view::table_view;

const FIELD_SEPARATOR: char = '△';

#[derive(Args, Debug)]
pub struct GitLogArgs {
    /// Limit the number of commits passed to git log
    #[arg(short = 'n', value_name = "<number>")]
    number: Option<usize>,
}

impl GitLogArgs {
    pub async fn run(&self) -> Result<()> {
        let logs = get_logs(self.number).await?;
        table_view(
            ["Hash", "Message", "Author", "Tags", "Refs"],
            logs.into_iter().map(|log| {
                [
                    Cell::new(log.hash).fg(Color::Yellow),
                    Cell::new(log.message),
                    Cell::new(log.author),
                    Cell::new(log.tags).fg(Color::Yellow),
                    Cell::new(render_refs(&log.refs)),
                ]
            }),
        )
        .await
    }
}

#[derive(Debug)]
struct LogEntry {
    hash: String,
    message: String,
    author: String,
    tags: String,
    refs: Vec<GitRef>,
}

#[derive(Debug, PartialEq, Eq)]
struct GitRef {
    name: String,
    local: bool,
    remote: bool,
}

async fn get_logs(lines: Option<usize>) -> Result<Vec<LogEntry>> {
    let mut command = Command::new("git");
    command.args(["log", "--pretty=%h△%s△%aN△%D", "--first-parent"]);
    if let Some(lines) = lines {
        command.arg("-n").arg(lines.to_string());
    }

    let output = command.output().await.wrap_err("failed to run git log")?;
    if !output.status.success() {
        bail!(
            "git log failed: {}",
            String::from_utf8_lossy(&output.stderr).trim()
        );
    }

    String::from_utf8(output.stdout)
        .wrap_err("git log returned non-UTF-8 output")?
        .lines()
        .map(parse_log_entry)
        .collect()
}

fn parse_log_entry(line: &str) -> Result<LogEntry> {
    let (hash, remainder) = line
        .split_once(FIELD_SEPARATOR)
        .ok_or_eyre("unexpected git log format")?;
    let (remainder, decorations) = remainder
        .rsplit_once(FIELD_SEPARATOR)
        .ok_or_eyre("unexpected git log format")?;
    let (message, author) = remainder
        .rsplit_once(FIELD_SEPARATOR)
        .ok_or_eyre("unexpected git log format")?;
    let (tags, refs) = parse_decorations(decorations);

    Ok(LogEntry {
        hash: hash.to_owned(),
        message: message.to_owned(),
        author: author.to_owned(),
        tags,
        refs,
    })
}

fn parse_decorations(decorations: &str) -> (String, Vec<GitRef>) {
    let mut tags = Vec::new();
    let mut seen_tags = HashSet::new();
    let mut refs: Vec<GitRef> = Vec::new();

    for decoration in decorations
        .split(',')
        .map(str::trim)
        .filter(|value| !value.is_empty())
    {
        if let Some(tag) = decoration.strip_prefix("tag: ") {
            if seen_tags.insert(tag) {
                tags.push(tag);
            }
            continue;
        }

        let reference = decoration
            .split_once(" -> ")
            .map_or(decoration, |(_, target)| target);
        if reference == "HEAD" {
            continue;
        }

        let (reference, is_remote) = reference
            .strip_prefix("origin/")
            .map_or((reference, false), |reference| (reference, true));
        if reference == "HEAD" {
            continue;
        }

        if let Some(existing) = refs.iter_mut().find(|existing| existing.name == reference) {
            existing.remote |= is_remote;
            existing.local |= !is_remote;
        } else {
            refs.push(GitRef {
                name: reference.to_owned(),
                local: !is_remote,
                remote: is_remote,
            });
        }
    }

    (tags.join(", "), refs)
}

fn render_refs(refs: &[GitRef]) -> String {
    refs.iter()
        .map(|reference| {
            let color = match (reference.local, reference.remote) {
                (true, true) => TerminalColor::Magenta,
                (true, false) => TerminalColor::Green,
                (false, true) => TerminalColor::Red,
                (false, false) => TerminalColor::Reset,
            };
            format!("{}", reference.name.as_str().with(color))
        })
        .collect::<Vec<_>>()
        .join(", ")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_tags_and_combined_refs() {
        let (tags, refs) = parse_decorations("HEAD -> main, tag: v1.2.3, origin/main");

        assert_eq!(tags, "v1.2.3");
        assert_eq!(
            refs,
            [GitRef {
                name: "main".to_owned(),
                local: true,
                remote: true,
            }]
        );
    }

    #[test]
    fn parses_remote_only_refs() {
        let (tags, refs) = parse_decorations("origin/feature");

        assert!(tags.is_empty());
        assert_eq!(
            refs,
            [GitRef {
                name: "feature".to_owned(),
                local: false,
                remote: true,
            }]
        );
    }

    #[test]
    fn ignores_remote_head() {
        let (_, refs) = parse_decorations("origin/main, origin/HEAD, main");

        assert_eq!(
            refs,
            [GitRef {
                name: "main".to_owned(),
                local: true,
                remote: true,
            }]
        );
    }

    #[test]
    fn preserves_separator_in_commit_message() {
        let log = parse_log_entry("abc123△subject △ detail△Author△main").unwrap();

        assert_eq!(log.message, "subject △ detail");
        assert_eq!(log.author, "Author");
    }

    #[test]
    fn rejects_unexpected_log_format() {
        let error = parse_log_entry("invalid").unwrap_err();

        assert_eq!(error.to_string(), "unexpected git log format");
    }
}
