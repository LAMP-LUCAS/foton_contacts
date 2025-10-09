# Relatório Técnico: Arquitetura de Views do Foton Contacts

## 1. Visão Geral

Este documento é a fonte da verdade para a arquitetura, conceitos e diretrizes de frontend (UI/UX) do plugin **Foton Contacts**. Ele descreve a estrutura implementada e estabelece os princípios para a evolução da interface.

Para o plano de trabalho e tarefas pendentes, consulte o **[Workplan](workplan.md)**.
Para o manual de funcionalidades e histórico de desenvolvimento, consulte o **[Roadmap](ROADMAP.md)**.

---

## 2. Filosofia e Diretrizes de Design

O desenvolvimento do plugin é guiado por uma filosofia de design clara e consistente.

### 2.1. Princípios Fundamentais

1.  **Integração Nativa e Fluidez:** O plugin se comporta como uma extensão natural do Redmine. A experiência do usuário é fluida e sem atrito ao transitar entre as funcionalidades nativas e as do plugin.
2.  **Foco Absoluto em Usabilidade (UI/UX):** A usabilidade é a prioridade máxima. As interfaces são intuitivas, fáceis de usar, responsivas e acessíveis, fazendo uso extensivo de modais para operações rápidas.
3.  **Inteligência de Dados e Ação:** O plugin transforma dados brutos em insights acionáveis, oferecendo uma visão analítica que ajude o usuário a identificar inconsistências e mapear relacionamentos.
4.  **Desempenho:** O plugin é otimizado para um bom desempenho, mesmo com um grande número de contatos e relacionamentos, graças ao uso de carregamento sob demanda.
5.  **Segurança e Resiliência:** A arquitetura é robusta, validando todas as entradas de dados, respeitando as permissões do Redmine e tratando de forma elegante a ausência ou inconsistência de informações.
6.  **Qualidade de Código:** O projeto segue o padrão *Conventional Commits* e um fluxo de contribuição baseado no Git Flow simplificado.

---

## 3. Arquitetura e Stack Tecnológica

### 3.1. Arquitetura Histórica (Legado)

A arquitetura inicial foi baseada no padrão clássico do Rails com JavaScript Não Obstrutivo (UJS). Essa abordagem, que utilizava `remote: true` e respostas `js.erb` para manipular o DOM com jQuery, foi completamente substituída pela stack Hotwire.

### 3.2. Arquitetura Atual (The Hotwire Stack)

A arquitetura de frontend do plugin é baseada no framework **Hotwire (Turbo + Stimulus)**. Esta abordagem moderna minimiza a necessidade de JavaScript customizado e permite a criação de interfaces rápidas e reativas.

- **Turbo Drive & Frames:** A navegação é acelerada e a página é componentizada em `Turbo Frames`. Isso permite que partes da interface, como modais e abas, sejam carregadas e atualizadas de forma independente, sem a necessidade de um recarregamento completo da página. O carregamento sob demanda (`lazy-loading`) é usado extensivamente.
- **Turbo Streams:** As atualizações reativas da interface (criar, atualizar, deletar itens em uma lista) são realizadas via `Turbo Streams`. Em resposta a uma ação do usuário, o servidor envia pequenas instruções de alteração do DOM, que o Turbo executa no cliente. Este mecanismo substitui completamente a necessidade de arquivos `js.erb`.
- **Stimulus:** É utilizado para interações no lado do cliente que complementam o Hotwire. Seus principais usos no plugin são:
    - **Feedback de UI:** Desabilitar botões e exibir spinners durante o envio de formulários.
    - **Controle de Componentes:** Gerenciar a adição e remoção de campos em formulários dinâmicos.
    - **Wrappers de Bibliotecas:** Encapsular bibliotecas de terceiros, como o `Tom Select`, para uma integração limpa com o ecossistema Hotwire.

---

## 4. Guia de Componentes e Padrões de UX Implementados

Para manter a consistência e a alta qualidade da UI, os seguintes padrões foram implementados em todo o plugin:

