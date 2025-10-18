# Guia de Business Intelligence (BI) para o Foton Contacts

## 1. Introdução

Este documento serve como um guia técnico e conceitual para a implementação de análises de Business Intelligence (BI) e dashboards no plugin **Foton Contacts**. O objetivo é fornecer aos desenvolvedores uma base sólida, detalhando as métricas, a lógica de negócio e a arquitetura de dados necessária para transformar os dados brutos do plugin em insights acionáveis.

O guia está dividido em três seções:
- **Análises Estratégicas e Preditivas:** Análises avançadas focadas em risco, performance de equipes, carga de trabalho e eficiência. Devem ser o foco para agregar valor estratégico ao plugin.
- **Análises Operacionais e de Ecossistema:** Detalhamento das análises que formam a base dos dashboards e relatórios do dia a dia.
- **Configurações e Alertas:** Definição das configurações necessárias para análises de recursos e dos sistemas de alerta proativos.

## 2. Análises Estratégicas e Preditivas

---
### Índice de Risco Preditivo de Alocação (IRPA)

**🎯 Objetivo:** Identificar proativamente quais contatos (pessoas) ou empresas representam o maior risco para o cronograma de um projeto. A análise responde à pergunta: "Baseado no histórico de performance, qual a probabilidade de o 'Fornecedor X' ou o 'Engenheiro Y' causar atrasos ou retrabalho nas tarefas futuras para as quais estão alocados?"

**🤔 Lógica e Raciocínio:** A simples contagem de tarefas por pessoa não revela o risco. Um contato pode ter poucas tarefas, mas se forem sempre as mais críticas e ele tiver um histórico de atrasos, o risco é imenso. Esta análise cruza o histórico de performance de um contato (atrasos, bugs gerados) com a criticidade das tarefas atuais e futuras, gerando um score de risco que permite ao gestor re-alocar recursos ou reforçar o acompanhamento antes que o problema ocorra.

**⚙️ Método de Cálculo e Métricas:**
- **Métrica 1: Taxa de Atraso Histórica (TAH)**: `(COUNT(Issues onde issue.closed_on > issue.due_date E status = 'Fechado') / COUNT(Total de Issues fechadas do contato)) * 100`
- **Métrica 2: Índice de Retrabalho (IR)**: `(COUNT(Issues com tracker 'Bug' ou 'Correção' vinculadas ao contato) / COUNT(Total de Issues do contato)) * 100`
- **Métrica 3: Fator de Criticidade Ponderado (FCP)**: `AVG(priority.position)` para todas as tarefas *abertas* do contato, onde `priority.position` é o valor numérico da prioridade no Redmine (quanto maior, mais crítico).
- **Métrica 4: Score de Risco (IRPA)**: `(TAH * 0.5) + (IR * 0.3) + (FCP * 0.2)`. Os pesos são ajustáveis.

**🏗️ Arquitetura da Análise (ETL):**
- **Entrada (Input):**
  - **Modelos/Tabelas:** `[Contact, ContactIssueLink, Issue, IssueStatus, Enumeration (para prioridades), Tracker]`
  - **Campos Relevantes:** `[contact.id, contact.name, issue.id, issue.due_date, issue.closed_on, issue.status_id, issue.priority_id, issue.tracker_id]`
  - **Parâmetros:** `[project_id (opcional), date_range (obrigatório para histórico)]`
- **Transformação (Transformation):**
  - 1. Juntar `contacts` com `contact_issue_links` e `issues`.
  - 2. Para cada `contact`, calcular a TAH e o IR sobre as `issues` fechadas no `date_range`.
  - 3. Para cada `contact`, calcular o FCP sobre as `issues` *abertas*.
  - 4. Calcular o score final IRPA para cada contato.
- **Entrega (Output):**
  - **Formato do Dado:** `JSON: [{ contact_id, contact_name, risk_score, tah_percent, ir_percent, fcp_avg }]`
  - **Visualização Sugerida:** "Tabela Ordenável por `risk_score`". Usar codificação de cores (vermelho para scores altos, verde para baixos) para destacar os contatos mais arriscados do projeto.

---
### Painel de Performance da Equipa (Team Scorecard)

**🎯 Objetivo:** Avaliar e comparar a performance de diferentes equipes (grupos) com base em métricas agregadas de qualidade, velocidade e risco. Responde a: "A 'Equipa de Elétrica A' é mais eficiente que a 'Equipa de Elétrica B'?"

