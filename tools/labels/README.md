# 🔍 I18n Label Sync Tool for Rails

Este script em Python verifica labels utilizadas no seu projeto Rails com I18n (`l(:label_name)`) e garante que todas estejam presentes nos arquivos `.yml` da pasta `config/locales`. Labels ausentes são adicionadas automaticamente com valor vazio (`""`), facilitando a manutenção da tradução.

---

## ✨ Funcionalidades

- Varredura completa dos arquivos `.rb` e `.erb` em busca de labels I18n.
- Verificação dos arquivos `.yml` na pasta `config/locales`.
- Adição automática de labels ausentes com valor vazio.
- Interface de terminal amigável com contadores e tabela de resultados.

---

## 🧰 Requisitos

- Python 3.8+
- Pip (gerenciador de pacotes Python)

---

## 📦 Instalação

1. Navegue até a pasta do script:

```bash
cd tools/labels/
```

2. Execute o script de instalação:

```bash
bash install.sh
```

Isso instalará as dependências necessárias listadas em `requirements.txt`.

---

## 📁 Estrutura esperada

```
.
├── config/
│   └── locales/
│       ├── pt-BR.yml
│       └── en.yml
├── app/
│   ├── models/
│   ├── views/
│   └── controllers/
├── tools/
│   └── labels/
│       ├── sync_labels.py
│       ├── install.sh
│       └── requirements.txt
```

---

## 🚀 Como usar

Execute o script a partir da pasta `tools/labels`:

```bash
python sync_labels.py
```

---

## 📊 Saída esperada

- Número de labels encontradas no código
- Número de arquivos `.yml` verificados
- Quantidade de labels ausentes
- Tabela com as labels adicionadas

---

## 🛡️ Segurança

O script **não sobrescreve traduções existentes**. Ele apenas adiciona novas chaves com valor vazio.

---

## 🧪 Testado em

- Rails 7
- Estrutura padrão de I18n
- Arquivos `.yml` com codificação UTF-8

---

## 📮 Sugestões

Quer suporte a múltiplos idiomas, argumentos de linha de comando ou integração com CI? Abra uma issue ou contribua!
```

---

## 📄 `requirements.txt`

```txt
pyyaml
rich
```

---

## 🛠️ `install.sh`

```bash
#!/bin/bash

echo "🔧 Instalando dependências do I18n Label Sync Tool..."
pip install -r requirements.txt

echo "✅ Instalação concluída!"
```
