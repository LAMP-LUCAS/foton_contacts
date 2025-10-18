# Guia de Implementação: Dashboards de BI no Foton Contacts

## 1. Visão Geral

Este documento resume os padrões de arquitetura e as metodologias de desenvolvimento que foram **validados na prática** para a construção dos dashboards de Business Intelligence do plugin. O objetivo é servir como um guia rápido e direto para a manutenção e criação de novas análises, evitando regressões e conflitos de tecnologia.

Este guia complementa o `views_architecture.md`, focando nas "receitas" que funcionaram após um processo iterativo de depuração.

---

## 2. Padrão de Renderização de Abas: A Arquitetura de 3 Estágios

A renderização de cada aba do dashboard (Visão Geral, Análise de Equipes, etc.) **deve** seguir o padrão "Monolito-Modular" de 3 estágios para garantir o funcionamento correto do lazy-loading com Turbo Frames.

### Estágio 1: O Frame (Container da Aba)

- **Arquivo:** `app/views/analytics/tabs/_*_frame.html.erb` (ex: `_team_performance_frame.html.erb`)
- **Responsabilidade:** Conter um único `<turbo_frame_tag>` que aponta para a `action` do controller que carregará o conteúdo da aba.
- **Padrão de Código:**
```erb
<%# ESTÁGIO 1: Frame da Aba %>
<%# Este frame carrega todo o conteúdo da aba de forma assíncrona %>
<%= turbo_frame_tag "team_performance_tab_content", src: analytics_team_performance_tab_path, loading: :lazy do %>
  <p><%= l(:label_loading) %>...</p>
<% end %>
```

### Estágio 2: O Layout da Aba (O "Monolito")

- **Arquivo:** `app/views/analytics/tabs/_*.html.erb` (ex: `_team_performance.html.erb`)
- **Responsabilidade:** Ser a resposta da `action` do controller. Sua única função é definir a estrutura de layout (grid, colunas) e renderizar os componentes (Estágio 3), passando os dados necessários.
- **REGRA DE OURO:** O conteúdo desta partial **deve obrigatoriamente ser envolvido por um `turbo_frame_tag` com o mesmo ID do Estágio 1.** A ausência desta tag causa a falha silenciosa do Turbo.
- **Padrão de Código:**
```erb
<%# A resposta para uma requisição de frame DEVE conter um frame com o mesmo ID %>
<%= turbo_frame_tag "team_performance_tab_content" do %>
  <%# ESTÁGIO 2: Layout da Aba %>
  <div class="row">
    <div class="col-md-7">
      <%= render partial: "analytics/components/team_radar_chart", locals: { scorecard_data: scorecard_data } %>
    </div>
    <div class="col-md-5">
      <%= render partial: "analytics/components/team_ranking_table", locals: { scorecard_data: scorecard_data } %>
    </div>
  </div>
<% end %>
```

### Estágio 3: Os Componentes

- **Arquivo:** `app/views/analytics/components/_*.html.erb` (ex: `_team_radar_chart.html.erb`)
- **Responsabilidade:** Renderizar um único widget de UI (um gráfico, uma tabela). Não deve ter conhecimento do layout. Recebe todos os seus dados via `locals`.

---

## 3. Padrão para Gráficos: A Stack Validada

Após múltiplos testes, a única abordagem que se provou 100% funcional e robusta para renderizar gráficos no ambiente do plugin foi a seguinte:

### 3.1. A Configuração Correta

1.  **Gems:** O `Gemfile` deve conter `gem 'chartkick'`, mas **NÃO DEVE** conter `gem 'chartjs-ror'` para evitar conflitos de helpers.
2.  **Carregamento de JavaScript (CDN):** As bibliotecas de gráficos **devem** ser carregadas via CDN na view principal (`analytics/index.html.erb`), usando `content_for :header_tags`. A ordem é crucial.
    ```erb
    <% content_for :header_tags do %>
      <%# 1. A biblioteca de desenho (Chart.js) %>
      <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
      <%# 2. A biblioteca de integração (Chartkick.js), que depende da anterior %>
      <script src="https://cdn.jsdelivr.net/npm/chartkick@4.2.0/dist/chartkick.min.js"></script>
    <% end %>
    ```
3.  **`application.js` do Plugin:** **NÃO DEVE** conter `//= require chartkick` ou `//= require Chart.bundle`. O `application.js` do plugin não se mostrou confiável para empacotar JS de gems externas neste ambiente.

### 3.2. A Implementação Correta (JavaScript Direto)