1.  **Feedback Visual:** Toda ação assíncrona fornece feedback. Botões de submissão são desabilitados e exibem um spinner. Erros de validação são exibidos de forma clara, próximos aos campos problemáticos, sem fechar o modal.
2.  **Carregamento Sob Demanda (Lazy Loading):** O conteúdo de todas as abas nas páginas de detalhes é carregado sob demanda usando Turbo Frames com `loading="lazy"`, otimizando a performance inicial.
3.  **"Empty States" (Estados Vazios):** Nenhuma lista é exibida em branco. Um "estado vazio" informa ao usuário a ausência de dados e fornece um botão de ação claro para o próximo passo (ex: "Nenhum vínculo encontrado. [Adicionar Vínculo]").
4.  **Hierarquia Visual:** Formulários e páginas usam espaçamento, agrupamento de campos e tipografia para criar uma hierarquia clara e guiar o usuário.
5.  **Componentes Modernos:** Bibliotecas com dependência de jQuery foram removidas em favor de soluções modernas. O `Tom Select`, encapsulado em um controller Stimulus, é o padrão para campos de seleção com busca.

---

## 5. Fluxogramas de Interação do Usuário

Os fluxogramas abaixo ilustram as principais jornadas do usuário dentro do plugin, demonstrando a arquitetura de interação implementada.

### 5.1. Fluxo de Interação na Página da Tarefa

Este fluxo descreve a jornada do usuário ao vincular um contato a uma tarefa do Redmine.

```mermaid
graph TD
    subgraph "Jornada de Vínculo de Contato na Tarefa"
        A[Início: Visualiza uma tarefa] --> B{Seção "Contatos Vinculados"};
        B --> C[Digita no campo de busca de contatos];
        C -- Requisição (debounced) --> D[contacts#search_links];
        D -- Retorna JSON --> E[TomSelect exibe resultados];
        E --> F{Seleciona um contato};
        F -- Submit automático --> G[contact_issue_links#create];
        G -- Sucesso --> H[Turbo Stream: Adiciona card do contato na lista];
        H --> I{Contato aparece na lista com campo "Função"};
        I --> J[Clica para editar a Função];
        J --> K[Campo se torna editável (inline)];
        K -- Salva ao perder o foco (blur) --> L[contact_issue_links#update];
        L -- Sucesso --> M[Turbo Stream: Atualiza o card com a nova função];
        I --> N[Clica no botão "Remover"];
        N -- Requisição DELETE --> O[contact_issue_links#destroy];
        O -- Sucesso --> P[Turbo Stream: Remove o card da lista];
    end
```

### 5.2. Fluxo de Interação na Gestão de Contatos

Este fluxo descreve a jornada principal de gerenciamento de contatos no plugin.

```mermaid
graph TD
    subgraph "Jornada Principal"
        A[Início: Acessa a aba 'Contatos'] --> B{Lista de Contatos};
        B --> C[Clica em 'Novo Contato'];
        B --> D[Clica em 'Editar' em um contato];
        B --> E[Clica no nome de um contato];
        B --> F[Usa Filtros/Busca];
        F --> B;
    end

    subgraph "Fluxo de Criação/Edição (Modal)"
        C --> G[Abre Modal via Turbo Frame];
        D --> G;
        G -- Preenche/Altera dados --> H{Salva Formulário};
        H -- Sucesso --> I[Turbo Stream: Fecha modal e atualiza lista];
        H -- Erro de Validação --> J[Renderiza formulário com erros no mesmo modal];
        J --> G;
    end

    subgraph "Fluxo de Visualização de Detalhes"
        E --> K[Navegação para a página do Contato];
        K --> L{Aba de Detalhes};
        L -- clica em outra aba --> M[Carrega conteúdo da aba via Turbo Frame];
        M --> L;
    end

    I --> B;
```

## 6. Estrutura de Views

### 6.1. Página de Detalhes do Contato (`/contacts/{id}`)

A página de visualização de um contato é o coração do plugin e segue uma arquitetura componentizada para máximo desempenho e clareza.

- **`show.html.erb`**: É o template principal. Ele é responsável por renderizar o cabeçalho com o nome do contato, os botões de ação (Editar, Analisar, Deletar) e a estrutura de abas.

- **Controlador de Abas (`show-tabs-controller.js`)**: Um controller Stimulus gerencia a lógica de alternância entre as abas, garantindo que apenas o conteúdo da aba ativa seja exibido.

