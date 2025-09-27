# 📇 Plugin de Contatos para Redmine — Mundo AEC

> Gestão de pessoas, empresas e vínculos profissionais com inteligência, fluidez e integração total ao Redmine.  
> Parte do ecossistema **Livre e OpenSource** que está transformando a indústria da construção civil brasileira.

---

### 🚀 Visão Geral

O **Plugin de Contatos para Redmine** é uma solução desenvolvida para empresas da indústria AEC (Arquitetura, Engenharia e Construção) que precisam gerenciar relacionamentos profissionais com clareza, segurança e agilidade.

Ele centraliza os dados de stakeholders, mapeia o histórico de vínculos profissionais e transforma esses dados em insights, tudo com uma interface moderna, responsiva e totalmente integrada ao Redmine.

---

### 🧩 Funcionalidades Principais

- **Cadastro Inteligente:** CRUD completo para contatos do tipo "Pessoa" e "Empresa".
- **Vínculos Múltiplos:** Associe uma pessoa a múltiplas empresas com cargos, status e histórico.
- **Grupos de Contatos:** Crie e gerencie grupos para organizar seus contatos.
- **Integração com Projetos:** Vincule contatos a tarefas e projetos do Redmine.
- **Visualização Analítica (BI):** Acesse um modal de análise para cada contato, com informações sobre carreira, projetos, vínculos e alertas de inconsistência de dados.
- **Importação e Exportação:** Importe contatos de arquivos CSV e exporte para vCard e CSV.

Para uma lista exaustiva de todas as funcionalidades e um manual detalhado de como o plugin funciona, consulte nosso **[Roadmap e Manual de Funcionalidades](docs/ROADMAP.md)**.

---

### 🏛️ Arquitetura e Filosofia de Design

A interface do plugin é construída seguindo princípios de design modernos para garantir uma experiência de usuário fluida, intuitiva e totalmente integrada ao Redmine. A arquitetura de frontend está em transição para o **framework Hotwire (Turbo + Stimulus)** para maximizar a performance e a reatividade.

Para aprofundar em nossos conceitos de UI/UX, diretrizes de desenvolvimento e arquitetura de frontend, leia o **[Relatório de Arquitetura de Views](docs/views_architecture.md)**.

---

### ⚙️ Requisitos e Instalação

Este plugin gerencia suas próprias dependências. O processo de instalação é simples:

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

---

### 🔧 Configuração

Acesse: **Administração → Configurações → Contatos**

Configure:

- Campos personalizados
- Tipos de contato (Pessoa, Empresa)
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
🐙 [github.com/LAMP-LUCAS](https://mundoaec.com/)

---

> Feito com ♥ por quem acredita que o futuro da construção é aberto, integrado e acessível.