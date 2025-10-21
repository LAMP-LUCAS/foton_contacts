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

## ✅ Verificação de compatibilidade do Workplan com o código atual

Esta seção documenta o resultado da verificação do conteúdo deste documento (`workplan.md`) em relação ao código atualmente presente no repositório do plugin. A checagem foi realizada lendo controladores, serviços, modelos, migrations e serializers mencionados neste plano.

Resumo rápido:

- A maioria dos itens das Fases 1 a 3 (arquitetura de BI, controllers, services principais, import/export, journaling e refatoração do modelo de contatos) está implementada no código.
- Itens pontuais de ajuste e pequenas lacunas (listadas abaixo) permanecem pendentes ou requerem alinhamento com as diretrizes do workplan.

Mapeamento por área (status, arquivos relevantes e observações):

- Analytics / BI — Status: CONCLUÍDO / PRESENTE
    - Arquivo controller: `app/controllers/analytics_controller.rb` (actions: `index`, `overview_tab`, `team_performance_tab`, `workload_tab`, `workload_results`, `contact_details`, `irpa_trend`, `dynamic_dashboard`, etc.)
    - Services lidos: `app/services/analytics/irpa_calculator.rb`, `team_scorecard_query.rb`, `workload_query.rb`, `historical_state_query.rb`, `data_quality_query.rb`, `partner_analysis_query.rb`.
    - Observação: a infraestrutura de widgets, frames e partials existe sob `app/views/analytics/`.

- IRPA (`Analytics::IrpaCalculator`) — Status: PRESENTE, AÇÕES PENDENTES
    - Arquivo: `app/services/analytics/irpa_calculator.rb`
    - Observação: implementa TAH, IR, FCP e Instability. Contudo, o workplan solicita duas mudanças de comportamento:
        1. Alterar `calculate_fcp` para retornar contagem de tarefas críticas (prioridade Alta/Urgente) — atualmente `calculate_fcp` retorna a média das posições de prioridade.
        2. Incluir no hash de retorno o campo bruto `instability_change_count` além do `instability_factor` — atualmente só é retornado `instability_factor`.
    - Recomendação: ajustar `calculate_fcp` e adicionar `instability_change_count` ao hash de retorno; atualizar views se necessário.

- TeamScorecard / ICE — Status: CONCLUÍDO
    - Arquivo: `app/services/analytics/team_scorecard_query.rb`
    - Observação: cálculo de ICE usa `Journal` e eventos `Created` / `Destroyed` conforme o workplan.

- Workload & check_workload — Status: CONCLUÍDO
    - Arquivos: `app/services/analytics/workload_query.rb`, `app/services/analytics/workload_checker_service.rb`, `app/controllers/contacts_controller.rb` (action `check_workload`), rotas em `config/routes.rb`.

- Journaling (ActsAsJournalizedConcern) — Status: CONCLUÍDO
    - Arquivo: `lib/acts_as_journalized_concern.rb`
    - Observação: inclui callbacks `after_create`, `after_destroy`, `after_save` e suporta `acts_as_journalized watch: [...]` nos modelos.

- Modelo de dados `FotonContact` e detalhes (phones/emails/addresses) — Status: CONCLUÍDO
    - Arquivos: `app/models/foton_contact.rb`, `app/models/foton_contact_email.rb`, `app/models/foton_contact_phone.rb`, `app/models/foton_contact_address.rb` e migration principal `db/migrate/001_init_foton_contacts_schema.rb`.
    - Observação: `FotonContact` implementa `has_many` e `accepts_nested_attributes_for` e métodos delegados `email`, `phone`, `address` para compatibilidade.

- Import / Export — Status: CONCLUÍDO
    - Arquivos: `app/services/contacts/import_service.rb`, `app/services/contacts/importers/vcard_mapper.rb`, `app/services/contacts/importers/google_csv_mapper.rb`, `app/services/contacts/export_service.rb`, `app/services/contacts/exporters/csv_serializer.rb`, `app/services/contacts/exporters/vcard_serializer.rb`.
    - Controller: `app/controllers/contacts_controller.rb` (`import`, `export` actions presentes).

- Data Quality / Merge — Status: PARCIAL
    - Arquivo de merge: `app/services/contacts/merge_service.rb` presente e implementa reassociação/transação.
    - Observação: o serviço `Analytics::DuplicateFinderService` nomeado no workplan não foi encontrado pelo nome exato — pode ainda não existir ou estar implementado com outro nome. A infraestrutura (imported_contacts, data_quality routes) existe.

Principais divergências / pendências detectadas (priorizadas):

1. `Analytics::IrpaCalculator` — alteração do FCP (Fator de Criticidade) e inclusão de `instability_change_count` no retorno (ver `app/services/analytics/irpa_calculator.rb`).
     - Impacto: atual views e visualizações do modal analytics esperam campos com nomes/formatos atuais. Se alterarmos o formato de retorno, atualizar `_analytics_modal.html.erb` para exibir o valor e o label (ex.: "Tarefas Críticas Abertas").

2. `Analytics::DuplicateFinderService` — não foi encontrado com esse nome.
     - Observação: workplan lista a criação deste serviço; o `merge_service.rb` existe. Recomenda-se implementar (ou documentar o nome existente) para o módulo Data Quality.

3. Frontend: controller `contact-filter-observer-controller.js` (workplan menciona refatoração) — marcado como pendente no workplan e não verificado aqui (requer investigação no diretório `assets/javascripts` / `app/javascript`).

4. UI/CSS e testes visuais: As alterações de estilo e auditoria de `contacts.css` e grid foram aplicadas parcialmente (assets `bootstrap.min.css`, `contacts.css` estão presentes), porém validação visual completa deve ser feita em navegador. Também há um bug JS intermitente documentado no backlog.

Checks executados / arquivos lidos (amostra):

