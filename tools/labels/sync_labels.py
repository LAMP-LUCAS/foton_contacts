import os
import re
import yaml
from collections import defaultdict
from rich.console import Console
from rich.table import Table
from rich.panel import Panel

# Configurações
LOCALES_DIR = "config/locales"
CODE_DIR = "."  # Raiz do projeto
LABEL_REGEX = re.compile(r"l\(\s*:\s*([a-zA-Z0-9_]+)\s*\)")
console = Console()

def find_labels_in_code():
    labels = set()
    for root, _, files in os.walk(CODE_DIR):
        for file in files:
            if file.endswith(".rb") or file.endswith(".erb"):
                path = os.path.join(root, file)
                with open(path, encoding="utf-8", errors="ignore") as f:
                    content = f.read()
                    matches = LABEL_REGEX.findall(content)
                    labels.update(matches)
    return labels

def load_yml_labels():
    yml_labels = defaultdict(dict)
    for file in os.listdir(LOCALES_DIR):
        if file.endswith(".yml"):
            path = os.path.join(LOCALES_DIR, file)
            with open(path, encoding="utf-8") as f:
                data = yaml.safe_load(f)
                lang = list(data.keys())[0]
                yml_labels[file] = data[lang]
    return yml_labels

def save_missing_labels(yml_labels, missing_labels):
    updated_files = 0
    for file, labels in yml_labels.items():
        path = os.path.join(LOCALES_DIR, file)
        lang = list(labels.keys())[0] if labels else "pt-BR"
        if lang not in labels:
            labels[lang] = {}
        added = 0
        for label in missing_labels:
            if label not in labels:
                labels[label] = ""
                added += 1
        if added:
            with open(path, "w", encoding="utf-8") as f:
                yaml.dump({lang: labels}, f, allow_unicode=True, sort_keys=True)
            updated_files += 1
    return updated_files

def main():
    console.print(Panel.fit("[bold cyan]🔍 I18n Label Sync Tool for Rails[/bold cyan]\n[dim]Verifica e sincroniza labels com arquivos YAML[/dim]"))

    console.print("[bold]📁 Verificando labels no código...[/bold]")
    code_labels = find_labels_in_code()
    console.print(f"🔎 Encontradas [green]{len(code_labels)}[/green] labels no código.")

    console.print("[bold]📄 Verificando arquivos YAML...[/bold]")
    yml_labels = load_yml_labels()
    all_yml_labels = set()
    for labels in yml_labels.values():
        all_yml_labels.update(labels.keys())
    console.print(f"📚 Total de arquivos YAML verificados: [green]{len(yml_labels)}[/green]")

    missing_labels = code_labels - all_yml_labels
    console.print(f"⚠️ Labels inexistentes: [red]{len(missing_labels)}[/red]")

    if missing_labels:
        updated = save_missing_labels(yml_labels, missing_labels)
        console.print(f"✅ Labels adicionadas com valor vazio em [yellow]{updated}[/yellow] arquivos.")
    else:
        console.print("[green]🎉 Nenhuma label faltando! Tudo sincronizado.[/green]")

    if missing_labels:
        table = Table(title="Labels Adicionadas")
        table.add_column("Label", style="cyan")
        for label in sorted(missing_labels):
            table.add_row(label)
        console.print(table)

if __name__ == "__main__":
    main()