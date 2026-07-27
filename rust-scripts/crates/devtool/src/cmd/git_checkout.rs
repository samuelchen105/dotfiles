use std::borrow::Cow;
use std::cmp::Ordering;
use std::collections::HashSet;

use chrono::{DateTime, Local, TimeDelta};
use clap::Args;
use eyre::{Result, bail};
use ratatui::style::{Color, Stylize};
use ratatui::text::{Line, Span};
use ratatui::widgets::ListItem;
use regex::Regex;
use std::sync::LazyLock;

use crate::core::sh::CommandBuilder;
use crate::core::terminal::select::{ListView, select};

#[derive(Args, Debug)]
pub struct GitCheckoutArgs {}

impl GitCheckoutArgs {
    pub async fn run(&self) -> Result<()> {
        let tracked_remotes = get_tracked_remotes().await?;
        let mut branches = get_branches(&tracked_remotes).await?;

        // Sort branches
        branches.sort_by(|a, b| {
            let is_a_remote = a.name.starts_with("origin/");
            let is_b_remote = b.name.starts_with("origin/");
            if !is_a_remote && is_b_remote {
                return Ordering::Less;
            } else if is_a_remote && !is_b_remote {
                return Ordering::Greater;
            } else {
                return a.committed.cmp(&b.committed).reverse();
            }
        });

        let selected = select(&branches)?;

        if let Some(selected) = selected {
            println!("selected: {selected:?}");
            println!("branches: {:?}", &branches[selected]);
        }

        Ok(())
    }
}

async fn get_tracked_remotes() -> Result<HashSet<String>> {
    let mut tracked_remotes = HashSet::new();
    let mut reader = CommandBuilder::new("git")
        .args(&["for-each-ref", "--format=%(upstream:short)", "refs/heads"])
        .run_with_stream()?;

    while let Some(line) = reader.next_line().await? {
        let line = line.trim().to_owned();
        if !line.is_empty() {
            tracked_remotes.insert(line);
        }
    }

    let status = reader.wait().await?;
    if !status.success() {
        bail!("failed to get tracked remotes");
    }

    Ok(tracked_remotes)
}

async fn get_branches(tracked_remotes: &HashSet<String>) -> Result<Vec<Branch>> {
    let mut reader = CommandBuilder::new("git")
        .arg("for-each-ref")
        .arg("--sort=-committerdate")
        .arg("--format=%(HEAD)△%(refname:short)△%(committerdate:unix)△%(upstream:track,nobracket)△%(upstream:remotename)")
        .arg("refs/heads")
        .arg("refs/remotes")
        .run_with_stream()?;

    let now = Local::now();
    let mut branches = Vec::new();
    while let Some(line) = reader.next_line().await? {
        let line = line.trim().to_owned();
        if line.is_empty() {
            continue;
        }

        let mut parts = line.split('△');
        let head = parts.next().expect("invalid git branch line: no head");
        if head == "*" {
            continue;
        }

        let name = parts.next().expect("invalid git branch line: no name");
        if tracked_remotes.contains(name) {
            continue;
        }
        if name == "origin" {
            continue;
        }

        let committed_unix = parts
            .next()
            .expect("invalid git branch line: no committed_unix")
            .parse()
            .expect("committed unix timestamp is not a number");
        let commit_time = DateTime::from_timestamp(committed_unix, 0)
            .expect("Invalid timestamp")
            .with_timezone(&Local);

        let raw_track = parts.next().expect("invalid git branch line: no raw_track");
        let raw_remote = parts
            .next()
            .expect("invalid git branch line: no raw_remote");
        let status = parse_status(raw_track, raw_remote);

        branches.push(Branch {
            name: name.to_owned(),
            committed: commit_time,
            status,
            last_edit: format_duration(now - commit_time),
        });
    }

    let status = reader.wait().await?;
    if !status.success() {
        bail!("failed to get tracked remotes");
    }

    Ok(branches)
}

