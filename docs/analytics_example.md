### Relatório de Arquitetura e Funcionamento: Dashboard de Teste (`/examples/dashboard`)

Este relatório detalha a estrutura e o fluxo de trabalho do dashboard de teste em `/examples/dashboard`, que agora opera de forma totalmente funcional, incluindo lazy-loading de abas e modais. Ele serve como o modelo validado para a implementação final do módulo de Analytics.

#### 1. **Visão Geral da Arquitetura (Hotwire)**

A implementação do dashboard de teste segue rigorosamente os princípios da arquitetura Hotwire (Turbo + Stimulus), minimizando o JavaScript customizado e maximizando a renderização HTML pelo servidor.

*   **Turbo Drive:** Gerencia a navegação principal, proporcionando uma experiência de Single-Page Application (SPA).
*   **Turbo Frames:** Utilizado para carregar conteúdo de forma assíncrona e sob demanda (lazy-loading) nas abas e para exibir modais.
*   **Stimulus:** Empregado para adicionar interatividade leve no lado do cliente, como a troca de abas e o gerenciamento do estado do modal.

#### 2. **Frontend: `examples/dashboard.html.erb` (A Página Principal do Dashboard)**

Esta view atua como o "esqueleto" do dashboard, definindo a estrutura principal (abas) e os contêineres para o conteúdo.

*   **Definição das Abas (`@tabs`)**:
    ```erb
    <% 
    @tabs = [
      { name: 'overview', partial: 'examples/tabs/overview_frame', label: :label_overview },
      { name: 'team_performance', partial: 'examples/tabs/team_performance_frame', label: :label_team_performance },
      { name: 'workload', partial: 'examples/tabs/workload_frame', label: :label_workload }
    ]
    %>
    ```
    *   Um array `@tabs` é definido na view (em uma aplicação real, seria definido no controller e passado para a view). Cada hash descreve uma aba, incluindo seu identificador (`name`), a `partial` que será renderizada para o seu "frame" e o texto do `label`.
*   **Controle de Abas (`div.tabs` com `data-controller="show-tabs"`)**:
    ```erb
    <div class="tabs" data-controller="show-tabs" data-show-tabs-initial-tab-value="<%= params[:tab].presence || @tabs.first[:name] %>">
      <ul>
        <% @tabs.each do |tab| %>
          <li>
            <%= link_to l(tab[:label]), { controller: 'examples', action: 'dashboard', tab: tab[:name] },
                        data: { action: "click->show-tabs#showTab", "show-tabs-target": "tab", tab_name: tab[:name] },
                        id: "tab-link-#{tab[:name]}" %>
          </li>
        <% end %>
      </ul>
    </div>
    ```
    *   O `div` que contém as abas é controlado pelo **Stimulus `show-tabs-controller.js`**. Este controller gerencia a visibilidade das abas (adicionando/removendo a classe `selected`) e atualiza a URL do navegador para refletir a aba ativa, permitindo links diretos.
    *   Cada `link_to` de aba aponta para a própria action `examples#dashboard`, mas com um parâmetro `tab` diferente, e o Stimulus intercepta o clique para gerenciar a troca no frontend.
*   **Conteúdo das Abas (`div.tab-content`)**:
    ```erb
    <% @tabs.each_with_index do |tab, i| %>
      <div class="tab-content <%= (params[:tab].to_s == tab[:name].to_s || (params[:tab].blank? && i == 0)) ? 'selected' : nil %>" id="tab-<%= tab[:name] %>" data-show-tabs-target="content" data-tab-name="<%= tab[:name] %>">
        <%= render partial: tab[:partial] %>
      </div>
    <% end %>
    ```
    *   Para cada aba, um `div.tab-content` é renderizado. A classe `selected` controla qual conteúdo é visível.
    *   Dentro de cada `div.tab-content`, é renderizada uma **`partial` de "frame"** (ex: `examples/tabs/_overview_frame.html.erb`).

#### 3. **Frontend: Partials de "Frame" (`examples/tabs/_*_frame.html.erb`)**

Estas parciais são a ponte para o lazy-loading de conteúdo.

*   **Exemplo (`examples/tabs/_overview_frame.html.erb`)**:
    ```erb
    <%= turbo_frame_tag "irpa_widget_frame", src: irpa_widget_examples_path, loading: :lazy %>
    ```
    *   Cada partial de frame contém um único **`turbo_frame_tag`**.
    *   O `id` do `turbo_frame_tag` (ex: `"irpa_widget_frame"`) é único e corresponde ao conteúdo que ele irá carregar.
    *   O atributo `src` aponta para uma action do `ExamplesController` (ex: `irpa_widget_examples_path`). Esta action é responsável por renderizar o conteúdo real do widget.
    *   `loading: :lazy` é uma otimização do Turbo que faz com que o conteúdo do frame só seja carregado quando o frame se torna visível na viewport do usuário, melhorando a performance inicial da página.

