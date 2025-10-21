import os
import re
import json
from datetime import datetime
from rich.console import Console
from rich.table import Table

# Diretórios Rails
TARGET_DIRS = ["app/controllers", "app/models", "app/helpers"]
DOCSTRING_REGEX = re.compile(r"(?:(?:^|\n)#.*\n)*\s*(class|def)\s+")
console = Console()

# Arquivos auxiliares
CONFIG_PATH = ".config"
LOG_PATH = "log.json"
VIEW_PATH = "view.md"
SYNC_PATH = "sync.json"

def load_config():
    if os.path.exists(CONFIG_PATH):
        with open(CONFIG_PATH) as f:
            return json.load(f)
    return {}

def load_sync():
    if os.path.exists(SYNC_PATH):
        with open(SYNC_PATH) as f:
            return json.load(f)
    return {}

def save_log(entry):
    log = []
    if os.path.exists(LOG_PATH):
        with open(LOG_PATH) as f:
            log = json.load(f)
    log.append(entry)
    with open(LOG_PATH, "w") as f:
        json.dump(log, f, indent=2)

def extract_docstrings(file_path):
    with open(file_path, encoding="utf-8") as f:
        lines = f.readlines()

    doc_entries = []
    buffer = []
    for i, line in enumerate(lines):
        if line.strip().startswith("#"):
            buffer.append(line.strip())
        elif re.match(r"^\s*(class|def)\s+", line):
            doc_entries.append({
                "file": file_path,
                "line": i + 1,
                "type": "class" if "class" in line else "method",
                "signature": line.strip(),
                "docstring": "\n".join(buffer)
            })
            buffer = []
        else:
            buffer = []
    return doc_entries

def scan_all():
    all_docs = []
    for folder in TARGET_DIRS:
        for root, _, files in os.walk(folder):
            for file in files:
                if file.endswith(".rb"):
                    path = os.path.join(root, file)
                    docs = extract_docstrings(path)
                    all_docs.extend(docs)
    return all_docs

def export_view(docs):
    with open(VIEW_PATH, "w", encoding="utf-8") as f:
        for doc in docs:
            f.write(f"### {doc['type'].capitalize()} `{doc['signature']}`\n")
            f.write(f"**Arquivo:** `{doc['file']}`\n\n")
            f.write(f"```ruby\n{doc['docstring']}\n```\n\n")

def clean_docstrings(docs):
    for doc in docs:
        with open(doc["file"], encoding="utf-8") as f:
            lines = f.readlines()
        start = doc["line"] - len(doc["docstring"].split("\n"))
        for i in range(start, doc["line"]):
            if lines[i].strip().startswith("#"):
                lines[i] = ""
        with open(doc["file"], "w", encoding="utf-8") as f:
            f.writelines(lines)
        save_log({
            "action": "clean",
            "file": doc["file"],
            "line": doc["line"],
            "timestamp": datetime.now().isoformat()
        })

def sync_docstrings(docs, sync_data):
    for doc in docs:
        key = doc["signature"]
        if key in sync_data:
            new_doc = sync_data[key]
            with open(doc["file"], encoding="utf-8") as f:
                lines = f.readlines()
            start = doc["line"] - len(doc["docstring"].split("\n"))
            for i in range(start, doc["line"]):
                if lines[i].strip().startswith("#"):
                    lines[i] = ""
            lines.insert(start, f"# {new_doc}\n")
            with open(doc["file"], "w", encoding="utf-8") as f:
                f.writelines(lines)
            save_log({
                "action": "sync",
                "file": doc["file"],
                "line": doc["line"],
                "new_doc": new_doc,
                "timestamp": datetime.now().isoformat()
            })

def show_table(docs):
    table = Table(title="DocStrings Encontradas")
    table.add_column("Arquivo", style="cyan")
    table.add_column("Linha", style="green")
    table.add_column("Tipo")
    table.add_column("Assinatura")
    table.add_column("Docstring", style="dim")
    for doc in docs:
        table.add_row(doc["file"], str(doc["line"]), doc["type"], doc["signature"], doc["docstring"].replace("\n", " "))
    console.print(table)

def main():
    console.print("[bold cyan]📘 Gerenciador de DocStrings Rails[/bold cyan]")
    config = load_config()
    docs = scan_all()

    if config.get("mode") == "view":
        show_table(docs)
        export_view(docs)
        console.print(f"[green]✅ Exportado para {VIEW_PATH}[/green]")

    elif config.get("mode") == "clean":
        clean_docstrings(docs)
        console.print("[yellow]🧹 Docstrings removidas.[/yellow]")

    elif config.get("mode") == "sync":
        sync_data = load_sync()
        sync_docstrings(docs, sync_data)
        console.print("[blue]🔄 Docstrings sincronizadas com sync.json[/blue]")

    else:
        console.print("[red]❌ Modo inválido. Use 'view', 'clean' ou 'sync' em .config[/red]")

if __name__ == "__main__":
    main()