- `app/controllers/analytics_controller.rb`
- `app/services/analytics/irpa_calculator.rb`
- `app/services/analytics/team_scorecard_query.rb`
- `app/services/analytics/workload_query.rb`
- `app/services/analytics/historical_state_query.rb`
- `app/models/foton_contact.rb`
- `lib/acts_as_journalized_concern.rb`
- `app/services/contacts/import_service.rb`
- `app/services/contacts/importers/vcard_mapper.rb`
- `app/services/contacts/importers/google_csv_mapper.rb`
- `app/services/contacts/export_service.rb`
- `app/services/contacts/exporters/csv_serializer.rb`
- `app/services/contacts/merge_service.rb`
- `db/migrate/001_init_foton_contacts_schema.rb`

Recomendações imediatas (ações concretas):

- Implementar a mudança no `IrpaCalculator#calculate_fcp` para retornar a contagem de tarefas críticas (prioridades definidas) e adicionar `instability_change_count` ao hash retornado. Arquivo: `app/services/analytics/irpa_calculator.rb`.
- Verificar se existe um serviço de detecção de duplicatas com outro nome; caso contrário, implementar `Analytics::DuplicateFinderService` usando `imported_contacts`, e-mail exato e `pg_trgm` para fuzzy search. Arquivo sugerido: `app/services/analytics/duplicate_finder_service.rb`.
- Rodar a suíte de testes do plugin (rake test) e ajustar os testes que esperam os antigos formatos de métricas.
- Testes manuais: validar visualmente o dashboard de BI com navegação via Turbo Drive para reproduzir o erro `Cannot read properties of undefined (reading 'start')` e adicionar guards nos scripts JS que inicializam gráficos.

Se preferir, implemento agora as alterações no `IrpaCalculator` (mudança de FCP + inclusion de instability_change_count) e adapto as views mínimas necessárias. Caso queira, também posso criar um esqueleto para `Analytics::DuplicateFinderService`.

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

### ✅ Fase 2: Vínculo de Contatos e Grupos às Issues (Concluída)

**Objetivo:** Implementar a capacidade de associar contatos e grupos diretamente a uma issue do Redmine, fornecendo contexto sobre os stakeholders de cada tarefa.

**Resultados:**
- **Modelo de Dados:** Foi criada a tabela `contact_issue_links` e o modelo `ContactIssueLink` para estabelecer a relação N-N entre contatos/grupos e issues. Os modelos `Issue`, `Contact` e `ContactGroup` foram estendidos (via patches) para refletir essas associações.
- **Integração com a Issue:** Utilizando um hook do Redmine (`view_issues_show_details_bottom`), uma nova seção "Contatos Vinculados" foi injetada na página da issue.
- **Interface Reativa:** A seção é totalmente gerenciada via Hotwire. A adição e remoção de vínculos são instantâneas e não recarregam a página, utilizando `Turbo Streams` para atualizar a UI.
- **Busca Inteligente:** Um campo de busca com `Tom Select` permite encontrar e adicionar contatos ou grupos de forma eficiente, consultando um endpoint JSON dedicado.
- **Experiência de Usuário Aprimorada:** A exibição dos vínculos evoluiu de simples "pílulas" para "cards" informativos. Foi implementada a edição "inline" do campo "Função" (`role`) com salvamento automático (via Stimulus), proporcionando uma UX fluida e rica em contexto, conforme idealizado nos mockups.

---

### 🚀 Fase 3: Business Intelligence e Análises Avançadas (Em Andamento)

**Status Atual:** A arquitetura de backend e frontend para os dashboards de BI foi implementada. Os cálculos principais estão funcionais e as visualizações de dados (tabelas, gráficos) estão sendo renderizadas. O foco atual está no refinamento da UI e na validação completa dos dados apresentados.

**Objetivo:** Transformar os dados do Foton Contacts em inteligência acionável. Esta fase foca em desenvolver dashboards, análises preditivas e relatórios visuais para que gestores possam tomar decisões mais informadas, mitigar riscos e otimizar a alocação de recursos, implementando a visão descrita em `@exemplos/BDD_analises.md` e `@exemplos/bi_analysis_guide.md`.

#### 🧠 Arquitetura e Princípios

A implementação seguirá rigorosamente as diretrizes de `@docs/concepts.md` e `@docs/views_architecture.md`.

-   **Backend (O Cérebro):**
    -   **Cálculos em Service Objects/Query Objects:** A lógica complexa para as métricas de BI (IRPA, TAH, etc.) será encapsulada em classes de serviço (ex: `Analytics::IrpaCalculatorService`) ou objetos de query. Isso mantém os controllers e modelos limpos e facilita os testes.
    -   **Endpoints Dedicados:** Um novo controller, `AnalyticsController`, será o responsável por orquestrar a coleta de dados e responder às requisições dos dashboards.
    -   **Performance:** As queries serão otimizadas para lidar com grandes volumes de dados, utilizando `eager loading` e, se necessário, agregações diretas no banco de dados.

-   **Frontend (A Experiência):**
    -   **Dashboards com Hotwire:** As páginas de análise serão construídas com a stack Hotwire. Cada widget do dashboard (gráfico, tabela, KPI) será um `Turbo Frame` independente com carregamento `lazy`. Isso garante que a página principal carregue rapidamente e os dados sejam buscados sob demanda.
    -   **Gráficos com Stimulus:** A integração com bibliotecas de gráficos (ex: Chart.js, ApexCharts) será feita através de controllers Stimulus. O Rails fornecerá os dados via JSON, e o Stimulus cuidará de renderizar e atualizar os gráficos, criando uma experiência interativa.

#### 🗺️ Etapas Detalhadas de Implementação

1.  **Fundação da Arquitetura de BI (Backend)**
    -   [x] **1.1. Criar `AnalyticsController`:** Definir as actions principais (`index`, `team_performance`, `workload`, etc.) e as rotas correspondentes em `config/routes.rb`.
    -   [x] **1.2. Implementar os Cálculos de Métricas:**
        -   [x] Criar `Service/Query Objects` para cada análise principal descrita no `bi_analysis_guide.md`:
            -   `Analytics::IrpaCalculator` para o **Índice de Risco Preditivo de Alocação (IRPA)**.
            -   `Analytics::TeamScorecardQuery` para o **Painel de Performance da Equipa**.
                - [x] Refatorar o cálculo do Índice de Coesão (ICE) para usar o histórico do `Journal`.
            -   [x] `Analytics::WorkloadQuery` para o **Mapa de Calor da Carga de Trabalho**.
            -   `Analytics::DataQualityMonitor` para a **Saúde dos Dados**.
    -   [x] **1.3. Configuração de Carga Horária:** Adicionar os campos para configuração da carga horária global e por contato, conforme especificado no guia de BI.

