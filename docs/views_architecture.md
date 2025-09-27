# Relatório Técnico: Arquitetura de Views do Foton Contacts

## 1. Visão Geral

Este documento é a fonte da verdade para a arquitetura, conceitos e diretrizes de frontend (UI/UX) do plugin **Foton Contacts**. Ele avalia a estrutura atual e estabelece os princípios para o desenvolvimento futuro da interface.

Para o plano de trabalho e tarefas pendentes, consulte o **[Workplan](workplan.md)**.
Para o manual de funcionalidades e histórico de desenvolvimento, consulte o **[Roadmap](ROADMAP.md)**.

---

## 2. Filosofia e Diretrizes de Design

O desenvolvimento do plugin é guiado por uma filosofia de design clara e consistente.

### 2.1. Princípios Fundamentais

1.  **Integração Nativa e Fluidez:** O plugin deve se comportar como uma extensão natural do Redmine. A experiência do usuário deve ser fluida e sem atrito ao transitar entre as funcionalidades nativas e as do plugin.
2.  **Foco Absoluto em Usabilidade (UI/UX):** A usabilidade é a prioridade máxima. As interfaces devem ser intuitivas, fáceis de usar, responsivas e acessíveis, fazendo uso extensivo de modais para operações rápidas.
3.  **Inteligência de Dados e Ação:** O plugin deve transformar dados brutos em insights acionáveis, oferecendo uma visão analítica que ajude o usuário a identificar inconsistências e mapear relacionamentos.
4.  **Desempenho:** O plugin deve ser otimizado para um bom desempenho, mesmo com um grande número de contatos e relacionamentos.
5.  **Segurança e Resiliência:** A arquitetura deve ser robusta, validando todas as entradas de dados, respeitando as permissões do Redmine e tratando de forma elegante a ausência ou inconsistência de informações.
6.  **Qualidade de Código:** O projeto segue o padrão *Conventional Commits* e um fluxo de contribuição baseado no Git Flow simplificado.

---

## 3. Arquitetura e Stack Tecnológica

### 3.1. Estrutura Legada (Base)

A arquitetura inicial foi baseada no padrão clássico do Rails:
- **Templates ERB com Parciais:** Forte modularização e respeito ao SRP.
- **JavaScript Não Obstrutivo (UJS):** Interatividade gerenciada via `remote: true` com respostas em `js.erb` que manipulam o DOM com jQuery.

Esta base é funcional, mas representa uma prática legada no ecossistema Rails 7+.

### 3.2. Arquitetura Alvo (Hotwire)

A visão futura e o padrão para todo novo desenvolvimento de frontend é o framework **Hotwire (Turbo + Stimulus)**.

- **Turbo Drive & Frames:** Para navegação e componentização da página, evitando recarregamentos completos e permitindo o carregamento sob demanda (lazy-loading).
- **Turbo Streams:** Para atualizações parciais e reativas da página (criar, atualizar, deletar itens em uma lista) em resposta a ações do usuário, substituindo completamente a necessidade de `js.erb`.
- **Stimulus:** Para interações complexas no lado do cliente que exigem JavaScript, como toggles, animações, wrappers de bibliotecas de terceiros (ex: Tom Select), e feedback de UI (ex: exibir spinners).

**O plano de migração detalhado da stack legada para a arquitetura alvo está documentado no [workplan.md](workplan.md).**

---

## 4. Guia de Componentes e Padrões de UX

Para manter a consistência e a alta qualidade da UI, os seguintes padrões devem ser seguidos:

1.  **Feedback Visual:** Toda ação assíncrona (submissão de formulário) deve fornecer feedback. Desabilitar o botão de submissão e exibir um spinner é o padrão. Em caso de erro, as mensagens devem ser exibidas próximas aos campos problemáticos.
2.  **Carregamento Sob Demanda (Lazy Loading):** Conteúdos "pesados" ou secundários, como o conteúdo de abas, devem ser carregados sob demanda usando Turbo Frames com `loading="lazy"`.
3.  **"Empty States" (Estados Vazios):** Nenhuma lista deve ficar simplesmente em branco. Um estado vazio deve informar ao usuário a ausência de dados e fornecer um botão de ação claro para o próximo passo (ex: "Criar seu primeiro contato").
4.  **Hierarquia Visual:** Formulários e páginas devem usar espaçamento, agrupamento de campos e tipografia para criar uma hierarquia clara e guiar o usuário, evitando interfaces intimidadoras.
5.  **Componentes Modernos:** Deve-se evitar o uso de bibliotecas com dependência de jQuery. Para campos de seleção com busca, o padrão é o `Tom Select`, encapsulado em um controller Stimulus.

---

## 5. Fluxograma de Interação do Usuário

O fluxograma abaixo ilustra as principais jornadas do usuário dentro do plugin, demonstrando visualmente a arquitetura de interação.

```mermaid
graph TD
    subgraph "Jornada Principal"
        A[Início: Acessa a aba 'Contatos'] --> B{Lista de Contatos};
        B --> C[Clica em 'Novo Contato'];
        B --> D[Clica em 'Editar' em um contato];
        B --> E[Clica em 'Análise' (🔍) em um contato];
        B --> F[Usa Filtros/Busca];
        F --> B;
    end

    subgraph "Fluxo de Criação/Edição (Modal)"
        C --> G[Abre Modal de Formulário];
        D --> G;
        G -- Preenche/Altera dados --> H{Salva Formulário};
        H -- Sucesso --> I[Modal fecha, lista é atualizada];
        H -- Erro --> J[Exibe erros de validação no modal];
        J --> G;
    end

    subgraph "Fluxo de Análise (Modal)"
        E --> K[Abre Modal de Análise (BI)];
        K --> L[Navega entre abas: Vínculos, Projetos, Alertas];
        L --> K;
    end

    I --> B;
```

---

## 6. Conclusão

Este documento estabelece as diretrizes para a criação de uma experiência de usuário excepcional no Foton Contacts. A migração para Hotwire é o pilar técnico para alcançar essa visão, e todos os novos desenvolvimentos devem aderir aos padrões de UX aqui definidos.