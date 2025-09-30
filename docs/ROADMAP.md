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

---

## 🏛️ Arquitetura de Modais

O plugin utiliza duas abordagens distintas para a implementação de modais, cada uma com suas próprias características, prós e contras.

### 1. Modais de CRUD (Criar/Editar)

- **Tecnologia:** **Hotwire (Turbo Frames + Turbo Streams)**.
- **Descrição:** Estes modais são integrados diretamente no fluxo da página usando Turbo Frames. As ações (como salvar ou cancelar) são tratadas via Turbo Streams, que atualizam o DOM de forma eficiente sem a necessidade de um recarregamento completo da página. O conteúdo do modal é renderizado no servidor e inserido em um frame `<turbo-frame id="modal">`.
- **Prós:**
  - **Leveza e Performance:** Extremamente rápido, pois apenas o HTML necessário é transportado pela rede.
  - **Integração com Rails:** Solução nativa do Rails 7, exigindo pouquíssimo JavaScript customizado.
  - **Desenvolvimento Ágil:** Mantém a lógica no servidor, simplificando o desenvolvimento.
- **Contras:**
  - **Menos Flexibilidade de UI:** Funcionalidades complexas de UI, como arrastar e redimensionar, não são suportadas nativamente e exigem a integração com bibliotecas de JavaScript (como StimulusJS).
  - **Fluxo de Página:** Por ser parte do DOM da página, o modal não se comporta como uma "janela" flutuante independente, o que pode ser menos intuitivo para certas experiências de usuário.

### 2. Modal de Análise (BI)

- **Tecnologia:** **AJAX + Biblioteca de UI JavaScript (provavelmente jQuery UI Dialog)**.
- **Descrição:** Este modal opera de forma mais tradicional. Um link dispara uma requisição AJAX para o servidor, que retorna um HTML parcial. Esse HTML é então injetado em um contêiner de modal genérico, gerenciado por uma biblioteca JavaScript (o Redmine utiliza jQuery UI, que oferece o componente "Dialog").
- **Prós:**
  - **Experiência de Usuário Rica:** Suporta nativamente funcionalidades avançadas como arrastar, redimensionar e manter estado no lado do cliente. Proporciona a sensação de uma janela de aplicativo desktop.
  - **Isolamento:** O estado e o comportamento do modal são completamente gerenciados no lado do cliente, isolando-o do resto da página.
- **Contras:**
  - **Mais Complexidade:** Exige mais código JavaScript para gerenciar os eventos, o estado e as interações do modal.
  - **Performance:** Pode ser ligeiramente mais lento, pois envolve mais overhead no lado do cliente e, tradicionalmente, um gerenciamento de estado mais manual.
  - **Estilo de Código:** Representa uma abordagem mais antiga e imperativa em comparação com a reatividade declarativa do Hotwire.