2.  **Dashboard Principal e Análise de Risco (Cenários BDD 1 e 2)**
    -   [xx] **2.1. View do Dashboard Principal:** Criar a view `app/views/analytics/index.html.erb` com uma estrutura de abas (`Visão Geral`, `Análise de Equipes`, `Carga de Trabalho`).
    -   [x] **2.2. Widgets com Lazy Loading:** Na aba "Visão Geral", criar os partials para cada widget (`_irpa_widget.html.erb`, `_data_quality_widget.html.erb`, etc.), cada um dentro de um `turbo_frame_tag` com `loading: :lazy`.
    -   [x] **2.3. Tabela de Risco (IRPA):** Implementar a tabela de contatos de maior risco. Cada linha terá um link para a análise detalhada.
    -   [x] **2.4. Modal de Análise Individual (Drill-Down):** O clique no nome de um contato na tabela de risco abrirá um modal (`_contact_analysis_modal.html.erb`) via Turbo Frame, exibindo o score IRPA, os KPIs detalhados e o histórico do contato.

3.  **Dashboard Dinâmico na Lista de Contatos (Cenário BDD 3)**
    -   [x] **3.1. Modificar a View `contacts/index` para incluir o frame do dashboard**
    -   [ ] **3.2. Refatorar e Implementar `contact-filter-observer-controller.js`:**
        - [ ] Refatorar o controller para usar o padrão IIFE + `window.ControllerName`.
        - [ ] Implementar a lógica para atualizar o `src` do frame do dashboard com os parâmetros de filtro.

4.  **Análise Comparativa de Equipes (Cenário BDD 4)**
    -   [x] **4.1. View de Análise de Equipes:** Criar a view/partial para a aba "Análise de Equipes".
    -   [x] **4.2. Integrar Gráfico de Radar:** Desenvolver um controller Stimulus (`chart-controller.js`) que recebe os dados do `TeamScorecardQuery` e renderiza o Gráfico de Radar para comparação visual das equipes.
    -   [x] **4.3. Ranking de Equipes:** Exibir a tabela de "Ranking de Equipes" ao lado do gráfico.

5.  **Mapa de Carga de Trabalho e Alerta Proativo (Cenário BDD 5)**
    -   [x] **5.1. View do Mapa de Calor:** A view para a aba "Carga de Trabalho" renderiza o heatmap. A UI permite filtrar por período, projeto, e alternar entre horas estimadas e lançadas.
    -   [x] **5.2. Lógica do Heatmap:** O backend, usando a `WorkloadQuery`, calcula a matriz de `[contato, dia]` com a porcentagem de alocação, que é usada para colorir as células da tabela.
    -   [x] **5.3. Implementar Alerta de Sobrecarga (Real-Time):**
        -   [x] **Backend:** Criar o endpoint `POST /contacts/check_workload` que recebe `contact_id`, `start_date`, `due_date`, `estimated_hours` e retorna um status de `ok` ou `overload`.
        -   [x] **Frontend:** Na página da issue, um controller Stimulus interceptará a adição de um contato. Antes de salvar, ele fará um `fetch` para o endpoint `check_workload`. Se a resposta for `overload`, ele exibirá um `window.confirm()` com o alerta, permitindo que o gestor decida se continua ou não.

---

### Fase 3.1: Refatoração da UI e Implementação dos Componentes

**Objetivo:** Refatorar a UI do dashboard de BI para uma arquitetura "Monolito-Modular", alinhando o design com o mockup e permitindo a reutilização de componentes em outras áreas, como o modal de análise individual.

**Arquitetura Alvo:**
1.  **Frame da Aba (`tabs/_*_frame.html.erb`):** Responsável por carregar o conteúdo completo de uma aba via `src` de forma assíncrona.
2.  **Layout da Aba (`tabs/_*.html.erb`):** Define a estrutura de grid (colunas) da aba e renderiza os componentes, passando os dados necessários.
3.  **Componentes (`components/_*.html.erb`):** Partials focadas e reutilizáveis que renderizam um único elemento de UI (tabela, gráfico, card de KPI, etc.).

---

#### Plano de Implementação por Aba

##### **Aba "Visão Geral" (`overview_tab`)**

- [x] **Estrutura Base:** Criar a rota, action (`overview_tab`), frame e a partial de layout (`_overview.html.erb`).
- [x] **Componente `_irpa_table.html.erb`:** Mover a lógica da tabela IRPA para um componente modular em `app/views/analytics/components/`.
- [x] **Componente `_data_quality.html.erb` (Novo):**
    - [x] Criar a partial do componente para o "Monitor de Qualidade dos Dados".
    - [x] Implementar a lógica no `AnalyticsController#overview_tab` para buscar as métricas de qualidade.
    - [x] Renderizar as métricas com barras de progresso no componente, dentro de um card.
- [x] **Componente `_partner_analysis.html.erb` (Novo):**
    - [x] Criar a partial do componente para a "Análise de Empresas Parceiras".
    - [x] Implementar a lógica no `AnalyticsController#overview_tab` para buscar os dados das empresas.
    - [x] Integrar o Gráfico de Bolhas (Bubble Chart) no componente, dentro de um card.
- [ ] **Estilo:** Aplicar o layout de colunas (`col-md-8` / `col-md-4`) e o estilo de "card" do mockup na partial de layout `_overview.html.erb`.

##### **Aba "Análise de Equipes" (`team_performance_tab`)**

