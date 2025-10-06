# Foton Contacts: Plano de Trabalho (Workplan)

## 🧭 Apresentação

Este documento é o plano de trabalho central para o desenvolvimento do plugin **Foton Contacts**. Ele organiza as tarefas em fases e registra o backlog de funcionalidades e bugs. Este plugin está implantado no Redmine 6.0.7, ruby 3.3.9, Rails 7.2.2.2 e Puma 7.0.4, rodando na imagem oficial do Redmine e banco de dados postgres 15 no Docker.

O objetivo do plugin é ser a solução definitiva para gestão de contatos e relacionamentos (CRM) no Redmine, com foco na indústria de Arquitetura, Engenharia e Construção (AEC).

Para garantir a consistência e a qualidade, o desenvolvimento é guiado por um conjunto de documentos vivos que evoluem com o projeto. É fundamental consultá-los:

- **[📄 Conceitos e Diretrizes de Desenvolvimento (concepts.md)](concepts.md)**
  - **Resumo:** Descreve a filosofia do projeto, como o foco na usabilidade e a adesão à arquitetura **Hotwire (Turbo + Stimulus)**. É o ponto de partida para entender *como* o código deve ser escrito.

- **[🏗️ Arquitetura de Views (views_architecture.md)](views_architecture.md)**
  - **Resumo:** Detalha tecnicamente a arquitetura de front-end. Explica os padrões de UI/UX, o uso de componentes como Turbo Frames e Streams, e o fluxograma de interação do usuário. Essencial para quem vai trabalhar na interface.

- **[🗺️ Roadmap e Manual de Funcionalidades (ROADMAP.md)](ROADMAP.md)**
  - **Resumo:** Funciona como o manual do usuário final e o registro de tudo que já foi implementado. Descreve em detalhes as funcionalidades existentes e a estrutura do plugin.

---

## 🚀 Fases de Desenvolvimento

### ✅ Fase 1: Modernização da Interface com Hotwire (Concluída)

**Objetivo:** Migrar a interface legada (UJS/jQuery) para Hotwire, criando uma experiência de usuário moderna, rápida e reativa, similar a uma Single-Page Application (SPA).

**Resultados:**
- A navegação e as operações de CRUD foram migradas para Turbo Drive, Frames e Streams.
- Formulários de criação e edição agora abrem em modais sem recarregar a página.
- A interface é atualizada em tempo real após as ações do usuário.
- O conteúdo de abas é carregado sob demanda (*lazy loading*), otimizando a performance.
- Componentes interativos, como a seleção com `Tom Select`, são gerenciados por Stimulus.
- A experiência do usuário foi refinada com feedback visual e "empty states".

---

### 🎯 Fase 2: Vínculo de Contatos e Grupos às Issues (Em Andamento)

**Objetivo Primordial:** Implementar a capacidade de associar contatos (pessoas) e grupos de contatos diretamente a uma issue do Redmine, fornecendo contexto crucial sobre os stakeholders de cada tarefa.

#### Comportamento Esperado (BDD - Behavior-Driven Development)

- **Dado que** estou visualizando uma issue,
- **Então** devo ver uma nova seção chamada "Contatos Vinculados" com os contatos e/ou grupos vinculados a ela.
- **Dado que** estou editando uma issue,
- **Então** devo ver uma seção chamada "Contatos Vinculados".
- **Quando** eu digitar o nome de uma pessoa ou grupo no campo de busca dentro desta seção,
- **Então** o sistema deve me apresentar uma lista de sugestões correspondentes, separadas por "Pessoas" e "Grupos".
- **Quando** eu selecionar um item da lista,
- **Então** ele deve aparecer como uma "tag" ou "pill" na seção de contatos vinculados, e o vínculo deve ser salvo instantaneamente.
- **E** cada "tag" deve ter um botão "x" para remover o vínculo de forma imediata.
- **Dado que** adicionei múltiplos contatos individuais,
- **Quando** eu clicar no botão "Criar grupo a partir destes contatos",
- **Então** um modal deve surgir para que eu insira o nome do novo grupo.
- **E** ao salvar, o novo grupo é criado, associado aos contatos selecionados e vinculado à issue.

#### Conceitos e Experiência do Usuário (UX)

O objetivo é criar uma experiência fluida e integrada. A seção "Contatos Vinculados" não deve parecer um adendo, mas uma parte natural da issue.