**🤔 Lógica e Raciocínio:** Assim como avaliamos o risco de um indivíduo (IRPA), podemos agregar esses dados para avaliar a performance coletiva. Uma equipa pode ter um membro de alto risco que é compensado pela alta performance dos outros, ou o risco pode ser sistémico. Esta análise dá aos gestores uma visão macro para alocar projetos a equipes inteiras.

**⚙️ Método de Cálculo e Métricas:**
- **Métrica 1: Score de Risco Médio da Equipa (IRPA Médio)**: `AVG(IRPA)` de todos os membros do grupo.
- **Métrica 2: Taxa de Atraso Agregada (TAA)**: `(Total de Issues Atrasadas da Equipa / Total de Issues Fechadas da Equipa) * 100`.
- **Métrica 3: Índice de Coesão da Equipa (ICE)**: `AVG(duração da associação de cada membro ao grupo)`. Uma equipa com membros que trabalham juntos há mais tempo tende a ser mais coesa e eficiente.
- **Métrica 4: Score Geral da Equipa**: Uma fórmula ponderada, ex: `(1 - IRPA Médio/100) * 0.4 + (1 - TAA/100) * 0.4 + (ICE em meses / 12) * 0.2`.

**🏗️ Arquitetura da Análise (ETL):**
- **Entrada (Input):**
  - **Modelos/Tabelas:** `[ContactGroup, ContactGroupMembership, Contact, ContactIssueLink, Issue]`
  - **Campos Relevantes:** Todos os campos usados para o IRPA, mais `contact_group_memberships.created_at`.
- **Transformação (Transformation):**
  - 1. Para cada `ContactGroup`, obter a lista de `contact_id` dos seus membros.
  - 2. Calcular o IRPA individual para cada membro (conforme análise anterior).
  - 3. Calcular a média do IRPA para o grupo.
  - 4. Obter todas as `issues` vinculadas ao grupo ou aos seus membros para calcular a TAA.
  - 5. Calcular a data de entrada de cada membro no grupo para obter o ICE.
  - 6. Aplicar a fórmula do Score Geral.
- **Entrega (Output):**
  - **Formato do Dado:** `JSON: [{ group_id, group_name, avg_risk_score, aggregated_delay_rate, cohesion_index_months, overall_score }]`
  - **Visualização Sugerida:** "Gráfico de Radar". Cada eixo é uma métrica (Qualidade, Velocidade, Risco, Coesão), e cada equipa é uma linha colorida. Permite uma comparação visual e multidimensional muito rápida entre as equipes.

---
### Mapa de Calor da Carga de Trabalho (Workload Heatmap)

**🎯 Objetivo:** Visualizar a carga de trabalho alocada para cada contato ao longo do tempo, identificando dias de sobrecarga (>100%) ou subutilização. Responde a: "Quem está sobrecarregado na próxima semana?"

**🤔 Lógica e Raciocínio:** O Redmine usa `start_date`, `due_date` e `estimated_hours`. A lógica é distribuir as horas estimadas de uma tarefa de forma uniforme pelos dias úteis da sua duração. Somando as horas diárias de todas as tarefas de um contato, podemos comparar com a sua disponibilidade diária (configurável).

**⚙️ Método de Cálculo e Métricas:**
- **Métrica 1: Horas Alocadas por Dia (HAD)**: Para um `Contato` e um `Dia`: `SUM(issue.estimated_hours / (dias úteis entre issue.start_date e issue.due_date))` para todas as tarefas ativas nesse dia.
- **Métrica 2: Percentagem de Alocação Diária (PAD)**: `(HAD / Horas Disponíveis por Dia do Contato) * 100`.

**🏗️ Arquitetura da Análise (ETL):**
- **Entrada (Input):**
  - **Modelos/Tabelas:** `[Contact, ContactIssueLink, Issue]` e as configurações de carga horária.
  - **Campos Relevantes:** `[issue.start_date, issue.due_date, issue.estimated_hours, contact_issue_links.contact_id]`.
- **Transformação (Transformation):**
  - 1. Obter todas as `issues` abertas para um determinado projeto ou período.
  - 2. Para cada `issue`, calcular os dias úteis da sua duração e as `horas/dia`.
  - 3. Criar uma matriz de dados onde as linhas são os `contacts` e as colunas são os dias do período analisado.
  - 4. Iterar sobre cada tarefa e adicionar as suas `horas/dia` às células correspondentes (`[contato, dia]`) na matriz.
  - 5. Converter os valores de horas para a percentagem de alocação (PAD).