- [x] **Estrutura Base:** Criar a action `team_performance_tab` e a partial de layout `tabs/_team_performance.html.erb`.
- [x] **Refatorar Frame:** Atualizar `tabs/_team_performance_frame.html.erb` para carregar a nova rota.
- [x] **Componente `_team_radar_chart.html.erb` (Novo):**
    - [x] Mover a lógica do Gráfico de Radar da antiga partial de widget para este novo componente.
- [x] **Componente `_team_ranking_table.html.erb` (Novo):**
    - [x] Mover a lógica da Tabela de Ranking para este novo componente.
- [x] **Layout da Aba:** Renderizar os componentes de gráfico e tabela em uma estrutura de colunas (`col-md-7` / `col-md-5`) com cards, conforme o mockup.
- [x] **Cleanup:** Remover a action `team_performance` e a view `widgets/_team_performance.html.erb`.

##### **Aba "Carga de Trabalho" (`workload_tab`)**

- [x] **Estrutura Base:** Criar a action `workload_tab` e a partial de layout `tabs/_workload.html.erb`.
- [x] **Refatorar Frame:** Atualizar `tabs/_workload_frame.html.erb` para carregar a nova rota.
- [x] **Componente `_workload_heatmap.html.erb` (Novo):**
    - [x] Mover a lógica da tabela de Mapa de Calor para este novo componente.
- [x] **Componente `_workload_filters.html.erb` (Novo):**
    - [x] Criar um componente dedicado para os filtros avançados (nome, projeto, tipo de análise, período).
- [x] **Layout da Aba:** Renderizar os filtros e o heatmap dentro de um único card, conforme o mockup.
- [x] **Cleanup:** Remover a action `workload` e a view `widgets/_workload.html.erb`.

---

### Fase 3.2: Alinhamento Visual do Dashboard

**Objetivo:** Substituir o estilo padrão do Redmine pela identidade visual moderna (Bootstrap 5) definida no `mockup_Analises.html`. O foco é alinhar componentes como tabelas, cards e badges para criar uma experiência de usuário mais limpa e profissional.

- [x] **Componentes Gerais:**
    - [x] Substituir `<div class="box">` por `<div class="card">` com os cabeçalhos (`card-header`) e corpos (`card-body`) corretos.
    - [x] Substituir `<table class="list">` por `<table class="table table-hover">` para um visual mais limpo.
- [x] **Tabela de Ranking:**
    - [x] Aplicar badges com cores (`bg-success`, `bg-warning`) para o score e a posição no ranking, conforme o mockup.
- [x] **Mapa de Calor:**
    - [x] Criar classes CSS específicas (`workload-low`, `workload-medium`, `workload-high`, `workload-overload`) para as células do heatmap, replicando a paleta de cores do mockup.

---

### ✅ Fase 3.3: Fundamentação Histórica para BI com Journaling Avançado (Concluída)

**Objetivo:** Habilitar análises de BI baseadas em tendências e na evolução dos dados ao longo do tempo. Para isso, é necessário estender o sistema de journaling para capturar não apenas as alterações nos contatos, mas também os eventos de criação e destruição de relacionamentos-chave.

- [x] **1. Evoluir o `ActsAsJournalizedConcern`:**
    - [x] Adicionar suporte para callbacks de `after_create` e `after_destroy`.
    - [x] Renomear o callback de `after_save` para `create_update_journal_entry` para maior clareza.
    - [x] Implementar os novos métodos `create_creation_journal_entry` e `create_destruction_journal_entry` para registrar esses eventos no histórico com uma nota clara (ex: "Created", "Destroyed").

- [x] **2. Habilitar Journaling para Vínculos Empregatícios:**
    - [x] Incluir o `ActsAsJournalizedConcern` no modelo `ContactEmployment`.
    - [x] Configurar o `acts_as_journalized` para monitorar (`watch`) as alterações nos campos `start_date`, `end_date` e `position`.

- [x] **3. Habilitar Journaling para Grupos:**
    - [x] Incluir o `ActsAsJournalizedConcern` no modelo `ContactGroupMembership`.
    - [x] Configurar o `acts_as_journalized` sem a opção `watch`, pois o interesse principal é registrar a entrada e saída de membros (eventos de criação e destruição).

---

### Fase 3.4: Aplicação do Journaling nas Análises de BI

**Objetivo:** Utilizar a base de journaling histórico para aprimorar as métricas de BI existentes, tornando-as mais precisas e permitindo análises de tendências ao longo do tempo.

- [x] **Refatorar Análise de Parceiros (`PartnerAnalysisQuery`):**
    - [x] Substituir o cálculo de turnover por uma métrica real baseada nos eventos de criação e destruição de `ContactEmployment`.
    - [x] Habilitar a análise temporal com filtros de data na interface.
    - [x] Refatorar a query para usar o novo serviço `HistoricalStateQuery`, simplificando o código.
- [x] **Refatorar Painel de Performance da Equipe (`TeamScorecardQuery`):**
    - [x] Substituir o cálculo de coesão (ICE) por uma métrica real baseada na duração da permanência dos membros nos grupos.
- [x] **Aprimorar Análise de Risco (`IrpaCalculator`):**
    - [x] Criar uma nova métrica de "Instabilidade do Contato" baseada na frequência de alterações de status ou projeto no `Journal`.
    - [x] Exibir o "Fator de Instabilidade" no modal de detalhes do contato, com visualização em barra de progresso.
    - [ ] Habilitar a análise da evolução do `risk_score` de um contato ao longo do tempo.
- [x] **Criar Serviço de Snapshot Histórico (`Analytics::HistoricalStateQuery`):**
    - [x] Desenvolver um serviço que possa reconstruir o estado de um conjunto de dados em uma data específica no passado, permitindo análises "point-in-time".

---

### 🚀 Fase 4: Refatoração e Padronização da Estilização (CSS) (Planejada)

**Objetivo:** Alinhar todo o plugin com a arquitetura de estilização híbrida (Bootstrap + CSS Grid) definida no `views_architecture.md`, garantindo consistência visual, manutenibilidade e conformidade com a filosofia de autohospedagem.

#### 🗺️ Etapas Detalhadas