Os helpers do Rails (`<%= line_chart ... %>`) se mostraram problemáticos para traduzir opções complexas (como `type: 'radar'`). A abordagem validada é **ignorar os helpers e usar a biblioteca `Chartkick.js` diretamente**.

- **Padrão de Código (Exemplo do Gráfico de Radar):**
```erb
<%# 1. Formatar os dados em Ruby para o formato JSON que o JS espera %>
<% 
  chart_data_for_js = scorecard_data.map do |team_data|
    {
      name: team_data[:group_name],
      data: [
        ['Qualidade', team_data[:avg_quality_score]],
        ['Velocidade', team_data[:avg_velocity_score]]
        # ... etc
      ]
    }
  end
%>

<%# 2. Criar um <div> com um ID para o gráfico %>
<div id="team-radar-chart-container" style="height: 350px;"></div>

<%# 3. Chamar o Chartkick.js diretamente, injetando os dados com `raw ... .to_json` %>
<script>
  new Chartkick.LineChart("team-radar-chart-container", <%= raw chart_data_for_js.to_json %>, {
    dataset: { type: 'radar' } 
  });
</script>
```

---

## 4. Padrão para Filtros em Abas: Target Direto

Para implementar filtros que atualizam uma parte de uma aba (como uma tabela de resultados) sem recarregar a página inteira, o padrão mais robusto e simples é o **"Target Direto"**, que não requer JavaScript customizado (Stimulus).

### Arquitetura do Filtro

1.  **Layout da Aba (`_workload.html.erb`):**
    - Renderiza a partial dos filtros.
    - Renderiza um `turbo_frame_tag` para os resultados, com um `src` que busca os dados iniciais.

2.  **Formulário de Filtro (`_workload_filters.html.erb`):**
    - É um `form_tag` simples.
    - **REGRA DE OURO:** O formulário **deve** ter o atributo `data: { "turbo-frame": "ID_DO_FRAME_DE_RESULTADOS" }`.
    - O `action` do formulário aponta para a `action` do controller que renderiza os resultados.

3.  **Action de Resultados (`workload_results`):**
    - Busca os dados com base nos parâmetros do filtro.
    - Renderiza a partial de resultados.

4.  **Partial de Resultados (`_workload_results.html.erb`):**
    - **REGRA DE OURO:** O conteúdo desta partial **deve** ser envolvido por um `turbo_frame_tag` com o mesmo ID do frame de resultados.

### Exemplo de Código

**Layout da Aba (`_workload.html.erb`):**
```erb
<%= turbo_frame_tag "workload_tab_content" do %>
  <%= render partial: 'analytics/components/workload_filters', ... %>
  
  <%= turbo_frame_tag "workload_results", src: analytics_workload_results_path, ... do %>
    <p>Carregando...</p>
  <% end %>
<% end %>
```

**Formulário de Filtro (`_workload_filters.html.erb`):**
```erb
<%= form_tag(analytics_workload_results_path, 
           method: :get, 
           data: { "turbo-frame": "workload_results" }) do %>
  <%# ... campos do filtro ... %>
  <%= submit_tag 'Aplicar' %>
<% end %>
```

**Partial de Resultados (`_workload_results.html.erb`):**
```erb
<%= turbo_frame_tag "workload_results" do %>
  <%# ... a tabela ou conteúdo com os resultados ... %>
<% end %>
```

---

## 5. Checklist Anti-Regressão

Ao criar ou modificar um dashboard, siga este checklist para evitar os problemas que enfrentamos:

- [ ] **Nova Aba:** A `action` do controller renderiza a partial de **Layout (Estágio 2)**?
- [ ] **Nova Aba:** A partial de **Layout (Estágio 2)** está envolvida por um `<turbo_frame_tag>` com o ID correto?
- [ ] **Novo Gráfico:** Estou usando a abordagem de **JavaScript Direto** (`new Chartkick...`) em vez dos helpers do Rails?
- [ ] **Novo Gráfico:** Os CDNs para `Chart.js` e `Chartkick.js` estão presentes e na ordem correta na view principal?
- [ ] **Filtros:** O formulário de filtro aponta para o `turbo_frame` de resultados usando `data-turbo-frame`?
- [ ] **Filtros:** A `action` que responde ao filtro renderiza uma partial que está envolvida pelo mesmo `turbo_frame`?
- [ ] **Nova Rota:** A rota para o `src` do Turbo Frame está definida corretamente em `config/routes.rb` e o helper `_path` está sendo usado corretamente?
