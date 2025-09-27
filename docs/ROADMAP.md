# Roadmap e Manual de Funcionalidades do Foton Contacts

## 🚀 Visão Geral

Este documento é o registro histórico e o manual de funcionalidades do plugin **Foton Contacts**. Ele descreve em detalhes o que já foi implementado e como o plugin funciona.

---

## ✅ Funcionalidades Implementadas

### Core

- **Gestão de Contatos:** CRUD completo para contatos (pessoas e empresas).
- **Tipos e Status:** Diferenciação entre contatos do tipo "pessoa" e "empresa", e controle de status (ativo, inativo, descontinuado) com tipos enumerados.
- **Campos Personalizados:** Suporte a campos personalizados para contatos.
- **Anexos:** Suporte a anexos para contatos.
- **Busca e Filtro:** Funcionalidade de busca e filtros na lista de contatos.

### Relacionamentos

- **Cargos e Empresas:** Associação de contatos (pessoas) a empresas com cargos específicos.
- **Grupos de Contatos:** Criação de grupos de contatos para organização.
- **Vínculo com Tarefas:** Associação de contatos a tarefas do Redmine.

### Integração com Redmine

- **Permissões:** Sistema de permissões integrado ao Redmine para controlar o acesso aos contatos.
- **Visibilidade:** Controle de visibilidade de contatos (público, privado, por projeto).
- **Perfil de Usuário:** Vínculo de um contato a um usuário do Redmine.

### UI/UX e Fluxo de Trabalho

A interface foi projetada para ser robusta, responsiva e intuitiva, com foco em operações rápidas através de modais.

- **Botões de Ação Rápida:**
  - **➕ Novo Contato:** Abre um formulário modal para criação rápida.
  - **📥 Importar CSV/vCard:** Abre um modal para upload e mapeamento de campos.
  - **📊 Análise de Contato:** Um botão em cada linha da tabela abre um modal de Business Intelligence (BI) com dados analíticos.

- **Modal de Análise (BI):**
  - **Aba 1: Vínculos:** Mostra a quantidade de empresas vinculadas, cargos ocupados, status e o período de cada vínculo.
  - **Aba 2: Relações com Projetos:** Exibe projetos associados, tarefas vinculadas e a última atividade registrada.
  - **Aba 3: Carreira:** Apresenta uma linha do tempo dos vínculos, evolução de cargos e participação em grupos.
  - **Aba 4: Alertas e Inconsistências:** Aponta dados ausentes (e-mail, telefone), vínculos sem cargo definido e possíveis contatos duplicados.

### Importação e Exportação

- **Importação de CSV:** Suporte para importação de contatos a partir de arquivos CSV.
- **Exportação de vCard e CSV:** Suporte para exportação de contatos individuais para o formato vCard (.vcf) e da lista para CSV.

### Testes

- **Testes de Integração:** Cobertura de testes de integração para o `ContactsController`, validando as principais ações de CRUD e filtros.

### Backend e Estrutura

- **Refatoração Estrutural:** Unificação dos modelos de vínculo (`ContactRole` e `ContactEmployment`) para garantir consistência, manutenibilidade e corrigir bugs estruturais.

---

## 🏗️ Estrutura do Repositório

```text
./foton_contacts/
├── app
│   ├── controllers
│   ├── models
│   └── views
├── assets
│   ├── javascripts
│   └── stylesheets
├── config
│   ├── locales
│   └── routes.rb
├── db
│   └── migrate
├── lib
│   ├── hooks
│   └── patches
└── test
    ├── functional
    ├── integration
    └── unit
```