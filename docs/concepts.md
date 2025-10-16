# Conceitos e Diretrizes de Desenvolvimento

Este documento estabelece os princípios fundamentais que guiam o desenvolvimento do plugin **Foton Contacts**. O objetivo é criar uma ferramenta robusta, moderna e fácil de usar, que se integre perfeitamente ao Redmine.

Para uma visão geral das funcionalidades, consulte o **[Roadmap e Manual](ROADMAP.md)**. Para tarefas de desenvolvimento em andamento, veja o **[Plano de Trabalho](workplan.md)**.

---

##  Filosofia Principal

1.  **Foco no Usuário:** A interface é intuitiva, rápida e responsiva. Ações comuns não devem exigir recarregamentos de página inteira, graças à arquitetura Hotwire.
2.  **Código Moderno e Manutenível:** Aderir às melhores práticas do ecossistema Ruby on Rails 7+, favorecendo simplicidade, clareza e a stack Hotwire.
3.  **Documentação é Fundamental:** Todo o progresso e as decisões de arquitetura são documentados para facilitar a manutenção e a colaboração.

---

## Diretrizes de Arquitetura

O plugin adota a filosofia "The Hotwire Way" como padrão para toda a sua arquitetura de front-end, minimizando a necessidade de código JavaScript complexo e maximizando a produtividade do desenvolvedor.

### Back-End
- **Padrão Rails com Service Objects:** A lógica de negócio complexa é extraída para classes de serviço dedicadas (Service Objects ou Query Objects). Isso mantém os controllers e modelos limpos e focados em suas responsabilidades principais. O `Analytics::HistoricalStateQuery` é um exemplo prático deste padrão, encapsulando a lógica de consultas temporais para ser reutilizada em diferentes análises.
- **Modelos "Magros" (Fat Model, Skinny Controller):** A lógica diretamente associada a um modelo (validações, associações, métodos de instância simples) permanece nele, mas a lógica de negócio que coordena múltiplos modelos ou fontes de dados deve ser movida para um serviço.

### Front-End: The Hotwire Stack

A interação do usuário é inteiramente controlada pelo Hotwire, um conjunto de três tecnologias que funcionam em harmonia:

- **Turbo Drive:** Intercepta todos os cliques em links e envios de formulário, realizando-os em segundo plano e substituindo o `<body>` da página. Isso resulta em uma navegação praticamente instantânea.
- **Turbo Frames:** Decompõem a página em segmentos independentes que podem ser atualizados sob demanda. Esta técnica é a base para:
    - **Modais:** Carregamento de formulários de criação e edição.
    - **Lazy-Loading:** Carregamento sob demanda do conteúdo de abas, otimizando a performance.
- **Turbo Streams:** Entregam atualizações de página a partir do servidor, permitindo modificar partes específicas do DOM em resposta a ações do usuário (como criar, atualizar ou deletar um registro). É a tecnologia por trás da atualização dinâmica da lista de contatos após uma edição no modal.

### Componentização com Partials

Para promover a reutilização e a clareza, a interface é dividida em componentes independentes usando partials do Rails. Elementos de UI complexos ou recorrentes, como a lista de tarefas vinculadas a um contato (`app/views/issues/_issue_list.html.erb`), são encapsulados em seus próprios partials. Isso torna o código das views mais limpo e facilita a manutenção.

### JavaScript com Stimulus

> ATENÇÃO: Redmine 6.0.7 com Rails 7.2.2.2 não serve automaticamente arquivos JS da pasta assets/javascripts via /plugin_assets/... como fazia em versões anteriores.

- **Interatividade Leve e Focada:** O Stimulus é usado para interatividade que complementa o ciclo do Hotwire. Os controllers Stimulus são pequenos e focados em um único comportamento, como:
    - Desabilitar um botão de "Salvar" durante o envio de um formulário.
    - Animar a adição/remoção de campos em formulários aninhados.
    - Integrar bibliotecas JavaScript de terceiros (como `Tom Select`) de forma limpa.

---

## Principais Entidades e Conceitos

O plugin é construído sobre um conjunto de modelos de dados que representam os stakeholders e seus relacionamentos.

- **Contato (Contact):** É a entidade central. Um contato pode ser de dois tipos:
  - **Pessoa (Person):** Representa um indivíduo, com atributos como nome, cargo, e-mail e telefone.
  - **Empresa (Company):** Representa uma organização. Pessoas podem ser vinculadas a empresas.

- **Vínculo Empregatício (ContactEmployment):** Modela o relacionamento de carreira entre uma Pessoa e uma Empresa. Ele registra o cargo, a data de início e a data de fim, formando o histórico profissional de um contato.

- **Grupo de Contatos (ContactGroup):** Permite agrupar Pessoas e Empresas de forma lógica (ex: "Equipe de Projeto X", "Fornecedores de TI").

- **Vínculo a Tarefas (ContactIssueLink):** É a entidade que conecta o CRM ao sistema de gestão de projetos do Redmine. Ela representa a associação entre um `Contact` (Pessoa ou Empresa) ou um `ContactGroup` e uma `Issue` (tarefa). Este vínculo possui um atributo adicional crucial:
  - **Função (Role):** Um campo de texto que descreve *qual o papel* daquele contato ou grupo naquela tarefa específica (ex: "Aprovador", "Consultor Técnico", "Cliente").

- **Histórico (Journals):** O plugin utiliza o sistema de journaling do Redmine para rastrear todas as alterações feitas em um contato, fornecendo uma trilha de auditoria completa.

---

## Fluxo de Trabalho

1.  **Planejamento:** Novas funcionalidades são primeiro discutidas e detalhadas no **[Plano de Trabalho](workplan.md)**.
2.  **Implementação:** O código é desenvolvido seguindo as diretrizes de arquitetura Hotwire.
3.  **Verificação:** As alterações são validadas por testes e revisões de código.
4.  **Documentação:** A documentação (`ROADMAP.md`, `workplan.md`, etc.) é atualizada para refletir as novas mudanças, mantendo todos os documentos sincronizados.