#### 4. **Backend: Actions de Widget (`ExamplesController#irpa_widget`, etc.)**

Estas actions no `ExamplesController` atuam como endpoints para os Turbo Frames, fornecendo o HTML dos widgets.

*   **Exemplo (`ExamplesController#irpa_widget`)**:
    ```ruby
    def irpa_widget
      @irpa_data = Analytics::IrpaCalculator.calculate_for_collection(Contact.person.includes(:issues)).sort_by! { |h| -h[:risk_score] }
      render 'examples/irpa_widget', layout: false
    end
    ```
    *   Cada action de widget:
        *   Busca e processa os dados necessários (utilizando os `Service Objects` de `Analytics`, como `Analytics::IrpaCalculator`).
        *   **Renderiza uma view específica (ex: `examples/irpa_widget.html.erb`) com `layout: false`**. Isso é crucial, pois a resposta deve ser apenas o HTML do widget, sem o cabeçalho/rodapé completo da aplicação, para que o Turbo possa injetá-lo no frame.

#### 5. **Frontend: Views de Widget (`examples/irpa_widget.html.erb`, etc.)**

Estas views contêm o HTML real dos widgets e são a resposta final para as requisições dos Turbo Frames.

*   **Exemplo (`examples/irpa_widget.html.erb`)**:
    ```erb
    <%= turbo_frame_tag "irpa_widget_frame" do %>
      <h2>Exemplo: Widget IRPA</h2>
      <%= render partial: 'analytics/analytics/widgets/_irpa_widget', locals: { irpa_data: @irpa_data } %>
    <% end %>
    ```
    *   Cada view de widget **é envolvida por um `turbo_frame_tag` com o MESMO ID** do frame que a solicitou (ex: `"irpa_widget_frame"`). Isso permite que o Turbo substitua o conteúdo do frame original com a resposta.
    *   Dentro deste frame, é renderizada a `partial` de conteúdo do widget (ex: `analytics/analytics/widgets/_irpa_widget.html.erb`), que exibe os dados formatados.

#### 6. **Funcionalidade de Modal (Drill-Down)**

O modal de detalhes de um contato segue um padrão específico para ser exibido sobre a página principal.

*   **Link de Ativação (em `analytics/analytics/widgets/_irpa_widget.html.erb`)**:
    ```erb
    <%= link_to data[:contact_name], details_modal_examples_path(id: data[:contact_id]), data: { turbo_frame: "modal" } %>
    ```
    *   O link para abrir o modal **aponta explicitamente para o `turbo_frame_tag "modal"`**.
*   **Global Modal Frame (em `contacts/index.html.erb` ou layout principal):
    ```erb
    <%= turbo_frame_tag "modal", data: { controller: "modal" } %>
    ```
    *   Este é o `turbo_frame_tag` que existe na página principal e que será preenchido com o conteúdo do modal. Ele tem `data-controller="modal"` para ativar o Stimulus `modal_controller.js`.
*   **Action do Modal (`ExamplesController#details_modal`)**:
    ```ruby
    def details_modal
      @contact = Contact.find(1) # Exemplo com ID fixo para teste
      @irpa_data = Analytics::IrpaCalculator.calculate_for_contact(@contact)
      respond_to do |format|
        format.html { render 'examples/details_modal', layout: false }
      end
    end
    ```
    *   A action busca os dados do contato e renderiza a view `examples/details_modal.html.erb` **sem layout**.
*   **View do Modal (`examples/details_modal.html.erb`)**:
    ```erb
    <%= turbo_frame_tag "modal", data: { modal_history_action_value: "replace" } do %>
      <div class="modal-header">
        <h3 class="title">Análise de Risco: <%= @contact.name %></h3>
        <%= link_to "&#10006;".html_safe, close_modal_contacts_path, class: "close", data: { turbo_method: :post } %>
      </div>
      <%= render partial: 'examples/_details_modal_content', locals: { contact: @contact, irpa_data: @irpa_data } %>
    <% end %>
    ```
    *   Esta view **é envolvida por um `turbo_frame_tag "modal"` com o mesmo ID** do frame global. Quando o link é clicado, o Turbo substitui o `turbo_frame_tag "modal"` existente na página pelo conteúdo desta view.
    *   O `data: { modal_history_action_value: "replace" }` é uma instrução para o `modal_controller.js` gerenciar o histórico do navegador ao fechar o modal.
