use std::io::{self, ErrorKind, IsTerminal};
use std::process::Stdio;

use comfy_table::{Row, Table, presets::NOTHING};
use crossterm::terminal;
use eyre::{Result, WrapErr, bail};
use tokio::io::AsyncWriteExt;
use tokio::process::Command;

pub async fn table_view<H, R>(header: H, rows: R) -> Result<()>
where
    H: Into<Row>,
    R: IntoIterator,
    R::Item: Into<Row>,
{
    let mut table = Table::new();
    table.load_preset(NOTHING);
    table.set_header(header);
    table.add_rows(rows);

    render(&table).await
}

async fn render(table: &Table) -> Result<()> {
    if need_pager(table) {
        return render_with_pager(table).await;
    }

    let mut stdout = tokio::io::stdout();
    let output = table.to_string() + "\n";
    if let Err(error) = stdout.write_all(output.as_bytes()).await
        && error.kind() != ErrorKind::BrokenPipe
    {
        return Err(error).wrap_err("failed to write table to stdout");
    }
    Ok(())
}

async fn render_with_pager(table: &Table) -> Result<()> {
    let mut pager = Command::new("less")
        .args(["-R", "-~", "--mouse", "--redraw-on-quit", "--header=1"])
        .stdin(Stdio::piped())
        .spawn()
        .wrap_err("failed to start less")?;

    let mut stdin = pager
        .stdin
        .take()
        .ok_or_else(|| eyre::eyre!("failed to open less stdin"))?;
    let output = table.to_string() + "\n";
    if let Err(error) = stdin.write_all(output.as_bytes()).await
        && error.kind() != ErrorKind::BrokenPipe
    {
        return Err(error).wrap_err("failed to write table to less");
    }
    drop(stdin);

    let status = pager.wait().await.wrap_err("failed to wait for less")?;
    if !status.success() {
        bail!("less exited with status {status}");
    }

    Ok(())
}

fn need_pager(table: &Table) -> bool {
    if !io::stdout().is_terminal() {
        return false;
    }

    let size = terminal::size();
    if size.is_err() {
        // Use pager if we can't get the terminal size
        return true;
    }

    let (_, rows) = size.unwrap();
    let output_rows = table.row_count() + usize::from(table.header().is_some());
    output_rows >= usize::from(rows)
}
