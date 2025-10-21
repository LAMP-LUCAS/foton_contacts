# Roadmap e Manual de Funcionalidades do Foton Contacts

## 🚀 Visão Geral

Este documento é o registro histórico e o manual de funcionalidades do plugin **Foton Contacts**. Ele descreve em detalhes o que já foi implementado e como o plugin funciona.

---

## ✅ Funcionalidades Implementadas

### Core

- **Gestão de Contatos Detalhada:** CRUD completo para contatos (pessoas e empresas). Cada contato pode ter **múltiplos e-mails, telefones e endereços**, com a capacidade de marcar um de cada tipo como "principal", oferecendo um cadastro flexível e completo.
- **Tipos e Status:** Diferenciação entre contatos do tipo "pessoa" e "empresa", e controle de status (ativo, inativo, descontinuado).
- **Campos Personalizados:** Suporte a campos personalizados para contatos.
- **Anexos e Histórico:** Suporte a anexos e registro de histórico de alterações (`journals`) para contatos.
- **Busca e Filtro:** Funcionalidade de busca e filtros na lista de contatos.

### Relacionamentos

- **Vínculos Empregatícios (Carreira):** Associação dinâmica de contatos (pessoas) a empresas. A criação, edição e remoção de vínculos ocorrem em um modal com Hotwire, permitindo a construção de um histórico de carreira detalhado (cargo, datas de início e fim) sem recarregar a página.
- **Grupos de Contatos:** CRUD completo e dinâmico para criação de grupos, permitindo organizar contatos de forma segmentada. A adição e remoção de membros são feitas de forma interativa.

### Integração com Tarefas (Issues)

Esta é a funcionalidade central que conecta a gestão de contatos ao trabalho diário no Redmine.

- **Vínculo Direto a Tarefas:** Permite associar múltiplos contatos e/ou grupos de contatos diretamente a uma tarefa, criando um registro claro de todos os stakeholders envolvidos.
- **Atribuição de Funções (Roles):** Ao vincular um contato a uma tarefa, é possível atribuir uma **função** específica a ele (ex: "Aprovador", "Fornecedor", "Cliente"). Esse campo é editável diretamente na lista de contatos da tarefa, salvando automaticamente.
- **Busca Inteligente na Tarefa:** Dentro da tela de uma tarefa, uma caixa de busca permite encontrar e adicionar contatos ou grupos rapidamente, sem interromper o fluxo de trabalho. A busca sugere resultados em tempo real.
- **Gestão Visual:** Os contatos vinculados são exibidos como "cards" informativos na própria tarefa, cada um com um botão para remoção rápida e a opção de editar a função.

### Integração com Redmine

- **Permissões:** Sistema de permissões integrado ao Redmine para controlar o acesso aos contatos (visualizar, criar, editar, etc.).
- **Visibilidade:** Controle de visibilidade de contatos (público, privado, por projeto).
- **Perfil de Usuário:** Vínculo de um contato a um usuário do Redmine.

### UI/UX e Arquitetura Front-End (Hotwire)

A interface foi completamente modernizada com **Hotwire (Turbo + Stimulus)** para oferecer uma experiência de usuário de página única (SPA-like), rápida e reativa, eliminando a necessidade de recarregamentos de página completos para operações comuns.

- **Navegação com Turbo Drive:** A navegação geral no plugin é acelerada, proporcionando uma sensação de fluidez.
- **Modais com Turbo Frames:** Todas as operações de CRUD (Criar/Editar Contatos, Adicionar/Editar Vínculos) ocorrem em modais que são carregados dinamicamente com Turbo Frames. Isso mantém o contexto do usuário na página de fundo (seja a lista de contatos ou o perfil de um contato).
- **Atualizações em Tempo Real com Turbo Streams:** Após salvar ou excluir um item em um modal, a lista de fundo é atualizada automaticamente via Turbo Streams, sem a necessidade de recarregar a página. Erros de validação também são tratados de forma inteligente dentro do modal.
- **Carregamento Sob Demanda (Lazy Loading):** Na página de perfil de um contato, o conteúdo das abas (Detalhes, Carreira, Histórico, etc.) é carregado sob demanda usando Turbo Frames, otimizando o tempo de carregamento inicial da página.
- **Componentes Interativos com Stimulus:**
  - **Feedback Visual:** Formulários fornecem feedback claro, desabilitando botões e exibindo spinners durante o envio para evitar cliques duplos.
  - **Formulários Dinâmicos:** A adição e remoção de campos aninhados (como vínculos empregatícios) é gerenciada de forma suave.
  - **Componentes Modernos:** A biblioteca `Select2` foi substituída por `Tom Select` para campos de seleção avançados, encapsulado em um controller Stimulus para uma integração perfeita.
