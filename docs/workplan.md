# Foton Contacts

## Plano de Trabalho (Workplan)

*Nota: Este documento foi atualizado para refletir o estado de desenvolvimento atual. As fases concluídas representam o trabalho já realizado, enquanto as fases pendentes estão em planejamento.*

### 🧭 Apresentação

Este documento detalha o plano de trabalho para a evolução do plugin **Foton Contacts**, uma solução OpenSource para a gestão de contatos e relacionamentos profissionais no Redmine, com foco especial na indústria de Arquitetura, Engenharia e Construção (AEC).

#### Objetivos do Plugin

O Foton Contacts visa resolver problemas crônicos na gestão de stakeholders em projetos de construção, como:

- **Centralização de Dados:** Unificar contatos (pessoas e empresas) que hoje vivem em planilhas, e-mails e sistemas desconectados.
- **Gestão de Vínculos:** Permitir o mapeamento de relacionamentos profissionais complexos, como um mesmo profissional atuando em diferentes empresas com cargos distintos ao longo do tempo.
- **Rastreabilidade e Histórico:** Manter um histórico claro de vínculos, participações em projetos e evolução de carreira dos contatos.
- **Inteligência de Dados:** Oferecer uma visão analítica sobre a rede de contatos, seus relacionamentos e inconsistências (ex: dados faltantes, duplicidade).

#### Diretrizes de Desenvolvimento

O desenvolvimento do plugin é guiado pelos seguintes princípios, conforme detalhado no `CONTRIBUTING.md`:

- **Integração Nativa:** A interface e as funcionalidades devem ser consistentes com a experiência padrão do Redmine.
- **Foco em UI/UX:** A usabilidade é prioridade. As interfaces devem ser fluidas, responsivas e acessíveis.
- **Segurança e Resiliência:** O plugin deve ser seguro, validando todas as entradas e tratando de forma elegante a ausência ou inconsistência de dados.
- **Qualidade de Código:** O projeto segue o padrão *Conventional Commits* para mensagens de commit e um fluxo de contribuição baseado no Git Flow simplificado.

---

### ✅ Fase 4 — Frontend e Experiência do Usuário (Concluído)

**Objetivo:** Criar uma interface robusta, responsiva e intuitiva para o gerenciamento de contatos, com foco em:

- Visualização analítica (BI) em aba dedicada
- Operações rápidas (CRUD, importação, vinculação) em modais
- Melhorar a responsividade para dispositivos móveis

#### 🔘 Botões de Ação (topo da aba)

- [x] ➕ **Novo Contato** → abrir formulário modal com campos dinâmicos por tipo
- [x] 📥 **Importar CSV/vCard** → abrir modal com upload e mapeamento de campos
- [x] 📊 **Análise de Contato** → botão em cada linha da tabela que abre modal BI

#### 📊 Modal de Análise (BI)

- [x] **Abertura:**
  - Acessado via botão 🔍 na tabela
  - Modal responsivo com abas internas
- [x] **Conteúdo:**
  - [x] **Aba 1: Vínculos:** Quantidade de empresas vinculadas, cargos ocupados e status, período de cada vínculo.
  - [x] **Aba 2: Relações com Projetos:** Projetos associados, tarefas vinculadas (por tipo de issue), última atividade registrada.
  - [x] **Aba 3: Carreira:** Linha do tempo dos vínculos, evolução de cargos, participação em grupos e tarefas.
  - [x] **Aba 4: Alertas e Inconsistências:** Dados ausentes (e-mail, telefone, empresa), vínculos sem cargo definido, contatos duplicados (por nome ou e-mail).

### 🧪 Fase 6 — Testes e Validações (Em Andamento)

**Objetivo:**

- Garantir que todas as funcionalidades do plugin funcionem corretamente
- Validar regras de negócio, permissões e escopos
- Prevenir falhas em ambientes com dados incompletos ou inconsistentes

#### 🧱 Tipos de Testes

- [x] **Testes de Integração (RSpec/Capybara):**
  - [x] Verificar fluxo entre controllers, views e banco de dados para as principais funcionalidades.
- [x] **Testes de Importação/Exportação:**
  - [x] Validar mapeamento e tratamento de arquivos CSV.
- [ ] **Testes Unitários (RSpec):**
  - [ ] Validar modelos, métodos auxiliares e regras de validação.
- [ ] **Testes de Permissão:**
  - [ ] Confirmar que cada usuário vê e acessa apenas o que tem direito.
- [ ] **Testes de Interface:**
  - [ ] Garantir que a UI responde corretamente em desktop e mobile.
- [ ] **Testes de Resiliência:**
  - [ ] Simular dados corrompidos, ausentes ou duplicados.

### 📦 Fase 7 — Empacotamento, Documentação e Publicação (Planejamento)

**Objetivo:**

- Criar documentação técnica e de uso clara, acessível e atualizada.

#### 📘 Documentação Técnica

- [ ] **Uso do Plugin:**
  - [ ] Detalhar o processo de importação de vCard.
    - [ ] Detalhar funcionalidades avançadas e configurações.
- [ ] **Documentação para Desenvolvedores:**
  - [ ] Detalhar os hooks disponíveis.
  - [ ] Documentar a API REST.

### backlog

#### Implementar Histórico de Alterações no Contato

- **Problema:** A tentativa de exibir o histórico de alterações na página de detalhes do contato falha com um erro `NoMethodError (undefined method 'journals')`. Isso ocorre porque o modelo `Contact` não foi configurado para usar o sistema de histórico (`journals`) do Redmine.
- **Solução Proposta:**
  1.  Modificar o modelo `app/models/contact.rb`.
  2.  Adicionar a declaração `acts_as_journalized` ao modelo, configurando quais campos devem ser monitorados.
  3.  Restaurar a lógica no `ContactsController#show` para carregar os `@journals`.
  4.  Garantir que a view `show.html.erb` exiba o histórico corretamente usando o helper `render_journals(@journals)`.
- **Status:** A lógica quebrada foi removida do controller para evitar o erro 500. A funcionalidade está desativada até que o modelo seja corrigido.