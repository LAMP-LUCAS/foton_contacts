# 📇 Plugin de Contatos para Redmine — Mundo AEC

> Gestão de pessoas, empresas e vínculos profissionais com inteligência, fluidez e integração total ao Redmine.  
> Parte do ecossistema **Livre e OpenSource** que está transformando a indústria da construção civil brasileira.

---

### 🚀 Visão Geral

O **Plugin de Contatos para Redmine** é uma solução completa para gestão de stakeholders na indústria AEC (Arquitetura, Engenharia e Construção). Ele centraliza dados de pessoas e empresas, mapeia o histórico de vínculos profissionais e, mais importante, **integra essas informações diretamente às tarefas e projetos do Redmine**.

Com uma interface moderna e reativa construída com **Hotwire**, o plugin transforma dados de contato em insights acionáveis, permitindo uma visão 360º dos relacionamentos que impulsionam seus projetos.

---

### 🧩 Funcionalidades Principais

- **Cadastro Unificado:** CRUD completo para contatos do tipo "Pessoa" e "Empresa".
- **Vínculos Profissionais:** Associe pessoas a múltiplas empresas com cargos, datas e histórico de carreira.
- **Grupos Dinâmicos:** Crie e gerencie grupos de contatos para segmentação e comunicação.
- **Integração Profunda com Tarefas:**
    - Vincule múltiplos contatos e grupos diretamente a qualquer tarefa do Redmine.
    - Atribua **funções** específicas aos contatos em uma tarefa (ex: "Aprovador", "Fornecedor", "Cliente").
    - Busque e adicione contatos a uma tarefa de forma rápida, sem sair da tela da tarefa.
- **Visualização Analítica (BI):**
    - Acesse um modal de análise para cada contato, com informações sobre carreira e projetos.
    - Utilize o **Dashboard de Análises** para uma visão gerencial completa.
    - **Mapa de Calor de Carga de Trabalho (Workload):** Visualize a alocação da equipe ao longo do tempo, identifique gargalos e ociosidade.
        - Filtre a análise por projeto.
        - Alterne a visualização entre **horas estimadas** e **horas lançadas** para comparar planejamento e realidade.
- **Importação e Exportação:** Importe contatos de arquivos CSV e exporte para vCard e CSV.

Para uma lista exaustiva de todas as funcionalidades e um manual detalhado, consulte nosso **[Roadmap e Manual de Funcionalidades](docs/ROADMAP.md)**.

---

### 🏛️ Arquitetura e Filosofia de Design

A interface do plugin é construída com o **framework Hotwire (Turbo + Stimulus)**, garantindo uma experiência de usuário fluida, rápida e moderna, que se integra de forma nativa ao Redmine. A filosofia é de "HTML-over-the-wire", minimizando a complexidade no frontend.

- **Navegação Acelerada com Turbo Drive:** Interações rápidas, sem recarregamento de página.
- **Componentes Reativos com Turbo Frames e Streams:** Modais, abas e listas são atualizados dinamicamente, proporcionando uma experiência de SPA (Single Page Application).
- **Interatividade com Stimulus:** Controladores JavaScript leves para funcionalidades como busca, formulários dinâmicos e feedback visual.

Para aprofundar em nossos conceitos de UI/UX e arquitetura, leia o **[Relatório de Arquitetura de Views](docs/views_architecture.md)**.

---

### ⚡ Requisitos de Ambiente

O plugin foi desenhado para funcionar em um ambiente Redmine moderno que utilize **Hotwire** e **importmap-rails**.

Se o seu Redmine ainda não está configurado para usar `importmap`, será necessário adaptar o carregamento de JavaScript. O plugin injeta um *hook* (`javascript_include_tag('application', type: 'module')`) que depende dessa configuração.

**Nota:** As instruções detalhadas de instalação do Hotwire foram removidas por estarem desatualizadas. A recomendação é seguir a documentação oficial do `hotwire-rails` para configurar seu ambiente Redmine adequadamente.

---

### ⚙️ Instalação e Configuração

O processo de instalação é simples:

1.  **Clone o repositório** para a pasta de plugins do seu Redmine:
    ```bash
    git clone https://github.com/LAMP-LUCAS/foton_contacts plugins/foton_contacts
    ```

2.  **Instale as dependências** (gems). A partir do diretório raiz do seu Redmine, execute:
    ```bash
    bundle install
    ```

3.  **Execute as migrações** do banco de dados:
    ```bash
    bundle exec rake redmine:plugins:migrate RAILS_ENV=production
    ```

4.  **Reinicie o servidor** do Redmine para carregar o plugin.

#### Configuração Pós-Instalação

Acesse: **Administração → Configurações → Contatos**

Configure:

- Campos personalizados
- Permissões por função
- Mapeamento de campos para CSV/vCard
- Visibilidade padrão (global, privada, por projeto)

---

### 🤝 Contribua com o projeto

Este plugin é **Livre e OpenSource**. Toda contribuição é bem-vinda!

- **Veja o que precisa ser feito:** Nosso **[Plano de Trabalho (Workplan)](docs/workplan.md)** está sempre atualizado com as próximas tarefas.
- **Siga as diretrizes:** Leia as [diretrizes de contribuição](CONTRIBUTING.md) e use mensagens de commit convencionais.
- **Participe da comunidade:** [Mundo AEC](https://mundoaec.com/)

---

### 📬 Contato

Dúvidas, sugestões ou parcerias?  
📧 contato@mundoaec.com  
🌐 [mundoaec.com](https://mundoaec.com/)  
🐙 [github.com/LAMP-LUCAS](https://github.com/LAMP-LUCAS/foton_contacts)

---

> Feito com ♥ por quem acredita que o futuro da construção é aberto, integrado e acessível.
