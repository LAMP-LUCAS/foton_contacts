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
- [x] **Refatorar Actions `new` e `edit`:**
    - As actions devem renderizar uma view (ex: `new.html.erb`) que contém o `<turbo-frame-tag id="modal">` preenchido com o HTML do modal e o formulário **completo**.
    - O formulário deve ser renderizado a partir do partial `_form.html.erb` restaurado com **todos** os seus campos originais.
- [x] **Controlar Visibilidade com CSS:** Usar CSS para que, quando o `turbo-frame` for preenchido, o modal se torne visível.

### Fase 1.2: Refatoração do CRUD com Turbo Streams

- [x] **Restaurar `contact_params`:** Garantir que o `ContactsController` aceite todos os atributos do modelo novamente, incluindo campos aninhados.
- [x] **Adaptar Actions `create`, `update`, `destroy`:**
    - Devem responder **apenas** a `format.turbo_stream`.
    - Em caso de sucesso (`create`, `update`), o response deve conter dois streams: um para remover o modal (`<%= turbo_stream.remove "modal" %>`) e outro para atualizar/adicionar o registro na lista (`<%= turbo_stream.replace @contact, ... %>` ou `prepend`).
    - Em caso de falha de validação, a action deve re-renderizar a view do formulário (ex: `render :new, status: :unprocessable_entity`) para que o Turbo exiba os erros no modal.

### Fase 1.3: Migração do CRUD de Contatos

- [x] **Estruturar com Turbo Frames:** Envolver a lista de contatos e os modais de formulário em `turbo-frame-tag`.
- [x] **Atualizar Controller:** Modificar as actions `create` e `update` para responder com `Turbo Streams`.
- [x] **Remover Código Legado:** Excluir os arquivos `*.js.erb` e o código jQuery associado.

### Fase 1.4: Otimização com Carregamento Sob Demanda (Lazy Loading)

- [x] **Aplicar em Abas:** Converter o conteúdo das abas para `Turbo Frames` com `loading="lazy"`.

### Fase 1.5: Refinamento da Experiência com Stimulus

- [x] **Adicionar Feedback Visual:** Usar Stimulus para desabilitar botões e exibir spinners durante o envio de formulários.
- [ ] **Melhorar Formulários Dinâmicos:** Usar Stimulus para animar a adição de novos vínculos e focar automaticamente.
  *   **Diretriz:** A interface de vínculo (empregos) deve ser totalmente integrada ao Redmine 6 com Rails 7+ e adotar ao máximo as facilidades e evoluções do HotWire, respeitando as implementações do Redmine 6. Essa interface deve ser primeiramente implantada na página do contato (`app/views/contacts/show.html.erb`) em uma aba relacionada a isso, onde o usuário com permissão poderá realizar CRUD das informações. A implementação nos modais de edição e criação será realizada posteriormente.
- [x] **Implementar "Empty States":** Exibir mensagens e botões de ação quando as listas estiverem vazias.

### Fase 1.6: Modernização de Componentes

- [x] **Substituir Select2:** Planejar a substituição de `select2.js` por `Tom Select` com um wrapper Stimulus.

### Fase 1.7 REVISÃO E REATORAÇÃO: FOTON CONTACTS UI/UX

**Objetivo:** Realizar uma revisão completa e refatoração da interface (UI/UX) do plugin Foton Contacts, com foco em corrigir inconsistências da implementação mais recente e garantir a adesão estrita à arquitetura alvo definida nos documentos do projeto (concepts.md, views_architecture.md). O resultado final deve ser uma experiência de usuário coesa, fluida e robusta, utilizando o framework Hotwire de forma idiomática.

1. **Princípios Fundamentais (A Serem Seguidos):**

  - Arquitetura "Monolito Modular" com Hotwire:
  
        A aplicação deve se comportar como uma página única e rápida (monolito), mas ser construída de componentes independentes e carregados sob demanda (modular), como Turbo Frames e Streams.

  - Feedback Imediato ao Usuário:

        Toda ação assíncrona (envio de formulário, clique em botão) deve fornecer feedback visual claro (ex: desabilitar botão, mostrar spinner).

  - Consistência e Previsibilidade:
    
        A mesma ação em diferentes partes do plugin deve produzir o mesmo tipo de resposta e comportamento visual.

  - Resiliência e "Empty States":

        Nenhuma lista ou contêiner de dados deve quebrar ou ficar em branco. Sempre exiba um "estado vazio" amigável com uma chamada para ação clara (ex: "Nenhum vínculo encontrado. [Adicionar Vínculo]").