*   **Conteúdo do Modal (`examples/_details_modal_content.html.erb`)**:
    ```erb
    <div class="modal-header">
      <h3>Análise de Risco: <%= contact.name %></h3>
      <%= link_to "x", "#", class: "close", data: { action: "click->modal#closeAndGoBack" } %>
    </div>
    <div class="modal-body">
      <h4>Score IRPA: <span style="color: red;"><%= irpa_data[:risk_score] %>%</span></h4>
      <hr />
      <p><strong>Taxa de Atraso Histórica:</strong> <%= irpa_data[:tah_percent] %>%</p>
      <p><strong>Índice de Retrabalho:</strong> <%= irpa_data[:ir_percent] %>%</p>
      <p><strong>Fator de Criticidade Ponderado (médio):</strong> <%= irpa_data[:fcp_avg] %></p>
      
      <h4>Histórico Profissional</h4>
      <% if contact.employments_as_person.any? %>
        <ul>
          <% contact.employments_as_person.each do |employment| %>
            <li><%= employment.position %> na <%= employment.company.name %></li>
          <% end %>
        </ul>
      <% else %>
        <p class="nodata">Nenhum histórico profissional cadastrado.</p>
      <% end %>
    </div>
    ```
    *   Esta partial contém o HTML interno do modal (cabeçalho, corpo, dados).
    *   O botão de fechar (`link_to "x", ... data: { action: "click->modal#closeAndGoBack" }`) chama a ação `closeAndGoBack` do `modal_controller.js`.

#### 7. **Relação Frontend-Backend**

*   **Requisições:** O frontend (Turbo Frames) faz requisições HTTP GET para as actions do `ExamplesController`.
*   **Respostas:** O backend (actions do `ExamplesController`) responde com fragmentos HTML (views renderizadas com `layout: false`) que contêm `turbo_frame_tag`s com IDs correspondentes aos frames que fizeram a requisição.
*   **Interatividade:** O Stimulus (`show-tabs-controller`, `modal_controller`) adiciona interatividade leve (troca de abas, abertura/fechamento de modal, gerenciamento de histórico) sem a necessidade de JavaScript complexo de manipulação de DOM.

#### 8. **Design Patterns e Congruências**

*   **Componentização:** Uso extensivo de `partials` para modularizar a UI.
*   **Lazy Loading:** Implementado de forma eficaz com `turbo_frame_tag src="..." loading: :lazy`.
*   **"HTML-over-the-wire":** O servidor é a principal fonte de HTML, minimizando o JavaScript no cliente.
*   **Padrão de Abas:** Replicado do `contacts/show.html.erb`.
*   **Padrão de Modal:** Replicado do `contacts/edit.html.erb` e `contacts/new.html.erb`.

#### 9. **Premissas para o Desenvolvimento Final (`/analytics`)**

Com o ambiente de teste `/examples/dashboard` totalmente funcional, as premissas para a implementação final do módulo de Analytics no caminho `/analytics` são claras:

1.  **Replicar a Estrutura de Views:** A estrutura de `analytics/analytics/index.html.erb` deve ser idêntica à de `examples/dashboard.html.erb`, incluindo a definição do array `@tabs` e a renderização das `partials` de frame.
2.  **Replicar as Partials de Frame:** As `partials` de frame (`analytics/analytics/tabs/_*_frame.html.erb`) devem ser idênticas às de `examples/tabs/_*_frame.html.erb`, apontando para as actions corretas do `Analytics::AnalyticsController`.
3.  **Replicar as Views de Widget:** As views de widget (`analytics/analytics/widgets/_*_widget.html.erb`) devem ser idênticas às de `examples/_*_widget.html.erb`, incluindo o `turbo_frame_tag` envolvente.
4.  **Ajustar Actions do `Analytics::AnalyticsController`:** As actions de widget (`irpa_widget`, `team_performance`, `workload`, `contact_details`, `dynamic_dashboard`) devem ser ajustadas para:
    *   Buscar os dados necessários.
    *   Renderizar suas respectivas views de widget (ex: `analytics/analytics/widgets/irpa_widget.html.erb`) com `layout: false`.
5.  **Garantir `modal_controller.js` Ativo:** O `turbo_frame_tag "modal"` na página principal (`contacts/index.html.erb`) deve ter `data: { controller: "modal" }` para que o `modal_controller.js` seja ativado e gerencie a exibição do modal.
6.  **Consistência de Rotas:** Todos os `named route helpers` devem ser consistentes com as rotas definidas no `routes.rb` para o `namespace :analytics`.

---
