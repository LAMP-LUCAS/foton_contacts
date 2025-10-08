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

### ✅ Fase 2: Vínculo de Contatos e Grupos às Issues (Concluída)

**Objetivo:** Implementar a capacidade de associar contatos e grupos diretamente a uma issue do Redmine, fornecendo contexto sobre os stakeholders de cada tarefa.

**Resultados:**
- **Modelo de Dados:** Foi criada a tabela `contact_issue_links` e o modelo `ContactIssueLink` para estabelecer a relação N-N entre contatos/grupos e issues. Os modelos `Issue`, `Contact` e `ContactGroup` foram estendidos (via patches) para refletir essas associações.
- **Integração com a Issue:** Utilizando um hook do Redmine (`view_issues_show_details_bottom`), uma nova seção "Contatos Vinculados" foi injetada na página da issue.
- **Interface Reativa:** A seção é totalmente gerenciada via Hotwire. A adição e remoção de vínculos são instantâneas e não recarregam a página, utilizando `Turbo Streams` para atualizar a UI.
- **Busca Inteligente:** Um campo de busca com `Tom Select` permite encontrar e adicionar contatos ou grupos de forma eficiente, consultando um endpoint JSON dedicado.
- **Experiência de Usuário Aprimorada:** A exibição dos vínculos evoluiu de simples "pílulas" para "cards" informativos. Foi implementada a edição "inline" do campo "Função" (`role`) com salvamento automático (via Stimulus), proporcionando uma UX fluida e rica em contexto, conforme idealizado nos mockups.

---

### 🚀 Fase 3: Business Intelligence e Análises Avançadas (Em Planejamento)

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
    -   [ ] **1.1. Criar `AnalyticsController`:** Definir as actions principais (`index`, `team_performance`, `workload`, etc.) e as rotas correspondentes em `config/routes.rb`.
    -   [ ] **1.2. Implementar os Cálculos de Métricas:**
        -   [ ] Criar `Service/Query Objects` para cada análise principal descrita no `bi_analysis_guide.md`:
            -   `Analytics::IrpaCalculator` para o **Índice de Risco Preditivo de Alocação (IRPA)**.
            -   `Analytics::TeamScorecardQuery` para o **Painel de Performance da Equipa**.
            -   `Analytics::WorkloadQuery` para o **Mapa de Calor da Carga de Trabalho**.
            -   `Analytics::DataQualityMonitor` para a **Saúde dos Dados**.
    -   [ ] **1.3. Configuração de Carga Horária:** Adicionar os campos para configuração da carga horária global e por contato, conforme especificado no guia de BI.

2.  **Dashboard Principal e Análise de Risco (Cenários BDD 1 e 2)**
    -   [ ] **2.1. View do Dashboard Principal:** Criar a view `app/views/analytics/index.html.erb` com uma estrutura de abas (`Visão Geral`, `Análise de Equipes`, `Carga de Trabalho`).
    -   [ ] **2.2. Widgets com Lazy Loading:** Na aba "Visão Geral", criar os partials para cada widget (`_irpa_widget.html.erb`, `_data_quality_widget.html.erb`, etc.), cada um dentro de um `turbo_frame_tag` com `loading: :lazy`.
    -   [ ] **2.3. Tabela de Risco (IRPA):** Implementar a tabela de contatos de maior risco. Cada linha terá um link para a análise detalhada.
    -   [ ] **2.4. Modal de Análise Individual (Drill-Down):** O clique no nome de um contato na tabela de risco abrirá um modal (`_contact_analysis_modal.html.erb`) via Turbo Frame, exibindo o score IRPA, os KPIs detalhados e o histórico do contato.

3.  **Dashboard Dinâmico na Lista de Contatos (Cenário BDD 3)**
    -   [ ] **3.1. Modificar a View `contacts/index`:** Adicionar um `<turbo_frame_tag id="dynamic_dashboard">` abaixo da tabela de contatos.
    -   [ ] **3.2. Criar Controller Stimulus:** Desenvolver um controller `contact-filter-observer-controller.js` que monitora os eventos de filtro da lista.
    -   [ ] **3.3. Lógica de Atualização:** Quando os filtros forem aplicados, o controller Stimulus irá disparar uma nova requisição para o frame `dynamic_dashboard`, passando os parâmetros de filtro atuais. O backend recalculará as métricas para o subconjunto de dados e renderizará o dashboard atualizado.

4.  **Análise Comparativa de Equipes (Cenário BDD 4)**
    -   [ ] **4.1. View de Análise de Equipes:** Criar a view/partial para a aba "Análise de Equipes".
    -   [ ] **4.2. Integrar Gráfico de Radar:** Desenvolver um controller Stimulus (`chart-controller.js`) que recebe os dados do `TeamScorecardQuery` e renderiza o Gráfico de Radar para comparação visual das equipes.
    -   [ ] **4.3. Ranking de Equipes:** Exibir a tabela de "Ranking de Equipes" ao lado do gráfico.

5.  **Mapa de Carga de Trabalho e Alerta Proativo (Cenário BDD 5)**
    -   [ ] **5.1. View do Mapa de Calor:** Criar a view para a aba "Carga de Trabalho", que renderizará o heatmap. A UI permitirá filtrar por período (semana, mês) e por contatos.
    -   [ ] **5.2. Lógica do Heatmap:** O backend, usando a `WorkloadQuery`, calculará a matriz de `[contato, dia]` com a porcentagem de alocação, que será usada para colorir as células da tabela.
    -   [ ] **5.3. Implementar Alerta de Sobrecarga (Real-Time):**
        -   [ ] **Backend:** Criar o endpoint `POST /contacts/check_workload` que recebe `contact_id`, `start_date`, `due_date`, `estimated_hours` e retorna um status de `ok` ou `overload`.
        -   [ ] **Frontend:** Na página da issue, um controller Stimulus interceptará a adição de um contato. Antes de salvar, ele fará um `fetch` para o endpoint `check_workload`. Se a resposta for `overload`, ele exibirá um `window.confirm()` com o alerta, permitindo que o gestor decida se continua ou não.

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

---

## 💡 Backlog de Tecnologia e Otimizações

### Implementar Gerenciador de Links (Porteiro) no Frontend
- **Problema:** A gestão de links para fora do plugin (e mesmo entre páginas completas dentro do plugin) está sendo feita no servidor com um *helper* que adiciona `data-turbo="false"` a todos os links de navegação. Embora funcional, isso causa um recarregamento completo da página, perdendo o benefício de velocidade do Turbo Drive.
- **Solução Proposta:** No futuro, implementar um "porteiro" em JavaScript (via Stimulus controller) que gerencia o comportamento dos links de forma inteligente no lado do cliente. Isso permitiria manter a navegação rápida do Turbo Drive para todas as páginas, mas executando um `Turbo.visit()` programaticamente para garantir que o estado da página (como a URL no navegador) seja atualizado corretamente, oferecendo a melhor experiência de usuário possível.
- **Status:** Pendente. A abordagem via helper no servidor foi priorizada para garantir a funcionalidade imediata.