- **Entrega (Output):**
  - **Formato do Dado:** `JSON: { contact_name, daily_load: [{ date, allocated_hours, load_percent }] }`
  - **Visualização Sugerida:** "Heatmap (Mapa de Calor)". Linhas são os contatos, colunas são os dias da semana/mês, com cores indicando a carga (Verde <80%, Amarelo 80-100%, Vermelho >100%).

## 3. Análises Operacionais e de Ecossistema

---
### Análise de Performance Operacional

**🎯 Objetivo:** Fornecer uma visão geral da distribuição de trabalho e da eficiência da entrega. Responde às perguntas: "Quem está fazendo o quê?", "Quais funções levam mais tempo?" e "Em quais projetos uma determinada função é mais demandada?".

**🤔 Lógica e Raciocínio:** É a análise mais fundamental para entender a carga de trabalho e identificar gargalos básicos. Agrega dados de tarefas, tempo e funções para criar um panorama da operação.

**⚙️ Método de Cálculo e Métricas:**
- **Métrica 1: Volume de Tarefas por Contato/Empresa**: `COUNT(DISTINCT issue.id)` agrupado por `contact.id`.
- **Métrica 2: Lead Time Médio por Função (Role)**: `AVG(issue.closed_on - issue.start_date)` agrupado por `contact_issue_links.role`.
- **Métrica 3: Distribuição de Funções por Projeto**: `COUNT(contact_issue_links.id)` agrupado por `project.id` e `contact_issue_links.role`.

**🏗️ Arquitetura da Análise (ETL):**
- **Entrada (Input):**
  - **Modelos/Tabelas:** `[Contact, ContactIssueLink, Issue, Project]`
  - **Campos Relevantes:** `[contact.id, contact.name, issue.id, issue.start_date, issue.closed_on, project.id, project.name, contact_issue_links.role]`
  - **Parâmetros:** `[project_id (opcional), date_range (opcional)]`
- **Entrega (Output):**
  - **Formato do Dado:** `JSON: [{ dimension, metric_value }]`
  - **Visualização Sugerida:** "Gráficos de Barras" para volume e lead time. "Heatmap" para a distribuição de funções vs. projetos.

---
### Análise de Volatilidade e Ecossistema de Parceiros

**🎯 Objetivo:** Medir a estabilidade das equipes de empresas parceiras, mapear a rede de relacionamentos e identificar dependências críticas. Responde a: "A equipa do meu fornecedor é estável?" e "Quem trabalha para quem?".

**🤔 Lógica e Raciocínio:** Na indústria AEC, a continuidade da equipe de um fornecedor é crucial. Esta análise deteta a "volatilidade" da equipa alocada e mapeia as conexões profissionais.

**⚙️ Método de Cálculo e Métricas:**
- **Métrica 1: Taxa de Rotatividade no Projeto (TRP)**: Para uma `Empresa` durante um `Projeto`: `(COUNT(contact_employments.end_date) dentro do período do projeto) / (COUNT(total de funcionários distintos da empresa vinculados a issues do projeto))`
- **Métrica 2: Idade Média da Equipe no Projeto (IMEP)**: Média de `(data_atual - contact_employments.start_date)` para todos os funcionários *ativos* no projeto.
- **Métrica 3: Grafo de Relacionamentos**: Representação visual das conexões `Pessoa -> Empresa`.

**🏗️ Arquitetura da Análise (ETL):**
- **Entrada (Input):**
  - **Modelos/Tabelas:** `[Contact (tipo Empresa e Pessoa), ContactEmployment, ContactIssueLink, Issue, Project]`
  - **Parâmetros:** `[project_id (obrigatório)]`
- **Entrega (Output):**
  - **Formato do Dado:** `JSON: [{ company_id, company_name, turnover_rate, avg_team_age_days }]` e `JSON: { nodes: [...], edges: [...] }`.
  - **Visualização Sugerida:** "Gráfico de Bolhas (Bubble Chart)" para `IMEP` vs `TRP`. "Grafo de Rede Interativo" para os relacionamentos.

---
### Análise de Saturação e Dependência de "Funções-Chave"