1.  **Bundling de Dependências (Autohospedagem)**
    -   [x] **1.1. Download e Integração do Bootstrap:** Baixar os arquivos CSS e JS do Bootstrap 5 e configurá-los para serem servidos pelo asset pipeline do plugin.
    -   [x] **1.2. Verificação e Remoção de CDNs:** Substituir todas as chamadas de CDN para o Bootstrap nos layouts e views pelos helpers de asset do Rails (`stylesheet_link_tag`, `javascript_include_tag`).

2.  **Correção e Limpeza do CSS**
    -   [x] **2.1. Auditoria de `contacts.css`:** Mapear e remover regras de CSS que conflitam com o Bootstrap, como a aplicação de `display: grid` em classes `.col-md-*`.
    -   [x] **2.2. Implementação do Novo Grid:** Adicionar as novas classes de contêiner de grid (`.analytics-grid-container`, etc.) ao `contacts.css`, conforme especificado na arquitetura.

3.  **Refatoração das Views do Dashboard de BI**
    -   [x] **3.1. Aplicar Grid na "Visão Geral":** Refatorar a partial `_overview.html.erb` para usar a nova estrutura de `divs` com as classes de CSS Grid, posicionando os `turbo_frame`s corretamente.
    -   [x] **3.2. Aplicar Grid na "Análise de Equipes":** Fazer o mesmo para a partial `_team_performance.html.erb`.
    -   [x] **3.3. Teste de Responsividade:** Validar que os novos layouts de grid se ajustam corretamente para uma única coluna em telas menores.

4.  **Revisão Geral de Consistência**
    -   [ ] **4.1. Auditoria de Componentes:** Revisar os principais componentes da UI (filtros, tabelas, modais) para garantir o uso consistente das classes do Bootstrap.

#### ✅ Critérios de Aceite

- O plugin carrega o Bootstrap 5 exclusivamente a partir de seus próprios assets, sem requisições a CDNs.
- O layout do Dashboard de BI é totalmente controlado pelo novo sistema de CSS Grid e é responsivo.
- O arquivo `contacts.css` não contém mais CSS que conflita com o framework Bootstrap.
- Todas as páginas do plugin mantêm a consistência visual.

---

### 🚀 Fase 5: Refatoração do Modelo de Dados (Planejada)

**Objetivo:** Refatorar o modelo de dados de contatos para uma estrutura normalizada, permitindo que cada contato tenha múltiplos telefones, e-mails e endereços. Isso aumentará a flexibilidade e a robustez do plugin, alinhando-o com as melhores práticas de design de banco de dados.

**Arquitetura Alvo:**
*   **Tabela Principal `foton_contacts`:** Conterá apenas informações intrínsecas ao contato (nome, tipo, status, etc.).
*   **Tabelas Satélite:**
    *   `foton_contact_phones`: Armazenará uma lista de números de telefone associados a um contato.
    *   `foton_contact_emails`: Armazenará uma lista de endereços de e-mail.
    *   `foton_contact_addresses`: Armazenará uma lista de endereços físicos.
*   **Camada de Abstração (Porta de Desacoplamento):** Para garantir uma migração suave e evitar quebrar o plugin, o modelo `FotonContact` terá métodos delegados temporários (ex: `phone`, `email`) que buscarão o registro primário nas novas tabelas. Isso permite que a UI seja atualizada de forma incremental, funcionando como uma porta de desacoplamento entre a nova estrutura de dados e o código legado.

---

#### 🗺️ Etapas Detalhadas de Implementação

1.  **Criação da Nova Estrutura (Migrations)**
    *   [x] **1.1. Criar Migration para Novas Tabelas:** Criar um novo arquivo de migração (`db/migrate/XXX_create_foton_contact_details.rb`) para adicionar as tabelas `foton_contact_phones`, `foton_contact_emails` e `foton_contact_addresses`. (As tabelas foram definidas em `001_init_foton_contacts_schema.rb`)
    *   [x] **1.2. Criar Migration para Renomear Tabela Principal:** Criar uma migração (`db/migrate/XXX_rename_contacts_to_foton_contacts.rb`) para renomear a tabela `contacts` para `foton_contacts` e atualizar suas referências em outras tabelas (`contact_group_memberships`, `contact_issue_links`, `contact_employments`). (A tabela `foton_contacts` é criada diretamente e as chaves estrangeiras foram atualizadas em `001_init_foton_contacts_schema.rb`)
    *   [x] **1.3. Criar Novos Modelos:** Criar os arquivos de modelo `app/models/foton_contact_phone.rb`, `app/models/foton_contact_email.rb`, e `app/models/foton_contact_address.rb` com suas respectivas validações e associações.

2.  **Migração de Dados e Transição**
    *   [x] **2.1. Renomear Modelo Principal:** Renomear `app/models/contact.rb` para `app/models/foton_contact.rb` e a classe para `FotonContact`. Atualizar todas as referências no código.
    *   [x] **2.2. Atualizar Associações:** No novo `foton_contact.rb`, adicionar as associações `has_many` para `phones`, `emails`, e `addresses`, e configurar `accepts_nested_attributes_for`.
    *   [x] **2.3. Implementar Camada de Abstração:**
        *   No modelo `FotonContact`, criar métodos delegados como `phone`, `email`, `address` que retornam o valor do registro primário (`is_primary: true`) das novas tabelas.
        *   **Exemplo:** `def phone; phones.find_by(is_primary: true)&.number || phones.first&.number; end`.
        *   Isso manterá a compatibilidade com as views e controllers existentes durante a refatoração.
    *   [x] **2.4. Criar Migration de Dados:** Criar uma migração de dados (`db/migrate/XXX_migrate_contact_data.rb`) que:
        *   Itera sobre todos os registros da tabela `foton_contacts`.
        *   Para cada contato, cria um novo registro em `foton_contact_phones` com o valor do campo `phone` antigo, marcando-o como primário.
        *   Faz o mesmo para `email` e `address`. (Não necessário para um plugin novo sem dados existentes)
    *   [x] **2.5. Criar Migration para Remover Colunas Antigas:** Após a migração de dados ser bem-sucedida e testada, criar uma migração (`db/migrate/XXX_remove_old_columns_from_foton_contacts.rb`) para remover as colunas `phone`, `email`, e `address` da tabela `foton_contacts`. (Não necessário para um plugin novo, pois a tabela `foton_contacts` já é criada sem essas colunas)

