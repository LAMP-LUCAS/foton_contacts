# Foton Contacts: Plano de Trabalho (Workplan)

## 🧭 Apresentação

Este documento detalha o plano de trabalho e as tarefas pendentes para a evolução do plugin **Foton Contacts**. O objetivo do plugin é ser a solução definitiva para gestão de contatos e relacionamentos no Redmine para a indústria AEC.

Para detalhes sobre funcionalidades já implementadas e como o plugin funciona, consulte o **[Roadmap e Manual de Funcionalidades](ROADMAP.md)**.

Para diretrizes de arquitetura, UI/UX e conceitos de desenvolvimento, consulte o **[Relatório de Arquitetura de Views](views_architecture.md)**.

---

## 🚀 Fase 1 — Modernização da Interface com Hotwire (Prioridade)

**Objetivo:** Migrar a interface do plugin de UJS/jQuery para Hotwire (Turbo e Stimulus) para criar uma experiência de usuário mais rápida, fluida e moderna.

### Fase 1.0: Preparação do Ambiente
- [x] **Instalar Hotwire:** Adicionar a gem `hotwire-rails` e executar `rails hotwire:install`.
- [x] **Análise de Conflitos:** Garantir que a inicialização do Hotwire não entre em conflito com os scripts JavaScript existentes.

### Fase 1.1: Migração do CRUD de Contatos
- [x] **Estruturar com Turbo Frames:** Envolver a lista de contatos e os modais de formulário em `turbo-frame-tag`.
- [x] **Atualizar Controller:** Modificar as actions `create` e `update` para responder com `Turbo Streams`.
- [x] **Remover Código Legado:** Excluir os arquivos `*.js.erb` e o código jQuery associado.

### Fase 1.2: Otimização com Carregamento Sob Demanda (Lazy Loading)
- [x] **Aplicar em Abas:** Converter o conteúdo das abas para `Turbo Frames` com `loading="lazy"`.

### Fase 1.3: Refinamento da Experiência com Stimulus
- [x] **Adicionar Feedback Visual:** Usar Stimulus para desabilitar botões e exibir spinners durante o envio de formulários.
- [x] **Melhorar Formulários Dinâmicos:** Usar Stimulus para animar a adição de novos vínculos e focar automaticamente.
- [x] **Implementar "Empty States":** Exibir mensagens e botões de ação quando as listas estiverem vazias.

### Fase 1.4: Modernização de Componentes
- [ ] **Substituir Select2:** Planejar a substituição de `select2.js` por `Tom Select` com um wrapper Stimulus.

---

## 🧪 Fase 2 — Testes e Validações (Pendentes)

**Objetivo:** Aumentar a robustez e a confiabilidade do plugin.

- [ ] **Testes Unitários (RSpec):** Validar modelos, métodos auxiliares e regras de validação.
- [ ] **Testes de Permissão:** Confirmar que cada usuário vê e acessa apenas o que tem direito.
- [ ] **Testes de Interface:** Garantir que a UI responde corretamente em desktop e mobile após a migração para Hotwire.
- [ ] **Testes de Resiliência:** Simular dados corrompidos, ausentes ou duplicados.

---

## 📦 Fase 3 — Empacotamento e Documentação (Pendentes)

**Objetivo:** Facilitar a adoção e contribuição para o plugin.

- [ ] **Importação de vCard:** Detalhar e testar o processo de importação.
- [ ] **Documentação da API REST:** Documentar todos os endpoints da API.
- [ ] **Hooks para Desenvolvedores:** Detalhar os hooks disponíveis para extensão do plugin.

---

## 📝 Backlog Pendente

### Implementar Histórico de Alterações no Contato

- **Problema:** A funcionalidade de histórico (`journals`) está desativada pois o modelo `Contact` não foi configurado para tal.
- **Solução Proposta:**
  1. Adicionar `acts_as_journalized` ao modelo `contact.rb`.
  2. Restaurar a lógica no `ContactsController#show` e na view `show.html.erb` para carregar e renderizar os `journals`.
- **Status:** Pendente.

### Refatorar Grupos de Contatos

- **Problema:** O modelo `ContactGroup` usa flags booleanas (`is_system`, `is_private`) que poderiam ser substituídas por um enum `group_type` mais robusto.
- **Solução Proposta:** Avaliar a substituição das flags pelo enum `group_type` (`general`, `ephemeral`).
- **Status:** Pendente.