- **Visual Limpo:** As "tags" de contatos e grupos serão visualmente distintas (ex: ícone de pessoa vs. ícone de grupo) e apresentarão o nome de forma clara.
- **Interatividade Instantânea:** Todas as ações (adicionar, remover) ocorrerão sem recarregar a página, fornecendo feedback imediato ao usuário. A interface deve refletir o estado do sistema em tempo real.
- **Fluxo de Trabalho Inteligente:** A capacidade de criar grupos "on-the-fly" a partir dos contatos já vinculados a uma issue é um diferencial que economiza tempo e incentiva a organização da informação.

#### Arquitetura e Tecnologias

A implementação seguirá a filosofia moderna já estabelecida na Fase 1.

- **Backend:** Ruby on Rails, seguindo as convenções do Redmine.
- **Frontend:** **Hotwire (Turbo + Stimulus)** para reatividade e atualizações em tempo real.
  - **Turbo Streams:** Para adicionar e remover as "tags" de contatos da lista de forma dinâmica após as ações de `create` e `destroy`.
  - **StimulusJS:** Para gerenciar o comportamento do campo de busca e a lógica de interação do frontend, como a criação de grupo "on-the-fly".
- **Componente de UI:** **Tom Select**, já integrado ao projeto, será usado para o campo de busca inteligente, configurado para buscar em múltiplos modelos (`Contact`, `ContactGroup`) e exibir os resultados em `optgroup` distintos.

#### Etapas Detalhadas de Implementação

1.  **Estrutura do Banco de Dados (Backend)**
    -   [ ] **1.1. Criar a Migração:** Gerar e executar uma nova migração para criar a tabela `contact_issue_links` com as colunas: `issue_id` (integer), `contact_id` (integer, nullable), `contact_group_id` (integer, nullable). Adicionar índices para performance.
    -   [ ] **1.2. Configurar o Modelo `ContactIssueLink`:** Criar/ajustar o arquivo `app/models/contact_issue_link.rb`.
        -   Adicionar `belongs_to :issue`, `belongs_to :contact, optional: true`, `belongs_to :contact_group, optional: true`.
        -   Implementar a validação que garante que `contact_id` ou `contact_group_id` esteja presente, mas não ambos.
    -   [ ] **1.3. Atualizar Associações (Patches):**
        -   No patch `lib/patches/issue_patch.rb`, adicionar `has_many :contact_issue_links, dependent: :destroy`, `has_many :contacts, through: :contact_issue_links`, e `has_many :contact_groups, through: :contact_issue_links`.
        -   No modelo `Contact`, adicionar `has_many :contact_issue_links` e `has_many :issues, through: :contact_issue_links`.
        -   No modelo `ContactGroup`, adicionar `has_many :contact_issue_links` e `has_many :issues, through: :contact_issue_links`.

2.  **Lógica de Negócio (Backend)**
    -   [ ] **2.1. Definir Rotas:** Em `config/routes.rb`, aninhar `resources :contact_issue_links, only: [:create, :destroy]` dentro do resource de `issues` para criar os endpoints necessários.
    -   [ ] **2.2. Implementar `ContactIssueLinksController`:** Criar o controller em `app/controllers/contact_issue_links_controller.rb`.
        -   Implementar a ação `create` para criar o vínculo. A ação deve responder com um `turbo_stream.append` para adicionar a "tag" na view.
        -   Implementar a ação `destroy` para remover o vínculo. A ação deve responder com um `turbo_stream.remove` para remover a "tag" da view.
        -   Garantir que as permissões de usuário são verificadas em ambas as ações.
    -   [ ] **2.3. Criar Endpoint de Busca:** Criar uma nova ação em um controller (ex: `ContactsController#search`) que responda a requisições do Tom Select, retornando um JSON com Pessoas e Grupos formatados para `optgroup`.

3.  **Interface do Usuário (Frontend)**
    -   [ ] **3.1. Registrar o Hook da View:** Em `lib/hooks/views_layouts_hook.rb`, registrar um `render_on :view_issues_show_details_bottom` que renderizará uma partial na página da issue.
    -   [ ] **3.2. Criar a Partial Principal:** Criar a view `app/views/issues/_foton_contacts_section.html.erb`.
        -   Esta partial conterá um `<turbo-frame>` para isolar a seção.
        -   Listará os contatos e grupos já vinculados (`issue.contact_issue_links`).
        -   Renderizará as "tags" de contatos/grupos, cada uma com seu link de `destroy` (usando `data-turbo-method="delete"`).
    -   [ ] **3.3. Criar o Formulário de Adição:** Dentro da partial principal, criar o formulário (`form_with`) que aponta para `ContactIssueLinksController#create`.
        -   O formulário conterá o campo de texto que será transformado em um `Tom Select` pelo Stimulus.
    -   [ ] **3.4. Configurar o `TomSelectController` (Stimulus):**
        -   Adaptar ou estender o controller `tom_select_controller.js` para carregar os dados do endpoint de busca (`/contacts/search`).
        -   Configurá-lo para, ao selecionar um item, submeter o formulário de adição automaticamente.