2. **Análise da Estrutura de Navegação (Horizontal) Verifique e garanta o seguinte fluxo de navegação principal:**

  - **Página de Índice (/contacts):**

    - Acesso: É a porta de entrada do plugin.

    - Links de Navegação: Clicar no nome de um contato na lista DEVE realizar uma navegação de página inteira (via data-turbo-frame="_top"), atualizando a URL para /contacts/:id. A página não deve ser carregada dentro de um frame na mesma tela.
        
    - Ações em Modais: Clicar em "Novo Contato" ou "Editar Contato" DEVE abrir um modal (<turbo-frame id="modal">) sem alterar a URL da página de fundo.

  - **Página de Perfil do Contato (/contacts/:id):**

      - Layout: A página deve ter um cabeçalho com as informações principais do contato e um sistema de abas para os detalhes secundários.
      - Carregamento de Abas (Lazy Loading): O conteúdo de cada aba (Detalhes, Vínculos, Histórico, etc.) DEVE ser carregado sob demanda usando Turbo Frames com src e loading="lazy".
        - O conteúdo inicial do frame deve ser um indicador de carregamento (ex: "Carregando...").
      - URL da Aba: A navegação entre as abas NÃO DEVE alterar a URL principal do navegador.

3. **Análise de Fluxos de CRUD (Vertical) Verifique e corrija os seguintes fluxos de trabalho, garantindo que todos operem dentro da arquitetura Hotwire para CRUD.**

  - CRUD de Contato (Formulário Principal):

    - Abertura: O formulário de criação/edição abre em um modal sobre a lista de contatos.
    - Submissão: Ao clicar em "Salvar".
      - O botão DEVE ser desabilitado para prevenir cliques duplos.
    - Em caso de sucesso: O servidor responde com um Turbo Stream que:
      1. Remove o modal;
      2. Adiciona/Atualiza o contato na lista de fundo.

      - Em caso de erro de validação: O servidor re-renderiza o formulário com os erros destacados DENTRO do modal. O modal NÃO DEVE fechar.

    - Cancelamento: Clicar em "Cancelar" ou no "X" remove o modal via Turbo Stream.

  - CRUD de Vínculos (Aba "Carreira" no Perfil do Contato):

    - Visualização: A lista de vínculos é carregada na aba correspondente.
      - Se não houver vínculos, um "empty state" com o botão "Adicionar Vínculo" é exibido.
    - Criação/Edição: Clicar em "Adicionar Vínculo" (ou "Editar" em um vínculo existente) DEVE abrir o formulário de vínculo em um modal (<turbo-frame id="modal">), sobre a página de perfil do contato.
      - O fluxo de submissão (sucesso/erro) DEVE seguir o mesmo padrão do CRUD de Contato, atualizando a lista de vínculos na aba em segundo plano.

4. **Checklist de Correção e Verificação Use esta lista para validar a implementação:**

  - [ ] **Navegação:** Clicar no nome de um contato na lista atualiza a URL para /contacts/:id?
  - [ ] **Modal de Contato:** O modal de new/edit de contato abre corretamente?
  - [ ] **Validação de Contato:** Erros de validação no formulário do contato são exibidos dentro do modal, sem fechá-lo?
  - [ ] **Sucesso no CRUD de Contato:** Salvar um contato fecha o modal e atualiza a lista atrás?
  - [ ] **Carregamento de Abas:** Todas as abas na página de perfil carregam seu conteúdo (ou um "empty state") sem erros no console?
  - [ ] **Aba Histórico:** A aba de histórico exibe as alterações do contato ou uma mensagem de "sem histórico"? (Verificar se o erro NoMethodError foi resolvido).
  - [ ] **Aba Vínculos:** A aba de vínculos exibe a lista de vínculos ou um "empty state" com o botão para adicionar?
  - [ ] **Modal de Vínculo:** Clicar em "Adicionar Vínculo" abre um formulário em um modal?
  - [ ] **Validação de Vínculo:** O formulário de vínculo lida corretamente com erros de validação dentro do modal?
  - [ ] **Sucesso no CRUD de Vínculo:** Salvar um vínculo fecha o modal e atualiza a lista na aba?
  - [ ] **Feedback Visual:** Os botões "Salvar" em todos os formulários são desabilitados durante a submissão?
  - [ ] **Consistência:** A experiência de uso dos modais de Contato e de Vínculo é idêntica?

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