- **Partials de Abas (`/app/views/contacts/show_tabs/`)**: O conteúdo de cada aba é dividido em dois estágios para permitir o carregamento sob demanda (lazy-loading):
    1.  **Frame (`*_frame.html.erb`)**: Este é o primeiro partial carregado. Ele contém apenas um `turbo_frame_tag` com um atributo `src` que aponta para a action do controller correspondente e `loading="lazy"`. Ex: `_issues_frame.html.erb`.
    2.  **Conteúdo (`*.html.erb`)**: Este partial é carregado dinamicamente pelo Turbo Frame quando a aba se torna visível. Ele contém a lógica real para buscar e exibir os dados. Ex: `_issues.html.erb`.

- **Listagem de Tarefas (`/app/views/issues/_issue_list.html.erb`)**: Para manter a consistência e a reutilização, a lista de tarefas vinculadas a um contato é renderizada por um partial dedicado. Este partial (`_issue_list.html.erb`) recebe a coleção de issues e as exibe em um formato de tabela padronizado, similar à lista de tarefas nativa do Redmine.

O fluxograma de renderização da aba de tarefas é o seguinte:

```mermaid
graph TD
    A[Request: `/contacts/123`] --> B[contacts#show];
    B --> C[Renderiza `show.html.erb`];
    C --> D[Renderiza `_issues_frame.html.erb` para a aba de tarefas];
    D -- Turbo Frame (lazy) --> E{Request: `/contacts/123/tasks`};
    E --> F[contacts#tasks];
    F -- `@issues = @contact.issues.visible` --> G[Busca issues];
    G --> H[Renderiza `_issues.html.erb`];
    H -- `@issues.present?` --> I[Renderiza `_issue_list.html.erb`];
    I --> J[Exibe a lista de tarefas];
```

### 6.2. Arquitetura do Dashboard de BI (Monolito-Modular)

Para o Dashboard de BI, evoluímos o padrão de renderização para uma arquitetura de três estágios que chamamos de "Monolito-Modular". O objetivo é aumentar a reutilização de componentes de UI, permitindo que widgets de análise (como tabelas e gráficos) possam ser usados tanto no dashboard principal quanto em outras áreas, como modais de detalhe.

- **Estágio 1: Frame da Aba (`tabs/_*_frame.html.erb`)**: Similar ao padrão anterior, esta partial renderiza um único `turbo_frame_tag` que ocupa toda a área da aba e aponta para uma action de "layout de aba" (ex: `overview_tab_analytics_path`).

- **Estágio 2: Layout da Aba (`tabs/_*.html.erb`)**: Esta é a nova camada, o "Monolito". É uma partial que define a estrutura de layout da aba (ex: um grid de colunas 8/4). Sua responsabilidade é renderizar os vários "componentes" modulares que compõem a aba, passando os dados necessários para cada um.

- **Estágio 3: Componentes (`components/_*.html.erb`)**: Estas são as partials finais, focadas e reutilizáveis. Cada uma renderiza um único elemento de UI (uma tabela, um gráfico, um card de KPI) e não tem conhecimento do layout geral da aba. Elas recebem todos os dados via `locals`.

O fluxograma para a aba "Visão Geral" ilustra este padrão:

```mermaid
graph TD
    subgraph "Fluxo de Renderização - Monolito-Modular"
        A[Request: /analytics?tab=overview] --> B[AnalyticsController#index];
        B --> C[Renderiza a view principal<br/>`analytics/index.html.erb`];
        C --> D[Renderiza a partial de frame<br/>`tabs/_overview_frame.html.erb`];
        D -- "Frame visível, Turbo dispara requisição" --> E[Request: /analytics/overview_tab];
        E --> F[AnalyticsController#overview_tab];
        F -- "Busca dados para IRPA, Qualidade, etc." --> G[Renderiza o layout da aba<br/>`tabs/_overview.html.erb`];
        G -- "Layout da aba renderiza seus componentes" --> H["Renderiza `components/_irpa_table.html.erb`"];
        G -- "Layout da aba renderiza seus componentes" --> I["Renderiza `components/_data_quality.html.erb`"];
        H & I --> J[HTML completo da aba é montado];
        J --> K[Resposta HTML é inserida no frame `overview_tab_content`];
    end
```

### 6.2. Integração com a Página de Tarefas (`/issues/{id}`)