#### Checklist de Tarefas - Ui/Ux

- {
    "id": 1,
    "title": "Busca Instantânea com Debounce",
    "description": "À medida que o usuário digita no campo de busca, os resultados são atualizados em tempo real, sem a necessidade de clicar em um botão. O 'debounce' evita que uma nova busca seja feita a cada tecla pressionada, esperando uma pequena pausa na digitação para disparar a consulta. Isso torna a experiência fluida e rápida.",
    "hotwire_example": "Utilizar um controller Stimulus para monitorar o evento 'input' do campo de busca. O controller aplicaria o debounce e, em seguida, atualizaria um `<turbo-frame id='search_results'>` com os resultados vindos do servidor."
  },
-  {
    "id": 2,
    "title": "Seleção Visual e Feedback Imediato",
    "description": "Ao clicar no botão 'Adicionar', o contato é visualmente movido ou copiado para a lista de 'Selecionados'. O item na lista de busca original muda de estado (ex: fica esmaecido e o botão se transforma em 'Adicionado') para dar um feedback claro de que a ação foi concluída e evitar duplicidade.",
    "hotwire_example": "O clique no botão 'Adicionar' pode disparar uma ação de Turbo Stream que simultaneamente anexa o contato na lista de selecionados e atualiza o estado do contato na lista de resultados (replace)."
  },
-  {
    "id": 3,
    "title": "Área de 'Arrastar e Soltar' (Drag and Drop)",
    "description": "Permitir que os usuários arrastem contatos da lista de resultados e os soltem na lista de selecionados. É uma interação intuitiva e muito satisfatória, especialmente para montar listas rapidamente.",
    "hotwire_example": "Implementar com um controller Stimulus que gerencia os eventos de drag-and-drop. Ao 'soltar', o controller pode fazer uma requisição assíncrona para adicionar o contato e usar Turbo Streams para atualizar a UI."
  },
-  {
    "id": 4,
    "title": "Barra de Ações Flutuante",
    "description": "Assim que o primeiro contato é adicionado, uma barra de ações flutuante surge na parte inferior da tela. Ela mostra o número de contatos selecionados e o botão 'Salvar Grupo'. Isso mantém as ações principais sempre visíveis, sem que o usuário precise rolar a página.",
    "hotwire_example": "A primeira ação de adicionar um contato via Turbo Stream pode incluir uma stream adicional para anexar (append) a barra de ações flutuante ao `<body>` da página."
  },
-  {
    "id": 5,
    "title": "Edição Inline de Funções/Notas na Lista de Seleção",
    "description": "Na lista de contatos selecionados, permitir que o usuário clique no campo 'função' ou 'notas' (se aplicável) e o edite diretamente, sem abrir um modal. O campo se transforma em um input de texto e salva ao perder o foco ou ao pressionar Enter.",
    "hotwire_example": "Cada item da lista de selecionados pode ser um `<turbo-frame>`. Ao clicar em 'Editar', o conteúdo do frame é substituído por um formulário de edição. Ao submeter, o frame é atualizado com a informação nova."
  },
-  {
    "id": 6,
    "title": "Desfazer Remoção com 'Toast Notification'",
    "description": "Ao remover um contato da lista de selecionados, ele desaparece da lista, mas uma notificação 'toast' aparece por alguns segundos com a mensagem 'Contato removido. [Desfazer]'. Isso previne remoções acidentais e dá mais segurança ao usuário.",
    "hotwire_example": "A ação de remover dispara uma Turbo Stream para remover o item da lista e outra para adicionar o 'toast' com o link de 'desfazer'. O link de desfazer chamaria outra ação no controller para re-adicionar o item via stream."
  },
