use crossterm::event::{self, KeyCode, KeyEvent, KeyModifiers};
use eyre::Result;
use ratatui::Frame;
use ratatui::layout::{Constraint, Layout, Rect};
use ratatui::style::{Color, Modifier, Stylize};
use ratatui::widgets::{List, ListItem, ListState, Paragraph};

pub trait ListView {
    fn widths(&self) -> impl Iterator<Item = usize>;
    fn view<'a>(&'a self, widths: &[usize]) -> ListItem<'a>;
}

pub fn select<T: ListView>(inputs: &[T]) -> Result<Option<usize>> {
    let mut widths: Vec<usize> = Vec::new();
    for input in inputs {
        for (column, width) in input.widths().enumerate() {
            if let Some(max_width) = widths.get_mut(column) {
                *max_width = (*max_width).max(width);
            } else {
                widths.push(width);
            }
        }
    }

    let items = inputs.iter().map(|input| input.view(&widths)).collect();
    let mut model = Model::new(items);

    ratatui::run(|terminal| {
        while model.run_state != RunState::Done {
            terminal.draw(|frame| render(&mut model, frame))?;

            let mut msg = handle_event()?;
            while let Some(message) = msg {
                msg = update(&mut model, &message);
            }
        }

        if let Some(selected_index) = model.selected_index {
            Ok(Some(selected_index))
        } else {
            Ok(None)
        }
    })
}

struct Model<'a> {
    run_state: RunState,
    list_state: ListState,
    items: Vec<ListItem<'a>>,
    selected_index: Option<usize>,
}

impl<'a> Model<'a> {
    fn new(items: Vec<ListItem<'a>>) -> Self {
        let mut list_state = ListState::default();
        list_state.select_first();

        Self {
            run_state: RunState::Running,
            list_state,
            items,
            selected_index: None,
        }
    }
}

enum Message {
    CursorUp,
    CursorDown,
    Select,
    Quit,
}

#[derive(PartialEq, Eq)]
enum RunState {
    Running,
    Done,
}

fn handle_event() -> Result<Option<Message>> {
    if let Some(key) = event::read()?.as_key_press_event() {
        return Ok(handle_key_event(key));
    }
    Ok(None)
}

fn handle_key_event(key: KeyEvent) -> Option<Message> {
    match key.code {
        KeyCode::Esc => Some(Message::Quit),
        KeyCode::Char('c' | 'C') if key.modifiers == KeyModifiers::CONTROL => Some(Message::Quit),
        KeyCode::Enter => Some(Message::Select),
        KeyCode::Up => Some(Message::CursorUp),
        KeyCode::Down => Some(Message::CursorDown),
        _ => None,
    }
}

fn update(m: &mut Model, msg: &Message) -> Option<Message> {
    match msg {
        Message::CursorUp => {
            if let Some(selected) = m.list_state.selected()
                && selected == 0
            {
                m.list_state.select_last();
            } else {
                m.list_state.select_previous();
            }
            None
        }
        Message::CursorDown => {
            if let Some(selected) = m.list_state.selected()
                && selected == m.items.len() - 1
            {
                m.list_state.select_first();
            } else {
                m.list_state.select_next();
            }
            None
        }
        Message::Select => {
            m.selected_index = m.list_state.selected();
            m.run_state = RunState::Done;
            None
        }
        Message::Quit => {
            m.run_state = RunState::Done;
            None
        }
    }
}

fn render(m: &mut Model, frame: &mut Frame) {
    // Build layout
    let area = frame.area();
    let [main_area, help_area] =
        Layout::vertical([Constraint::Fill(1), Constraint::Length(1)]).areas(area);

    // Render main
    render_main(m, frame, main_area);

    // Render help hint
    render_help_normal(m, frame, help_area);
}

fn render_main(m: &mut Model, frame: &mut Frame, area: Rect) {
    let list = List::new(m.items.clone())
        .highlight_style(Modifier::BOLD)
        .highlight_symbol("> ");

    frame.render_stateful_widget(list, area, &mut m.list_state);
}

fn render_help_normal(_: &mut Model, frame: &mut Frame, area: Rect) {
    let help_paragraph =
        Paragraph::new("Quit: q • Move: <up>, <down> • Select: enter").fg(Color::DarkGray);
    frame.render_widget(help_paragraph, area);
}

// fn render_table(m: &mut Model, frame: &mut Frame, area: Rect) {
//     let header = Row::new(m.headers.clone())
//         .style(Style::new().bold())
//         .bottom_margin(1);

//     let footer = Row::new([
//         "Ratatouille Recipe",
//         "",
//         "135 kcal, 31g carbs, 6.4g protein",
//     ]);
//     let widths = [
//         Constraint::Percentage(30),
//         Constraint::Percentage(20),
//         Constraint::Percentage(50),
//     ];
//     let table = Table::new(m.rows.clone(), widths)
//         .header(header)
//         .footer(footer.italic())
//         .column_spacing(1)
//         .style(Color::White)
//         .row_highlight_style(Style::new().on_black().bold())
//         .column_highlight_style(Color::Gray)
//         .cell_highlight_style(Style::new().reversed().yellow())
//         .highlight_symbol("🍴 ");

//     frame.render_stateful_widget(table, area, &mut m.table_state);
// }