#[derive(Debug, Clone)]
struct Branch {
    name: String,
    committed: DateTime<Local>,
    status: BranchStatus,
    last_edit: String,
}

impl ListView for Branch {
    fn widths(&self) -> impl Iterator<Item = usize> {
        [
            Span::raw(self.name.as_str()).width(),
            self.status.to_span().width(),
            Span::raw(self.last_edit.as_str()).width(),
        ]
        .into_iter()
    }

    fn view<'a>(&'a self, widths: &[usize]) -> ListItem<'a> {
        let mut spans = Vec::with_capacity(6);

        let name = if self.name.starts_with("origin/") {
            Span::styled(self.name.as_str(), Color::Red)
        } else {
            Span::raw(self.name.as_str())
        };
        push_column(&mut spans, name, widths[0]);

        push_column(&mut spans, self.status.to_span(), widths[1]);

        let last_edit = Span::raw(self.last_edit.as_str()).fg(Color::Cyan);
        push_column(&mut spans, last_edit, widths[2]);

        ListItem::new(Line::from(spans))
    }
}

fn push_column<'a>(spans: &mut Vec<Span<'a>>, span: Span<'a>, width: usize) {
    let padding = width.saturating_sub(span.width()) + 3;
    spans.push(span);
    spans.push(Span::raw(" ".repeat(padding)));
}

#[derive(Debug, Clone)]
struct BranchStatus {
    text: Cow<'static, str>,
    color: Option<Color>,
}

impl BranchStatus {
    fn to_span(&self) -> Span<'_> {
        let span = Span::raw(self.text.as_ref());
        if let Some(color) = self.color {
            span.fg(color)
        } else {
            span
        }
    }
}

fn parse_status(raw_track: &str, raw_remote: &str) -> BranchStatus {
    if raw_remote.is_empty() {
        BranchStatus {
            text: Cow::Borrowed("-"),
            color: None,
        }
    } else if raw_track.is_empty() {
        BranchStatus {
            text: Cow::Borrowed("󰸞"),
            color: Some(Color::Green),
        }
    } else if raw_track == "gone" {
        BranchStatus {
            text: Cow::Borrowed("󱎘"),
            color: Some(Color::Red),
        }
    } else {
        let mut text = String::new();
        if let Some(ahead) = capture_ahead(raw_track) {
            text.push_str(&format!("󱦲{ahead}"));
        }
        if let Some(behind) = capture_behind(raw_track) {
            text.push_str(&format!("󱦳{behind}"));
        }

        BranchStatus {
            text: Cow::Owned(text),
            color: Some(Color::Yellow),
        }
    }
}

fn capture_ahead(input: &str) -> Option<u32> {
    static RE: LazyLock<Regex> = LazyLock::new(|| Regex::new(r"ahead (\d+)").unwrap());
    if let Some(captures) = RE.captures(input) {
        let n = &captures[1];
        Some(n.parse().unwrap())
    } else {
        None
    }
}

fn capture_behind(input: &str) -> Option<u32> {
    static RE: LazyLock<Regex> = LazyLock::new(|| Regex::new(r"behind (\d+)").unwrap());
    if let Some(captures) = RE.captures(input) {
        let n = &captures[1];
        Some(n.parse().unwrap())
    } else {
        None
    }
}

fn format_duration(duration: TimeDelta) -> String {
    if duration.num_days() > 0 {
        let days = duration.num_days();
        // Rough approximation for months and years
        if days > 365 {
            let years = days / 365;
            format!("{} years ago", years)
        } else if days > 30 {
            let months = days / 30;
            format!("{} months ago", months)
        } else if duration.num_weeks() > 0 {
            format!("{} weeks ago", duration.num_weeks())
        } else {
            format!("{} days ago", days)
        }
    } else if duration.num_hours() > 0 {
        format!("{} hours ago", duration.num_hours())
    } else if duration.num_minutes() > 0 {
        format!("{} minutes ago", duration.num_minutes())
    } else {
        format!("{} seconds ago", duration.num_seconds())
    }
}
