import os
import re
import sys
import yaml
from collections import defaultdict
from rich.console import Console
from rich.table import Table
from rich.panel import Panel

# Expressão regular para encontrar labels no formato l(:label_name)
LABEL_REGEX = re.compile(r"l\(\s*:\s*([a-zA-Z0-9_]+)\s*\)")
console = Console()

def find_project_root():
    """
    Encontra o diretório raiz do projeto subindo a árvore de diretórios.
    A raiz é identificada pela presença do diretório 'config/locales'.
    """
    current_dir = os.path.abspath(".")
    while current_dir != os.path.dirname(current_dir): # Para no root (e.g., C:\)
        if os.path.isdir(os.path.join(current_dir, "config", "locales")):
            return current_dir
        current_dir = os.path.dirname(current_dir)
    return None

def get_project_root():
    """
    Tenta encontrar a raiz do projeto automaticamente. Se não conseguir,
    pede ao usuário para fornecer o caminho.
    """
    root = find_project_root()
    if root:
        console.print(f"✅ Raiz do projeto detectada em: [bold green]{root}[/bold green]")
        return root

    console.print("[bold yellow]⚠️ Não foi possível detectar a raiz do projeto (onde a pasta 'config/locales' se encontra).[/bold yellow]")
    path = console.input("Por favor, insira o caminho para o diretório raiz do plugin ou pressione Enter para sair: ")

    if not path:
        return None

    if os.path.isdir(os.path.join(path, "config", "locales")):
        return os.path.abspath(path)
    else:
        console.print(f"[bold red]Erro: O caminho '{path}' não parece ser um diretório de plugin válido (não contém 'config/locales').[/bold red]")
        return None


def find_labels_in_code(code_dir):
    """Encontra todas as labels nos arquivos .rb e .erb."""
    labels = set()
    # Itera sobre todos os arquivos no diretório de código
    for root, _, files in os.walk(code_dir):
        for file in files:
            if file.endswith((".rb", ".erb")):
                path = os.path.join(root, file)
                try:
                    with open(path, "r", encoding="utf-8", errors="ignore") as f:
                        content = f.read()
                        matches = LABEL_REGEX.findall(content)
                        labels.update(matches)
                except Exception as e:
                    console.print(f"Erro ao ler o arquivo {path}: {e}")
    return labels

def load_yml_labels(locales_dir):
    """Carrega todas as labels dos arquivos YAML de tradução."""
    yml_labels = defaultdict(dict)
    try:
        for file in os.listdir(locales_dir):
            if file.endswith(".yml"):
                path = os.path.join(locales_dir, file)
                with open(path, "r", encoding="utf-8") as f:
                    data = yaml.safe_load(f)
                    # A chave de primeiro nível é o idioma (ex: 'pt-BR')
                    lang = list(data.keys())[0]
                    yml_labels[file] = data[lang]
    except FileNotFoundError:
        # Este erro não deve acontecer por causa da verificação na main
        return None
    return yml_labels

def save_missing_labels(locales_dir, yml_labels, missing_labels):
    """Adiciona as labels faltantes ao final dos arquivos YAML, preservando o conteúdo existente."""
    updated_files = 0
    
    globally_missing_labels = set(missing_labels)

    for file_name, labels_in_this_file in yml_labels.items():
        # Encontra quais das labels globalmente ausentes também estão ausentes NESTE arquivo
        if labels_in_this_file:
            labels_to_add_to_this_file = globally_missing_labels - set(labels_in_this_file.keys())
        else:
            labels_to_add_to_this_file = globally_missing_labels

        if not labels_to_add_to_this_file:
            continue

        path = os.path.join(locales_dir, file_name)
        
        # Prepara o novo conteúdo a ser anexado
        lines_to_append = []
        for label in sorted(list(labels_to_add_to_this_file)):
            # Formata como:   label_key: "TODO: label_key"
            lines_to_append.append(f'  {label}: "TODO: {label}"')

        # Anexa ao arquivo sem sobrescrever/reformatar
        with open(path, "a", encoding="utf-8") as f:
            # Garante uma linha em branco antes de adicionar novo conteúdo
            f.write("\n" + "\n".join(lines_to_append))
        
        updated_files += 1
            
    return updated_files

def main():
    """Função principal que orquestra a sincronização."""
    console.print(Panel.fit("[bold cyan]🔍 I18n Label Sync Tool for Rails[/bold cyan]\n[dim]Verifica e sincroniza labels com arquivos YAML[/dim]"))

    project_root = get_project_root()
    if not project_root:
        console.print("[bold red]Saindo.[/bold red]")
        sys.exit(1)

    # Define os diretórios com base na raiz do projeto
    code_dir = project_root
    locales_dir = os.path.join(project_root, "config", "locales")

    console.print("\n[bold]📁 Verificando labels no código...[/bold]")
    code_labels = find_labels_in_code(code_dir)
    console.print(f"🔎 Encontradas [green]{len(code_labels)}[/green] labels no código.")

    console.print("\n[bold]📄 Verificando arquivos YAML...[/bold]")
    yml_labels = load_yml_labels(locales_dir)
    if yml_labels is None:
        console.print(f"[bold red]Erro: O diretório de locales '{locales_dir}' não foi encontrado.[/bold red]")
        sys.exit(1)

    all_yml_labels = set()
    for labels in yml_labels.values():
        if labels: # Garante que o arquivo yml não está vazio
            all_yml_labels.update(labels.keys())
            
    console.print(f"📚 Total de arquivos YAML verificados: [green]{len(yml_labels)}[/green]")

    missing_labels = code_labels - all_yml_labels
    
    if not missing_labels:
        console.print("\n[bold green]🎉 Nenhuma label faltando! Tudo sincronizado.[/bold green]")
        return

    console.print(f"\n⚠️  Labels encontradas no código mas ausentes nos arquivos YAML: [bold red]{len(missing_labels)}[/bold red]")
    
    if console.input("Deseja adicionar as labels faltantes aos arquivos .yml? (s/N) ").lower() == 's':
        updated_count = save_missing_labels(locales_dir, yml_labels, missing_labels)
        console.print(f"✅ Labels adicionadas com valor 'TODO' em [yellow]{updated_count}[/yellow] arquivos.")
    else:
        console.print("Nenhuma alteração foi feita.")

    table = Table(title="Labels Faltantes")
    table.add_column("Label", style="cyan")
    for label in sorted(missing_labels):
        table.add_row(label)
    console.print(table)

if __name__ == "__main__":
    main()