**🎯 Objetivo:** Identificar a dependência do projeto em `roles` (funções) específicas e a saturação dos contatos que as executam. Responde: "Estou dependendo de uma única pessoa para uma função crítica?".

**🤔 Lógica e Raciocínio:** Mede a **distribuição de trabalho dentro de um mesmo `role`**, revelando gargalos ocultos e pontos únicos de falha (SPOF - Single Point of Failure).

**⚙️ Método de Cálculo e Métricas:**
- **Métrica 1: Índice de Concentração de Função (ICF)**: `(COUNT(tarefas do contato com mais tarefas no role) / COUNT(total de tarefas do role)) * 100`.
- **Métrica 2: Fator de Risco de SPOF**: `ICF * Fator de Criticidade Médio das Tarefas do Role`.

**🏗️ Arquitetura da Análise (ETL):**
- **Entrada (Input):** `[ContactIssueLink, Issue, Enumeration (para prioridades)]`
- **Parâmetros:** `[project_id (obrigatório)]`
- **Entrega (Output):**
  - **Formato do Dado:** `JSON: [{ role_name, concentration_index, spof_risk_factor }]`
  - **Visualização Sugerida:** "Gráfico de Barras Composto" para `ICF` e `spof_risk_factor`.

---
### Monitor de Qualidade e Saúde dos Dados

**🎯 Objetivo:** Garantir a integridade e a padronização dos dados de contatos. Responde: "Os nossos dados de contatos estão completos, atualizados e padronizados?".

**🤔 Lógica e Raciocínio:** Dados de baixa qualidade geram análises incorretas. Este monitor deve encontrar e sinalizar proativamente inconsistências.

**⚙️ Método de Cálculo e Métricas:**
- **Métrica 1: Contatos Órfãos**: `COUNT(contacts)` sem `contact_issue_link` ou `contact_employment`.
- **Métrica 2: Frequência de Uso de `role`**: `COUNT(id)` agrupado por `LOWER(contact_issue_links.role)`.
- **Métrica 3: Contatos Desatualizados**: `COUNT(contacts)` com `updated_on` mais antigo que um `date_range`.

**🏗️ Arquitetura da Análise (ETL):**
- **Entrada (Input):** `[Contact, ContactIssueLink, ContactEmployment]`
- **Entrega (Output):**
  - **Formato do Dado:** `JSON: [{ check_name: 'Orphan Contacts', count: 42, details: [...] }]`
  - **Visualização Sugerida:** "Tabelas de Diagnóstico" com links para edição.

## 4. Configurações e Alertas Proativos

---
### Configuração de Carga Horária

**🎯 Objetivo:** Permitir o cálculo preciso da alocação de recursos.

**🤔 Lógica e Raciocínio:** Para analisar a carga de trabalho, o sistema precisa saber a disponibilidade de cada recurso.

**⚙️ Implementação:**
- **Nível Global:** No painel de administração do plugin, adicionar um campo: **"Carga Horária Padrão Diária"** (ex: 8 horas).
- **Nível de Contato:** No formulário de edição do `Contact`, adicionar um campo: **"Horas Disponíveis por Dia"**. Se este campo estiver vazio, o sistema utiliza o valor global.

---
### Alerta de Sobreposição de Tarefas (Em Tempo Real)

**🎯 Objetivo:** Alertar o gestor no momento em que uma atribuição de tarefa irá sobrecarregar um colaborador.

**🤔 Lógica e Raciocínio:** Prevenir a sobrecarga antes que ela ocorra é mais eficaz do que corrigi-la depois.

**⚙️ Implementação:**
- **Endpoint de Verificação:** Criar uma rota/ação (`/contacts/check_workload`) que recebe `contact_id` e os dados da `issue` (`start_date`, `due_date`, `estimated_hours`).
- **Lógica do Endpoint:** A ação calcula a carga horária projetada para o contato no período especificado. Se a nova tarefa causar uma sobrecarga em qualquer dia, retorna um aviso.
- **Integração com a UI (Stimulus/Hotwire):**
  - Antes de salvar a associação de um contato a uma tarefa, um controlador JavaScript faz uma chamada `fetch` a este endpoint.
  - Se receber um aviso, exibe um modal de confirmação ao utilizador (ex: "Atenção: Esta tarefa sobrecarregará o contato. Deseja continuar?").
  - O gestor pode então tomar uma decisão informada: confirmar a atribuição ou cancelar para reavaliar.
