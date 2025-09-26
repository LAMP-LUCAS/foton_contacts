# Roadmap do Foton Contacts

## 🚀 Visão Geral

Este documento descreve o roadmap de desenvolvimento do plugin **Foton Contacts** para o Redmine. Ele serve como um guia para as próximas funcionalidades, bem como um registro do que já foi implementado.

## ✅ Funcionalidades Implementadas

### Core
- [x] **Gestão de Contatos:** CRUD completo para contatos (pessoas e empresas).
- [x] **Tipos e Status:** Diferenciação entre contatos do tipo "pessoa" e "empresa", e controle de status (ativo, inativo, descontinuado) com tipos enumerados.
- [x] **Campos Personalizados:** Suporte a campos personalizados para contatos.
- [x] **Anexos:** Suporte a anexos para contatos.
- [x] **Busca e Filtro:** Funcionalidade de busca e filtros na lista de contatos.

### Relacionamentos
- [x] **Cargos e Empresas:** Associação de contatos (pessoas) a empresas com cargos específicos.
- [x] **Grupos de Contatos:** Criação de grupos de contatos para organização.
- [x] **Vínculo com Tarefas:** Associação de contatos a tarefas do Redmine.

### Integração com Redmine
- [x] **Permissões:** Sistema de permissões integrado ao Redmine para controlar o acesso aos contatos.
- [x] **Visibilidade:** Controle de visibilidade de contatos (público, privado, por projeto).
- [x] **Perfil de Usuário:** Vínculo de um contato a um usuário do Redmine.

### UI/UX
- [x] **Interface com Modais:** Utilização de modais para criação e edição de contatos, proporcionando uma experiência de usuário mais fluida.
- [x] **Tela de Análise (BI):** Implementação de uma tela de análise de contatos com gráficos e insights sobre vínculos, projetos e carreira.

### Importação e Exportação
- [x] **Importação de CSV:** Suporte para importação de contatos a partir de arquivos CSV.
- [x] **Exportação de vCard e CSV:** Suporte para exportação de contatos individuais para o formato vCard (.vcf) e da lista de contatos para CSV.

### Testes
- [x] **Testes de Integração:** Cobertura de testes de integração para o `ContactsController`, validando as principais ações de CRUD e filtros.

## 🎯 Próximos Passos

### Frontend
- [ ] **Melhorar a responsividade** do plugin para dispositivos móveis.
- [ ] **Aprimorar Importação/Exportação:**
    - [ ] Implementar a importação de contatos a partir de arquivos **vCard**.
    - [ ] Adicionar a funcionalidade de exportação de contatos para **QR code** e **XML**.

### Backend
- [ ] **Refatorar Grupos de Contatos:** Avaliar a substituição das flags `is_system` e `is_private` pelo enum `group_type` (`general`, `ephemeral`), como planejado originalmente.
- [ ] **Expandir a API REST** para cobrir todas as funcionalidades do plugin, incluindo grupos, cargos e vínculos com tarefas.

### Testes
- [ ] **Ampliar Cobertura de Testes:**
    - [ ] Escrever testes unitários para os models.
    - [ ] Escrever testes de permissão para garantir que as regras de acesso sejam aplicadas corretamente.

## 🧭 Conceitos e Diretrizes

O desenvolvimento do Foton Contacts é guiado pelos seguintes princípios:

*   **Integração Nativa:** O plugin deve se integrar ao Redmine de forma transparente, utilizando os componentes, estilos e padrões de UX nativos sempre que possível.
*   **Flexibilidade:** O plugin deve ser flexível o suficiente para se adaptar a diferentes fluxos de trabalho, permitindo a personalização de campos, tipos de contato e permissões.
*   **Usabilidade:** A interface do plugin deve ser intuitiva e fácil de usar, mesmo para usuários com pouca experiência no Redmine.
*   **Desempenho:** O plugin deve ser otimizado para um bom desempenho, mesmo com um grande número de contatos e relacionamentos.
*   **Segurança:** O plugin deve seguir as melhores práticas de segurança, garantindo a privacidade e a integridade dos dados dos contatos.