3.  **Refatoração da Interface e Lógica de Negócio (Incremental)**
    *   [x] **3.1. Atualizar `contacts_controller.rb`:**
        *   Modificar `strong_params` para aceitar os atributos aninhados (`phones_attributes`, `emails_attributes`, etc.).
        *   Atualizar as actions `create` e `update`.
    *   [x] **3.2. Refatorar Formulários (`_form.html.erb`):**
        *   Substituir os campos de texto simples para `phone`, `email`, e `address` por um sistema de campos aninhados (nested forms), usando Stimulus (como o `nested_form_controller.js` já existente) para adicionar/remover dinamicamente múltiplos registros.
    *   [x] **3.3. Refatorar Views de Exibição (`show.html.erb`, `index.html.erb`):**
        *   Atualizar as views para iterar sobre as coleções (`@contact.phones`, `@contact.emails`) em vez de exibir um único valor. Exibir o registro primário com destaque.
    *   [x] **3.4. Revisar Arquivos Afetados:**
        *   **Controllers:** `contact_employments_controller.rb`, `contact_group_memberships_controller.rb`, `contact_issue_links_controller.rb`, `analytics_controller.rb`. (Verificado: `contact_employments_controller.rb`, `contact_group_memberships_controller.rb`, `contact_issue_links_controller.rb`, `analytics_controller.rb` foram atualizados para usar `FotonContact`.)
        *   **Helpers:** `contacts_helper.rb`. (Verificado: `contacts_helper.rb` foi atualizado para usar `FotonContact`.)
        *   **Views:** Todas as views em `app/views/contacts/`, `app/views/issues/`, `app/views/analytics/` que exibem informações de contato. (Verificado: `app/views/contacts/show_tabs/_details.html.erb` foi atualizado. `index.html.erb` não precisou de alterações diretas para este item.)
        *   **Patches:** `lib/patches/issue_patch.rb`, `lib/patches/user_patch.rb`. (Verificado: `lib/patches/issue_patch.rb` e `lib/patches/user_patch.rb` foram atualizados.)
        *   **Exportação CSV:** Atualizar o método `contacts_to_csv` para lidar com os novos dados. (Verificado em `foton_contact.rb`)

4.  **Atualização dos Testes**
    *   [x] **4.1. Atualizar Testes Existentes:** Modificar os testes unitários, funcionais e de integração para refletir o novo modelo de dados e a lógica de formulários aninhados.
    *   [x] **4.2. Criar Novos Testes:** Adicionar testes para as novas associações e para a lógica de múltiplos telefones/e-mails.

---

### 🚀 Fase 6: Aprimoramento e Contextualização dos KPIs de Análise (Planejada)

**Objetivo:** Evoluir o modal de análise individual de um simples mostrador de números para uma ferramenta de diagnóstico rápido e acionável. O foco é refatorar os KPIs (Key Performance Indicators) para que eles apresentem não apenas o dado bruto, mas também o contexto necessário para uma interpretação correta e imediata pelo gestor.

#### 🗺️ Etapas Detalhadas de Implementação

1.  **Refatorar o KPI "Fator de Criticidade" (FCP)**
    *   **Problema:** A métrica atual, "Fator de Criticidade Ponderado", é um número abstrato (ex: 3.5) de difícil interpretação.
    *   **Solução:** Substituir a média ponderada por uma contagem direta e compreensível de tarefas críticas.
    *   **Plano de Ação:**
        *   [ ] **1.1. Modificar `Analytics::IrpaCalculator`:** Alterar o método `calculate_fcp` para, em vez de calcular a média da posição das prioridades, contar o número de tarefas abertas que tenham prioridade "Alta" ou "Urgente". O método deve retornar este número inteiro.
        *   [ ] **1.2. Atualizar `_analytics_modal.html.erb`:**
            *   Alterar o "KPI Card" para exibir o novo dado.
            *   O `kpi-value` mostrará o número de tarefas (ex: "3").
            *   O `kpi-label` será alterado para "Tarefas Críticas Abertas".

2.  **Contextualizar o KPI "Fator de Instabilidade"**
    *   **Problema:** A métrica "Instabilidade: 20%" é vaga. O gestor não sabe o que causou essa instabilidade.
    *   **Solução:** Adicionar um "tooltip" informativo que revela a causa do número.
    *   **Plano de Ação:**
        *   [ ] **2.1. Modificar `Analytics::IrpaCalculator`:** O método `calculate_instability_factor` já conta o número de alterações. Fazer com que o hash de retorno do `IrpaCalculator` inclua também este número bruto (ex: `instability_change_count`).
        *   [ ] **2.2. Atualizar `_analytics_modal.html.erb`:**
            *   Ao lado do KPI "Fator de Instabilidade", adicionar um ícone de informação (`<i>` com classes de ícone).
            *   Usar o atributo `title` ou `data-bs-toggle="tooltip"` do Bootstrap neste ícone para exibir um texto explicativo ao passar o mouse, como: `"Baseado em X mudanças de projeto/status nos últimos 6 meses"`.

