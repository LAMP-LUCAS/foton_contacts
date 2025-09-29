# Foton Contacts: Plano de Trabalho (Workplan)

## 🧭 Apresentação

Este documento detalha o plano de trabalho e as tarefas pendentes para a evolução do plugin **Foton Contacts**. O objetivo do plugin é ser a solução definitiva para gestão de contatos e relacionamentos no Redmine para a indústria AEC.

Para detalhes sobre funcionalidades já implementadas e como o plugin funciona, consulte o **[Roadmap e Manual de Funcionalidades](ROADMAP.md)**.

Para diretrizes de arquitetura, UI/UX e conceitos de desenvolvimento, consulte o **[Relatório de Arquitetura de Views](views_architecture.md)**.

---

## 🚀 Fase 1 — Modernização da Interface com Hotwire (Prioridade)

**Objetivo:** Migrar a interface do plugin de UJS/jQuery para Hotwire (Turbo e Stimulus) para criar uma experiência de usuário mais rápida, fluida e moderna.

### Fase 1.0: Preparação do Ambiente
- [x] **Reverter Alterações Anteriores:** Garantir que todos os arquivos, exceto este workplan, estejam no estado `HEAD` do commit anterior.
- [x] **Instalar Hotwire:** Adicionar a gem `hotwire-rails` e executar `rails hotwire:install`.
- [x] **Análise de Conflitos:** Garantir que a inicialização do Hotwire não entre em conflito com os scripts JavaScript existentes.
- [x] **Limpeza de Artefatos UJS:** Excluir **todos** os arquivos `.js.erb` relacionados ao CRUD de contatos (`create.js.erb`, `update.js.erb`, `new.js.erb`, `edit.js.erb`, `destroy.js.erb`).

### Fase 1.1: Implementação Idiomática do Modal com Turbo Frames

- [x] **Estruturar o Contêiner do Modal:** Adicionar um `<turbo-frame-tag id="modal" class="modal-container">` vazio e oculto na view `index.html.erb`.
- [x] **Adaptar Links de Ação:** Modificar os links "Novo Contato" e "Editar" para que apontem para este frame (`data: { turbo_frame: "modal" }`).
- [ ] **Refatorar Actions `new` e `edit`:**
    - As actions devem renderizar uma view (ex: `new.html.erb`) que contém o `<turbo-frame-tag id="modal">` preenchido com o HTML do modal e o formulário **completo**.
    - O formulário deve ser renderizado a partir do partial `_form.html.erb` restaurado com **todos** os seus campos originais.
- [ ] **Controlar Visibilidade com CSS:** Usar CSS para que, quando o `turbo-frame` for preenchido, o modal se torne visível.

### Fase 1.2: Refatoração do CRUD com Turbo Streams

- [ ] **Restaurar `contact_params`:** Garantir que o `ContactsController` aceite todos os atributos do modelo novamente, incluindo campos aninhados.
- [ ] **Adaptar Actions `create`, `update`, `destroy`:**
    - Devem responder **apenas** a `format.turbo_stream`.
    - Em caso de sucesso (`create`, `update`), o response deve conter dois streams: um para remover o modal (`<%= turbo_stream.remove "modal" %>`) e outro para atualizar/adicionar o registro na lista (`<%= turbo_stream.replace @contact, ... %>` ou `prepend`).
    - Em caso de falha de validação, a action deve re-renderizar a view do formulário (ex: `render :new, status: :unprocessable_entity`) para que o Turbo exiba os erros no modal.

### Fase 1.3: Migração do CRUD de Contatos

- [ ] **Estruturar com Turbo Frames:** Envolver a lista de contatos e os modais de formulário em `turbo-frame-tag`.
- [ ] **Atualizar Controller:** Modificar as actions `create` e `update` para responder com `Turbo Streams`.
- [ ] **Remover Código Legado:** Excluir os arquivos `*.js.erb` e o código jQuery associado.

### Fase 1.4: Otimização com Carregamento Sob Demanda (Lazy Loading)

- [ ] **Aplicar em Abas:** Converter o conteúdo das abas para `Turbo Frames` com `loading="lazy"`.

### Fase 1.5: Refinamento da Experiência com Stimulus

- [ ] **Adicionar Feedback Visual:** Usar Stimulus para desabilitar botões e exibir spinners durante o envio de formulários.
- [ ] **Melhorar Formulários Dinâmicos:** Usar Stimulus para animar a adição de novos vínculos e focar automaticamente.
- [ ] **Implementar "Empty States":** Exibir mensagens e botões de ação quando as listas estiverem vazias.

### Fase 1.6: Modernização de Componentes

- [ ] **Substituir Select2:** Planejar a substituição de `select2.js` por `Tom Select` com um wrapper Stimulus.

---

## 🧪 Fase 2 — Testes e Validações (Pendentes)

**Objetivo:** Aumentar a robustez e a confiabilidade do plugin.

- [ ] **Testes Unitários (RSpec):** Validar modelos, métodos auxiliares e regras de validação.
- [ ] **Testes de Permissão:** Confirmar que cada usuário vê e acessa apenas o que tem direito.
- [ ] **Testes de Interface:** Garantir que a UI responde corretamente em desktop e mobile após a migração para Hotwire.
- [ ] **Testes de Resiliência:** Simular dados corrompidos, ausentes ou duplicados.

---

## 📦 Fase 3 — Empacotamento e Documentação (Pendentes)

**Objetivo:** Facilitar a adoção e contribuição para o plugin.

- [ ] **Importação de vCard:** Detalhar e testar o processo de importação.
- [ ] **Documentação da API REST:** Documentar todos os endpoints da API.
- [ ] **Hooks para Desenvolvedores:** Detalhar os hooks disponíveis para extensão do plugin.

---

## 📝 Backlog Pendente

### Implementar Histórico de Alterações no Contato

- **Problema:** A funcionalidade de histórico (`journals`) está desativada pois o modelo `Contact` não foi configurado para tal.
- **Solução Proposta:**
  1. Adicionar `acts_as_journalized` ao modelo `contact.rb`.
  2. Restaurar a lógica no `ContactsController#show` e na view `show.html.erb` para carregar e renderizar os `journals`.
- **Status:** Pendente.

### Refatorar Grupos de Contatos

- **Problema:** O modelo `ContactGroup` usa flags booleanas (`is_system`, `is_private`) que poderiam ser substituídas por um enum `group_type` mais robusto.
- **Solução Proposta:** Avaliar a substituição das flags pelo enum `group_type` (`general`, `ephemeral`).
- **Status:** Pendente.