# Roadmap e Manual de Funcionalidades do Foton Contacts

## 🚀 Visão Geral

Este documento é o registro histórico e o manual de funcionalidades do plugin **Foton Contacts**. Ele descreve em detalhes o que já foi implementado e como o plugin funciona.

---

## ✅ Funcionalidades Implementadas

### Core

- **Gestão de Contatos:** CRUD completo para contatos (pessoas e empresas).
- **Tipos e Status:** Diferenciação entre contatos do tipo "pessoa" e "empresa", e controle de status (ativo, inativo, descontinuado).
- **Campos Personalizados:** Suporte a campos personalizados para contatos.
- **Anexos e Histórico:** Suporte a anexos e registro de histórico de alterações (`journals`) para contatos.
- **Busca e Filtro:** Funcionalidade de busca e filtros na lista de contatos.

### Relacionamentos

- **Vínculos Empregatícios:** Associação de contatos (pessoas) a empresas com cargos específicos, incluindo histórico de carreira.
- **Grupos de Contatos:** Criação de grupos de contatos para organização.
- **Vínculo com Tarefas:** Associação de contatos a tarefas do Redmine.

### Integração com Redmine

- **Permissões:** Sistema de permissões integrado ao Redmine para controlar o acesso aos contatos.
- **Visibilidade:** Controle de visibilidade de contatos (público, privado, por projeto).
- **Perfil de Usuário:** Vínculo de um contato a um usuário do Redmine.

### UI/UX e Arquitetura Front-End (Hotwire)

A interface foi completamente modernizada com **Hotwire (Turbo + Stimulus)** para oferecer uma experiência de usuário de página única (SPA-like), rápida e reativa, eliminando a necessidade de recarregamentos de página completos para operações comuns.

- **Navegação com Turbo Drive:** A navegação geral no plugin é acelerada, proporcionando uma sensação de fluidez.
- **Modais com Turbo Frames:** Todas as operações de CRUD (Criar/Editar Contatos, Adicionar/Editar Vínculos) ocorrem em modais que são carregados dinamicamente com Turbo Frames. Isso mantém o contexto do usuário na página de fundo (seja a lista de contatos ou o perfil de um contato).
- **Atualizações em Tempo Real com Turbo Streams:** Após salvar ou excluir um item em um modal, a lista de fundo é atualizada automaticamente via Turbo Streams, sem a necessidade de recarregar a página. Erros de validação também são tratados de forma inteligente dentro do modal.
- **Carregamento Sob Demanda (Lazy Loading):** Na página de perfil de um contato, o conteúdo das abas (Detalhes, Carreira, Histórico, etc.) é carregado sob demanda usando Turbo Frames, otimizando o tempo de carregamento inicial da página.
- **Componentes Interativos com Stimulus:**
  - **Feedback Visual:** Formulários fornecem feedback claro, desabilitando botões e exibindo spinners durante o envio para evitar cliques duplos.
  - **Formulários Dinâmicos:** A adição e remoção de campos aninhados (como vínculos empregatícios) é gerenciada de forma suave.
  - **Componentes Modernos:** A biblioteca `Select2` foi substituída por `Tom Select` para campos de seleção avançados, encapsulado em um controller Stimulus para uma integração perfeita.
- **"Empty States" Inteligentes:** Listas vazias (como um contato sem histórico ou vínculos) exibem mensagens amigáveis com botões de ação claros, guiando o usuário no próximo passo.

### Importação e Exportação

- **Importação de CSV:** Suporte para importação de contatos a partir de arquivos CSV.
- **Exportação de vCard e CSV:** Suporte para exportação de contatos individuais para o formato vCard (.vcf) e da lista para CSV.

### Testes

- **Testes de Integração:** Cobertura de testes de integração para o `ContactsController`, validando as principais ações de CRUD e filtros.

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
│   │   └── controllers (Stimulus)
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