3.  **Enriquecer o Gráfico de Performance por Projeto**
    *   **Problema:** O gráfico de barras atual mostra taxas percentuais, mas não dá noção do volume de trabalho, o que pode levar a interpretações erradas.
    *   **Solução:** Transformar o gráfico de barras simples em um gráfico de barras empilhadas ("stacked bar chart") que mostre o volume total de tarefas e a proporção de cada status (no prazo, atrasadas, retrabalho).
    *   **Plano de Ação:**
        *   [ ] **3.1. Modificar `ContactsController#analytics`:** A variável `@performance_chart_data` precisa ser reestruturada. Para cada projeto, em vez de calcular apenas as taxas, ela deverá fornecer a contagem bruta de:
            *   Total de tarefas (`total_issues`)
            *   Tarefas de retrabalho (`rework_issues`)
            *   Tarefas atrasadas (que não são de retrabalho) (`late_issues`)
            *   Tarefas no prazo (total - retrabalho - atrasadas) (`ontime_issues`)
        *   [ ] **3.2. Atualizar `_analytics_modal.html.erb`:**
            *   A chamada ao helper `bar_chart` será modificada para passar múltiplas séries de dados.
            *   Configurar a opção `stacked: true` na biblioteca do gráfico.
            *   As séries serão "No Prazo", "Atrasadas" e "Retrabalho", e os dados serão a contagem de tarefas em cada categoria por projeto.

---

### 🚀 Fase 7: Compatibilidade Avançada de Importação e Exportação (Revisada)

**Objetivo:** Garantir que os recursos de importação e exportação sejam totalmente compatíveis com os formatos padrão de mercado (Google CSV, Apple vCard), facilitando a migração de dados de outras plataformas.

#### 🗺️ Etapas Detalhadas de Implementação

1.  **Backend: Lógica de Importação e Exportação**
    *   [x] **1.1. Criar `Contacts::ImportService`:** Desenvolver um service object para orquestrar o processo de importação, com suporte a múltiplos formatos.
    *   [x] **1.2. Implementar Mapeadores (Mappers):**
        *   [x] `Contacts::Importers::GoogleCsvMapper`: Para traduzir planilhas do Google CSV.
        *   [x] `Contacts::Importers::VcardMapper`: Para parsear arquivos `.vcf`.
    *   [x] **1.3. Refatorar `ContactsController#import`:** Modificar a action para usar o `ImportService` e fornecer feedback detalhado (criados, atualizados, falhas).
    *   [x] **1.4. Criar `Contacts::ExportService`:** Desenvolver um serviço para lidar com a exportação para múltiplos formatos.
    *   [x] **1.5. Implementar Serializadores (Serializers):**
        *   [x] `Contacts::Exporters::CsvSerializer`: Para gerar arquivos CSV no padrão Google.
        *   [x] `Contacts::Exporters::VcardSerializer`: Para gerar um arquivo `.vcf` com múltiplos contatos.
    *   [x] **1.6. Refatorar `ContactsController#export`:** Criar uma action dedicada que utiliza o `ExportService` para gerar os arquivos com base nos filtros da tela.

2.  **Frontend: Experiência do Usuário**
    *   [x] **2.1. Criar Página de Importação:** Desenvolver a view `import.html.erb` com opções para seleção de formato de arquivo.
    *   [x] **2.2. Melhorar Feedback:** Implementar mensagens de notificação detalhadas após a importação.
    *   [x] **2.3. Atualizar Links de Exportação:** Substituir o link genérico por links específicos para CSV e vCard na `index.html.erb`.

3.  **Lógica de Duplicidade (Simplificada na Importação)**
    *   [x] **3.1. Verificação por E-mail:** O `ImportService` implementa uma verificação básica por e-mail exato para decidir entre criar um novo contato ou atualizar um existente.
    *   [ ] **3.2. Notificação Pós-Importação:** Ao final da importação, adicionar uma mensagem recomendando ao usuário que visite a futura "Central de Qualidade de Dados" para uma análise mais profunda de duplicatas.

---

### 🚀 Fase 8: Central de Qualidade de Dados (Gestão de Duplicatas) (Planejada)

**Objetivo:** Criar um módulo dedicado para a manutenção contínua da base de contatos, permitindo a identificação, revisão e mesclagem de duplicatas de forma inteligente, segura e assistida pelo usuário.

#### 🧠 Arquitetura e Princípios

- **Módulo Dedicado:** A funcionalidade viverá em sua própria área (`/data_quality`), desacoplada do fluxo de importação.
- **Segurança em Primeiro Lugar:** Nenhuma alteração nos dados será feita automaticamente. Todas as mesclagens exigirão confirmação explícita do usuário.
- **Análise Inteligente:** A detecção de duplicatas usará múltiplos critérios (e-mail, similaridade de nome) para aumentar a precisão.
- **Reaproveitamento de Código:** A lógica de mapeamento e os serviços já criados na Fase 7 serão a base para a análise e processamento dos dados.

#### 🗺️ Etapas Detalhadas de Implementação

1.  **Backend: Serviços de Análise e Mesclagem**
    *   [ ] **1.1. Criar `Analytics::DuplicateFinderService`:**
        *   Desenvolver a lógica para varrer a tabela `foton_contacts`.
        *   Implementar a busca por duplicatas com base em e-mails idênticos.
        *   Implementar a busca por duplicatas com base em nomes com alta similaridade (ex: usando a gem `fuzzy-match` ou similar).
        *   O serviço deverá retornar uma lista de pares de contatos suspeitos, sem alterar nenhum dado.
    *   [ ] **1.2. Criar `Contacts::MergeService`:**
        *   Desenvolver o serviço que receberá dois IDs de contato (o principal e o duplicado) e um hash com os dados a serem mantidos.
        *   A lógica deverá ser transacional (`ActiveRecord::Base.transaction`).
        *   **Etapas da Transação:**
            1.  Atualizar o contato principal com os atributos escolhidos.
            2.  Reassociar todos os objetos relacionados do contato duplicado para o principal (vínculos com tarefas, grupos, histórico, anexos, etc.).
            3.  Arquivar ou excluir o contato duplicado.