A funcionalidade mais importante do plugin é a sua capacidade de se integrar diretamente à página de visualização de uma tarefa do Redmine, fornecendo contexto sobre os stakeholders.

- **Ponto de Entrada (`ViewsLayoutsHook`)**: O plugin utiliza um hook do Redmine, `view_issues_show_details_bottom`, para injetar seu conteúdo na página da tarefa. Este hook é responsável por renderizar o partial principal da funcionalidade.

- **Partial Principal (`_foton_contacts_section.html.erb`)**: Este é o contêiner para toda a UI de contatos na tarefa. Ele contém:
    - A lista de contatos e grupos já vinculados.
    - O formulário de busca para adicionar novos vínculos.

- **Componente de Busca (`contact_search_controller.js`)**: Um controller Stimulus, em conjunto com a biblioteca `Tom Select`, transforma um simples campo de texto em uma poderosa ferramenta de busca. Ele se conecta a um endpoint dedicado (`contacts#search_links`) que retorna contatos e grupos, e submete o formulário de adição automaticamente ao selecionar um item.

- **Exibição dos Vínculos (`_contact_issue_link.html.erb`)**: Cada contato ou grupo vinculado é renderizado como um "card" individual. Este partial é projetado para ser autocontido e reativo:
    - **Remoção Instantânea**: O botão de remover utiliza `data-turbo-method="delete"` para desvincular o contato instantaneamente, com a remoção do card da UI sendo gerenciada por uma resposta `turbo_stream.remove`.
    - **Edição Inline da Função**: O campo "Função" é gerenciado por um controller Stimulus (`inline_edit_controller.js`). Ao ser focado, ele salva o valor original. Ao perder o foco (`blur`), ele compara o valor novo com o original e, se houver mudança, dispara uma requisição `PATCH` para o `ContactIssueLinksController#update`. A UI é atualizada via Turbo Stream, fornecendo uma experiência de edição fluida e sem recarregamento.

---

## 7. Gestão de Navegação (Link Helper)

Para garantir uma experiência de usuário consistente e previsível, especialmente na transição entre as páginas aceleradas por Hotwire do plugin e as páginas tradicionais do Redmine, o plugin implementa uma estratégia de gerenciamento de links no lado do servidor.

### 7.1. Propósito

O objetivo é evitar comportamentos inesperados do Turbo Drive, onde uma página nativa do Redmine poderia ser carregada dentro de um contexto do plugin, quebrando a navegação e a UI. A abordagem garante que a navegação entre páginas de "contexto diferente" sempre funcione de forma robusta, mesmo que isso signifique abrir mão da aceleração do Turbo Drive em alguns casos.

### 7.2. Arquitetura: Sobrescrita do `link_to` Helper

A solução é implementada no `app/helpers/foton_contacts_link_helper.rb`. Este helper sobrescreve o `link_to` padrão do Rails com uma lógica específica:

1.  **Verificação de Intenção:** O helper primeiro verifica se o link já possui uma ação Turbo explícita definida em seus `data` attributes (ex: `data-turbo-frame`, `data-turbo-method`).

2.  **Aplicação do Padrão:** Se nenhuma ação Turbo for encontrada, o helper assume que se trata de um link de navegação padrão (ex: um link para outra página do plugin, para uma issue ou para um projeto). Nesse caso, ele **injeta automaticamente o atributo `data-turbo="false"`** no link.

3.  **Preservação da Interatividade:** Links que já utilizam a stack Hotwire para interatividade (como abrir modais, submeter formulários ou executar ações via `turbo_method`) são deixados intactos, permitindo que funcionem conforme o esperado.

### 7.3. Resultado Prático

-   **Navegação Segura:** Todos os links que levam a uma página inteiramente nova (seja dentro do plugin ou para o Redmine nativo) forçam um recarregamento completo. Isso garante que a página de destino seja renderizada corretamente, com seus próprios assets e layout, eliminando qualquer conflito.
-   **Experiência Interativa Mantida:** A rica interatividade dentro das páginas do plugin (modais, atualizações via Turbo Streams, etc.) não é afetada.
-   **Simplicidade:** Esta abordagem centraliza a lógica no servidor, eliminando a necessidade de um "porteiro" complexo em JavaScript no lado do cliente. É uma solução robusta e de fácil manutenção, alinhada com a filosofia "HTML-over-the-wire".