-  {
    "id": 7,
    "title": "Pré-visualização de Contatos com 'Hover'",
    "description": "Ao passar o mouse sobre um contato na lista de busca, um pequeno card de pré-visualização aparece ao lado, mostrando mais detalhes como endereço, empresa e descrição, sem a necessidade de clicar. Isso agiliza a identificação do contato correto.",
    "hotwire_example": "Um controller Stimulus nos itens da lista pode, no evento `mouseover`, carregar de forma preguiçosa (lazy-load) o conteúdo detalhado do contato dentro de um `<turbo-frame>` posicionado de forma absoluta na tela."
  },
-  {
    "id": 8,
    "title": "Busca Secundária Expansível",
    "description": "A UI principal mostra apenas o campo de busca por nome. Um link ou ícone de 'Busca Avançada' expande uma seção com filtros adicionais (email, telefone, empresa, etc.), mantendo a interface limpa e focada para o caso de uso mais comum.",
    "hotwire_example": "O link de 'Busca Avançada' pode simplesmente acionar um controller Stimulus para mostrar/esconder um `div` com os campos extras, ou pode carregar um formulário mais complexo via `<turbo-frame>`."
  },
-  {
    "id": 9,
    "title": "Animações Sutis na Adição e Remoção",
    "description": "Usar transições de CSS para que os itens deslizem suavemente para dentro e para fora da lista de selecionados. Uma animação de 'fade in' na entrada e 'fade out' na saída torna a experiência menos abrupta e mais polida.",
    "hotwire_example": "Turbo já facilita isso. As Turbo Streams disparam eventos (`turbo:before-stream-render`). Podemos usar classes de animação (ex: com Animate.css ou Tailwind UI transitions) que são adicionadas antes do elemento ser inserido ou removido, criando o efeito desejado."
  },
-  {
    "id": 10,
    "title": "Salvar Grupo com Sugestão de Nome Inteligente",
    "description": "Ao salvar a lista, se o sistema detectar que vários contatos pertencem à mesma empresa (ex: 'Foton'), ele pode pré-preencher o campo de nome do grupo com uma sugestão como 'Equipe Foton' ou 'Contatos Foton', agilizando o processo.",
    "hotwire_example": "A lógica seria no backend. Ao renderizar o formulário para salvar o grupo (que pode ser carregado num modal via `<turbo-frame>`), o controller analisaria os contatos selecionados e passaria a sugestão de nome como valor padrão para o campo de input."
  }

**Atenção:** O exemplo de implementação dos elementos está na pasta ./exemplos

---

### 🧪 Fase 3: Testes e Validações (Pendente)

**Objetivo:** Aumentar a robustez e a confiabilidade do plugin.

- [ ] **Testes Unitários (RSpec):** Validar modelos, métodos auxiliares e regras de validação.
- [ ] **Testes de Permissão:** Confirmar que cada usuário vê e acessa apenas o que tem direito.
- [ ] **Testes de Interface:** Garantir que a UI responde corretamente em desktop e mobile.
- [ ] **Testes de Resiliência:** Simular dados corrompidos, ausentes ou duplicados.

---

### 📦 Fase 4: Empacotamento e Documentação Final (Pendente)

**Objetivo:** Facilitar a adoção, o uso e a contribuição para o plugin.

- [ ] **Importação de vCard:** Detalhar e testar o processo de importação.
- [ ] **Documentação da API REST:** Documentar todos os endpoints da API, caso existam.
- [ ] **Hooks para Desenvolvedores:** Detalhar os hooks disponíveis para extensão do plugin.

---

## 📝 Backlog de Funcionalidades

### Refatorar Grupos de Contatos
- **Problema:** O modelo `ContactGroup` usa flags booleanas (`is_system`, `is_private`) que poderiam ser substituídas por um enum `group_type` mais robusto.
- **Solução Proposta:** Avaliar a substituição das flags pelo enum `group_type` (`general`, `ephemeral`).
- **Status:** Pendente.

---

## 🐞 Backlog de Bugs

### Botão de Excluir Vínculo no Modal de Edição Não Funciona
*   **Problema:** No modal de edição de um contato, o link para remover um vínculo empregatício não funciona como esperado.
*   **Comportamento Desejado:** O campo do formulário do vínculo deve ser removido visualmente da interface do modal (via Stimulus), e a exclusão do registro deve ser marcada para ocorrer apenas na submissão do formulário principal (via atributo `_destroy`).
*   **Próxima Ação / Hipótese:** Investigar a implementação do controller Stimulus responsável por essa interação, pois ele pode não estar conectado corretamente ou a lógica de remoção pode estar falhando.