- **"Empty States" Inteligentes:** Listas vazias (como um contato sem histórico ou vínculos) exibem mensagens amigáveis com botões de ação claros, guiando o usuário no próximo passo.

### Importação e Exportação

- **Importação de CSV:** Suporte para importação de contatos a partir de arquivos CSV.
- **Exportação de vCard e CSV:** Suporte para exportação de contatos individuais para o formato vCard (.vcf) e da lista para CSV.

### Testes

- **Testes de Integração:** Cobertura de testes de integração para o `ContactsController`, validando as principais ações de CRUD e filtros.

### Análises e Business Intelligence

O plugin integra um módulo de análise para transformar dados de contatos e projetos em inteligência acionável, com um foco em análise histórica e preditiva.

- **Dashboard de Análises:** Uma área dedicada com múltiplos painéis (Visão Geral, Performance da Equipe, Carga de Trabalho) para visualização de dados gerenciais.

- **Índice de Risco Preditivo de Alocação (IRPA):**
  - Calcula um score de risco para cada contato, permitindo identificar proativamente possíveis gargalos.
  - A fórmula foi aprimorada para incluir não apenas o desempenho em tarefas (atrasos, retrabalho), mas também um **Fator de Instabilidade**, que mede a frequência com que o status ou o projeto de um contato mudam, com base no seu histórico no `Journal`.

- **Painel de Performance da Equipe:**
  - Compara o desempenho de diferentes grupos através de um Gráfico de Radar e uma tabela de ranking.
  - A métrica de **Índice de Coesão da Equipa (ICE)** foi aprimorada para usar o `Journal`, calculando a duração real da permanência de cada membro no grupo e fornecendo um dado de estabilidade muito mais preciso.

- **Análise de Parceiros:**
  - Um gráfico de bolhas na "Visão Geral" permite comparar a estabilidade e a experiência das equipes de empresas parceiras.
  - A métrica de **Turnover** agora é calculada com precisão, usando o histórico de criação e destruição de vínculos empregatícios (`ContactEmployment`) registrados no `Journal`. A análise pode ser filtrada por período.

- **Mapa de Calor de Carga de Trabalho (Workload):**
  - Visualiza a alocação percentual de cada membro da equipe por dia, semana ou mês.
  - Identifica rapidamente períodos de sobrecarga ou ociosidade.
  - Permite filtrar a análise por projeto e alternar entre horas estimadas e lançadas.

---

## 🎯 Próximos Passos

O desenvolvimento do plugin continua, focado em aprimorar a inteligência de dados e a experiência do usuário. As próximas fases incluem:

-   **Fase 6: Aprimoramento e Contextualização dos KPIs de Análise:** Evoluir o modal de análise individual para uma ferramenta de diagnóstico rápido e acionável, contextualizando os KPIs para uma interpretação imediata.
-   **Fase 8: Central de Qualidade de Dados:** Criar um módulo dedicado para identificação, revisão e mesclagem assistida de duplicatas, garantindo a integridade da base de contatos.
-   **Testes e Validações:** Aumentar a robustez e a confiabilidade do plugin com testes unitários, de permissão, de interface e de resiliência.
-   **Empacotamento e Documentação Final:** Facilitar a adoção, o uso e a contribuição para o plugin, incluindo a documentação de API REST e hooks para desenvolvedores.

**Backlog de Funcionalidades:**

-   **Avaliação de Sobrecarga para Grupos de Contatos:** Estender o alerta de sobrecarga para grupos, somando a alocação dos membros.
-   **Refatorar Grupos de Contatos:** Avaliar a substituição de flags booleanas por um enum `group_type` mais robusto.

**Backlog de Bugs:**

-   **Erro de JavaScript intermitente no Dashboard de BI:** Investigar e corrigir o `Uncaught TypeError` durante a navegação via Turbo Drive.
-   **Botão de Excluir Vínculo no Modal de Edição Não Funciona:** Corrigir a remoção visual e a marcação para exclusão de vínculos empregatícios em modais.

**Backlog de Tecnologia e Otimizações:**

-   **Implementar Gerenciador de Links (Porteiro) no Frontend:** Refatorar a gestão de links para manter a navegação rápida do Turbo Drive para todas as páginas.

---

## 🏗️ Estrutura do Repositório

```text
./foton_contacts/
├── app
│   ├── controllers
│   ├── models
│   └── views
├── assets
│   ├── javascripts
│   │   └── controllers (Stimulus)
│   └── stylesheets
├── config
│   ├── locales
│   └── routes.rb
├── db
│   └── migrate
├── lib
│   ├── hooks
│   └── patches
└── test
    ├── functional
    ├── integration
    └── unit
```