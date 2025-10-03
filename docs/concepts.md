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
- **Padrão Rails:** Seguir as convenções do Ruby on Rails, utilizando `strong_parameters` para segurança e Services/Queries para organizar a lógica de negócio.
- **Modelos "Magra":** A lógica de negócio principal e as validações são mantidas nos modelos sempre que possível.

### Front-End: The Hotwire Stack

A interação do usuário é inteiramente controlada pelo Hotwire, um conjunto de três tecnologias que funcionam em harmonia:

- **Turbo Drive:** Intercepta todos os cliques em links e envios de formulário, realizando-os em segundo plano e substituindo o `<body>` da página. Isso resulta em uma navegação praticamente instantânea.
- **Turbo Frames:** Decompõem a página em segmentos independentes que podem ser atualizados sob demanda. Esta técnica é a base para:
    - **Modais:** Carregamento de formulários de criação e edição.
    - **Lazy-Loading:** Carregamento sob demanda do conteúdo de abas, otimizando a performance.
- **Turbo Streams:** Entregam atualizações de página a partir do servidor, permitindo modificar partes específicas do DOM em resposta a ações do usuário (como criar, atualizar ou deletar um registro). É a tecnologia por trás da atualização dinâmica da lista de contatos após uma edição no modal.

### JavaScript com Stimulus

- **Interatividade Leve e Focada:** O Stimulus é usado para interatividade que complementa o ciclo do Hotwire. Os controllers Stimulus são pequenos e focados em um único comportamento, como:
    - Desabilitar um botão de "Salvar" durante o envio de um formulário.
    - Animar a adição/remoção de campos em formulários aninhados.
    - Integrar bibliotecas JavaScript de terceiros (como `Tom Select`) de forma limpa.

---

## Fluxo de Trabalho

1.  **Planejamento:** Novas funcionalidades são primeiro discutidas e detalhadas no **[Plano de Trabalho](workplan.md)**.
2.  **Implementação:** O código é desenvolvido seguindo as diretrizes de arquitetura Hotwire.
3.  **Verificação:** As alterações são validadas por testes e revisões de código.
4.  **Documentação:** A documentação (`ROADMAP.md`, `workplan.md`, etc.) é atualizada para refletir as novas mudanças, mantendo todos os documentos sincronizados.