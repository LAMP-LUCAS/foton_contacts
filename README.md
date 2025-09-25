# 📇 Plugin de Contatos para Redmine — Mundo AEC

> Gestão de pessoas, empresas e vínculos profissionais com inteligência, fluidez e integração total ao Redmine.  
> Parte do ecossistema **Livre e OpenSource** que está transformando a indústria da construção civil brasileira.

---

### 🚀 Visão Geral

O **Plugin de Contatos para Redmine** é uma solução desenvolvida para empresas da indústria AEC (Arquitetura, Engenharia e Construção) que precisam gerenciar relacionamentos profissionais com clareza, segurança e agilidade.

Com ele, você pode:

- Cadastrar pessoas e empresas com campos específicos
- Vincular pessoas a múltiplas empresas com cargos e histórico
- Criar grupos de contatos (efêmeros ou permanentes)
- Associar contatos e grupos a tarefas e projetos
- Visualizar análises de vínculos, carreira e participação em projetos
- Integrar perfis de usuários Redmine ao sistema de contatos
- Importar e exportar dados via CSV, vCard e QR code

Tudo isso com uma interface moderna, responsiva e totalmente integrada ao Redmine.

---

### 🧠 Por que este plugin existe?

A indústria da construção ainda sofre com:

- Equipes externas sem cadastro formal
- Contatos dispersos em planilhas e e-mails
- Falta de histórico de vínculos e cargos
- Dificuldade em visualizar relacionamentos entre pessoas, empresas e projetos

Este plugin resolve esses problemas com uma abordagem centrada no usuário, na continuidade dos dados e na colaboração entre equipes.

---

### 🌐 Parte do Ecossistema Mundo AEC

Este plugin é mantido pela comunidade [Mundo AEC](https://mundoaec.com/), um ecossistema de soluções abertas que conecta dados, ferramentas e pessoas em toda a jornada da construção — do investidor ao usuário final.

Outras soluções do ecossistema incluem:

- [AutoSINAPI](https://mundoaec.com/): dados atualizados do SINAPI via API
- Ferramentas Web: fluxo de caixa, cronograma, gestão de tarefas
- Comunidade Foton: plugins, integrações e conhecimento colaborativo

---

### ⚙️ Requisitos

Para a funcionalidade completa, incluindo os gráficos de análise (BI), é **obrigatório** instalar as gems `chartkick`, `chartjs-ror` e `groupdate`.

1.  **Adicione ao Gemfile do Redmine:**
    Abra o arquivo `Gemfile` na raiz da sua instalação do Redmine e adicione a seguinte linha:
    ```ruby
    gem 'chartkick'
    gem 'chartjs-ror'
    gem 'groupdate'
    ```

2.  **Instale a gem:**
    ```bash
    bundle install
    ```

#### 🐳 Instalação com Docker

Se você usa Docker, adicione as gems ao `Gemfile` do seu Redmine (você pode montá-lo como um volume ou criar um `Dockerfile` customizado) e reconstrua sua imagem para que o `bundle install` seja executado.

Exemplo de `Dockerfile` para adicionar as gems:
```Dockerfile
FROM redmine:latest
RUN echo "gem 'chartkick'" >> Gemfile && \
    echo "gem 'chartjs-ror'" >> Gemfile && \
    echo "gem 'groupdate'" >> Gemfile && \
    bundle install
```

### 📦 Instalação

```bash
# Clone o repositório na pasta de plugins do Redmine
git clone https://github.com/LAMP-LUCAS/foton_contacts plugins/foton_contacts

# Execute as migrações
bundle exec rake redmine:plugins:migrate RAILS_ENV=production

# Reinicie o servidor
sudo systemctl restart redmine
```

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

### 🧩 Funcionalidades

- **Cadastro inteligente** de pessoas e empresas
- **Vínculos múltiplos** com cargos e status (ativo, inativo, descontinuado)
- **Grupos de contatos** para tarefas e projetos
- **Perfil de contato** vinculado a usuários Redmine
- **Visualização analítica** com histórico e carreira
- **Importação e exportação** via CSV, vCard e QR code
- **Interface fluida e responsiva**, compatível com mobile e desktop

---

### 🛡️ Segurança e Resiliência

- Validação de dados em todos os modelos
- Controle de visibilidade por escopo e permissões
- Tratamento de dados ausentes ou corrompidos
- Logs de acesso e modificação
- Compatível com Redmine 5.x e superior

---

### 🤝 Contribua com o projeto

Este plugin é **Livre e OpenSource**. Toda contribuição é bem-vinda!

- Veja as [diretrizes de contribuição](CONTRIBUTING.md)
- Use mensagens de commit convencionais
- Teste localmente antes de enviar PRs
- Participe da comunidade [Mundo AEC](https://mundoaec.com/)

---

### 📬 Contato

Dúvidas, sugestões ou parcerias?  
📧 contato@mundoaec.com  
🌐 [mundoaec.com](https://mundoaec.com/)  
🐙 [github.com/LAMP-LUCAS](https://mundoaec.com/)

---

> Feito com ♥ por quem acredita que o futuro da construção é aberto, integrado e acessível.