2.  **Frontend: Interface da Central de Qualidade**
    *   [ ] **2.1. Criar `DataQualityController`:** Criar o novo controller para gerenciar as ações do módulo (`index`, `scan`, `review`, `merge`).
    *   [ ] **2.2. Adicionar Rotas:** Definir as rotas para o novo controller em `config/routes.rb` (ex: `resources :data_quality, only: [:index, :create, :show, :update]`).
    *   [ ] **2.3. View Principal (`index.html.erb`):**
        *   Criar a página inicial do módulo com o botão "Analisar Duplicatas".
        *   Esta página também listará os pares de duplicatas encontrados após a análise, usando `Turbo Frames` para atualização assíncrona.
    *   [ ] **2.4. View de Revisão e Mesclagem (`show.html.erb`):**
        *   Desenvolver a interface de comparação lado a lado para um par de duplicatas.
        *   Para cada campo conflitante, fornecer botões ou rádio-buttons para que o usuário escolha qual dado prevalecerá.
        *   Um formulário (`form_with`) enviará os IDs dos contatos e os dados escolhidos para a action `update` (ou `merge`) do controller.

3.  **Integração e Fluxo de Usuário**
    *   [ ] **3.1. Adicionar Link no Menu:** Inserir um link ou aba na área de Contatos para acessar a "Central de Qualidade de Dados".
    *   [ ] **3.2. Atualizar Mensagem de Importação:** Implementar o item 3.2 da Fase 7, adicionando um link para a nova central na mensagem de feedback da importação.

4.  **Testes**
    *   [ ] **4.1. Testes de Unidade:** Criar testes para o `DuplicateFinderService` e o `MergeService`, validando a lógica de detecção e a segurança da transação de mesclagem.
    *   [ ] **4.2. Testes de Integração:** Criar testes para o fluxo completo: iniciar a análise, selecionar um par, revisar e confirmar a mesclagem, e verificar se o resultado no banco de dados está correto.

---

### 🧪 Testes e Validações (Pendente)

**Objetivo:** Aumentar a robustez e a confiabilidade do plugin.

- [ ] **Testes Unitários (RSpec):** Validar modelos, métodos auxiliares e regras de validação.
- [ ] **Testes de Permissão:** Confirmar que cada usuário vê e acessa apenas o que tem direito.
- [ ] **Testes de Interface:** Garantir que a UI responde corretamente em desktop e mobile.
- [ ] **Testes de Resiliência:** Simular dados corrompidos, ausentes ou duplicados.

---

### 📦 Empacotamento e Documentação Final (Pendente)

**Objetivo:** Facilitar a adoção, o uso e a contribuição para o plugin.

- [ ] **Importação de vCard:** Detalhar e testar o processo de importação.
- [ ] **Documentação da API REST:** Documentar todos os endpoints da API, caso existam.
- [ ] **Hooks para Desenvolvedores:** Detalhar os hooks disponíveis para extensão do plugin.

---

## 📝 Backlog de Funcionalidades

### Avaliação de Sobrecarga para Grupos de Contatos
*   **Problema:** O alerta de sobrecarga de trabalho atualmente funciona apenas para contatos individuais. Ao adicionar um grupo a uma tarefa, não há verificação agregada da carga de trabalho dos membros do grupo.
*   **Solução Proposta:** Estender a funcionalidade de alerta de sobrecarga para grupos. Isso exigiria uma "avaliação vertical" da carga de trabalho de todos os membros do grupo, somando suas alocações para determinar se a adição da tarefa sobrecarregaria o grupo como um todo ou membros específicos.
*   **Implicações:** Necessitaria de alterações na lógica de `check_workload` no backend e no `workload_alert_controller.js` no frontend para lidar com a seleção de grupos e a agregação de dados.

### Refatorar Grupos de Contatos
- **Problema:** O modelo `ContactGroup` usa flags booleanas (`is_system`, `is_private`) que poderiam ser substituídas por um enum `group_type` mais robusto.
- **Solução Proposta:** Avaliar a substituição das flags pelo enum `group_type` (`general`, `ephemeral`).
- **Status:** Pendente.

---

## 🐞 Backlog de Bugs

### Erro de JavaScript intermitente no Dashboard de BI
*   **Problema:** Um erro `Uncaught TypeError: Cannot read properties of undefined (reading 'start')` aparece no DevTools durante a navegação via Turbo Drive nas abas do dashboard de BI. O erro não parece quebrar a funcionalidade visível, mas polui o console.
*   **Comportamento:** O erro não ocorre num recarregamento completo da página (Ctrl+R), apenas em navegações internas, o que aponta para um problema no ciclo de vida do Turbo e na inicialização de scripts.
*   **Próxima Ação / Hipótese:** Investigar qual script (provavelmente um script global ou relacionado com gráficos) está a ser executado fora do seu contexto esperado durante as visitas do Turbo. A solução passará por adicionar uma "cláusula de guarda" para garantir que o script só corra quando os seus elementos alvo estiverem presentes na página.

### Botão de Excluir Vínculo no Modal de Edição Não Funciona
*   **Problema:** No modal de edição de um contato, o link para remover um vínculo empregatício não funciona como esperado.
*   **Comportamento Desejado:** O campo do formulário do vínculo deve ser removido visualmente da interface do modal (via Stimulus), e a exclusão do registro deve ser marcada para ocorrer apenas na submissão do formulário principal (via atributo `_destroy`).
*   **Próxima Ação / Hipótese:** Investigar a implementação do controller Stimulus responsável por essa interação, pois ele pode não estar conectado corretamente ou a lógica de remoção pode estar falhando.

---

## 💡 Backlog de Tecnologia e Otimizações

### Implementar Gerenciador de Links (Porteiro) no Frontend
- **Problema:** A gestão de links para fora do plugin (e mesmo entre páginas completas dentro do plugin) está sendo feita no servidor com um *helper* que adiciona `data-turbo="false"` a todos os links de navegação. Embora funcional, isso causa um recarregamento completo da página, perdendo o benefício de velocidade do Turbo Drive.
- **Solução Proposta:** No futuro, implementar um "porteiro" em JavaScript (via Stimulus controller) que gerencia o comportamento dos links de forma inteligente no lado do cliente. Isso permitiria manter a navegação rápida do Turbo Drive para todas as páginas, mas executando um `Turbo.visit()` programaticamente para garantir que o estado da página (como a URL no navegador) seja atualizado corretamente, oferecendo a melhor experiência de usuário possível.
- **Status:** Pendente. A abordagem via helper no servidor foi priorizada para garantir a funcionalidade imediata.
