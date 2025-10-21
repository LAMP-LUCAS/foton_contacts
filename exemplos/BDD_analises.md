# Cenários em BDD (Behavior-Driven Development)

Abaixo estão os cenários BDD que descrevem a jornada do utilizador pelas novas funcionalidades de análise, incorporando as suas ideias de um dashboard geral e de um dashboard dinâmico na página inicial.

---

## **Funcionalidade:** Análise de Business Intelligence para Gestão de Contatos e Equipes

**Como um** Gestor de Projetos ou Diretor,
**Eu quero** ter acesso a dashboards e análises visuais sobre a minha rede de contatos, equipes e a sua carga de trabalho,
**Para que eu possa** tomar decisões mais informadas, mitigar riscos proativamente e otimizar a alocação de recursos nos meus projetos.

---

### **Cenário 1: Visão Geral do Desempenho no Dashboard Principal**

O gestor precisa de um ponto de partida para "sentir o pulso" da operação, identificando rapidamente os pontos de atenção em toda a sua rede de contatos.

> **Dado que** eu estou autenticado no Redmine e na página principal do plugin Foton Contacts
> **E** existem múltiplos projetos, contatos e tarefas com histórico de performance registado no Redmine
> **Quando** eu clico na aba **"Lista de Contatos"**
> **Então** eu visualizo o titulo da página com os botões de ação Novo Contato, Importar Contatos, Exportar Contatos
> **E** eu vejo abaixo cards relatando a saúde da lista de contatos em formato de monitor de qualidade, demonstrando a quantidade de Contatos Órfãos (sem empresas vinculadas), Funções a padronizar (com a string semelhante porém com erros de digitação ou formatação) e Contatos Desatualizados (que tem a ultima atualização a mais de 1 ano)
> **E** logo abaixo tem uma barra de filtragem sobre uma tabela paginada com todos os contatos cadastrados organizados em colunas com: nome, tipo, telefone, email, data de criação, status, e botão de ações(análise,editar e excluir)
> **E** eu vejo abas com Lista de Contatos, dashboard de bi e grupos, na aba Lista de Contatos existe uma lista de contatos em formato de tabela, abaixo do menu de ações e do menu de filtragem e acima de um dashboard interativo referente aos dados da tabela de contatos
> **Quando** eu clico na aba **"Dashboard de BI"**
> **Então** eu devo ser direcionado para a sub-aba **"Visão Geral"**
> **E** devo ver um widget de **"Índice de Risco Preditivo (IRPA)"** mostrando uma tabela com os contatos de maior risco no topo
> **E** devo ver um widget de **"Monitor de Qualidade dos Dados"** indicando o número de contatos que necessitam de atenção
> **E** devo ver um widget de **"Análise de Empresas Parceiras"** com um gráfico de bolhas que relaciona a estabilidade das equipes (turnover) com a sua experiência.

---

### **Cenário 2: Investigação Detalhada de um Contato de Alto Risco (Drill-Down)**

Após identificar um risco no dashboard geral, o gestor precisa de aprofundar a análise para entender a causa e tomar uma ação.

> **Dado que** eu estou a visualizar o **"Dashboard de BI"**
> **E** o contato "Marcos Rocha" aparece no topo da lista de risco com um score de 92.0
> **Quando** eu clico no nome de "Marcos Rocha" na tabela de risco
> **Então** o **modal de análise individual** para "Marcos Rocha" deve ser exibido
> **E** o modal deve mostrar o seu score IRPA de 92.0 em destaque e a vermelho
> **E** devo ver os seus KPIs de performance, como "Taxa de Atraso" e "Índice de Retrabalho"
> **E** devo ver o seu histórico de vínculos profissionais para entender o seu contexto.

---

### **Cenário 3: Análise Dinâmica e Contextual na Lista de Contatos**

O gestor quer insights rápidos e filtrados sobre um subconjunto específico de contatos sem ter de navegar para um dashboard separado.

> **Dado que** eu estou na página principal do plugin, na aba **"Lista de Contatos"**
> **E** um painel de **"Dashboard Dinâmico"** é exibido abaixo da tabela de contatos
> **E** a tabela exibe uma lista paginada pelo redmine de contatos de diversas empresas e tipos
> **Quando** eu uso o filtro para procurar pela empresa **"Estruturas Metálicas XYZ"** ou por um contato específico **"Marcos Rocha"**
> **Então** a tabela de contatos deve ser atualizada para mostrar apenas os contatos dessa empresa
> **E** o painel de **"Dashboard Dinâmico"** deve ser recalculado automaticamente para refletir apenas esta seleção
> **E** o dashboard dinâmico deve exibir o "Score de Risco Médio" deste grupo de contatos
> **E** deve destacar que "Marcos Rocha" é o contato com o IRPA mais elevado dentro desta seleção.

---

### **Cenário 4: Análise Comparativa de Equipes para Alocação de Projeto**

O gestor está a planear um novo projeto e precisa de escolher a equipa (Grupo) mais qualificada e com menor risco para a tarefa.

> **Dado que** eu estou a visualizar o **"Dashboard de BI"**
> **Quando** eu clico na sub-aba **"Análise de Equipes"**
> **Então** eu devo ver um **Gráfico de Radar** a comparar a performance da "Equipa Alfa", "Equipa Beta" e "Equipa Gama"
> **E** o gráfico deve mostrar visualmente que a "Equipa Beta" tem o maior risco médio e a menor coesão
> **E** devo ver uma tabela de **"Ranking de Equipes"** ao lado, que classifica a "Equipa Alfa" em primeiro lugar com base no seu "Score Geral".

---

### **Cenário 5: Gestão Proativa da Carga de Trabalho e Prevenção de Sobrecarga**

O gestor precisa de garantir que os recursos estão bem distribuídos e evitar o esgotamento da equipa, que leva a atrasos e perda de qualidade.

> **Dado que** eu estou a visualizar o **"Dashboard de BI"**
> **Quando** eu clico na sub-aba **"Carga de Trabalho"**
> **Entãp** eu vejo uma lista com caixas de seleção de colaboradores ordenada pelo percentual de alocação abaixo de um menu de filtragem por nome, alocação e range de data.
> **Quando** eu filtro ou seleciono um ou alguns colaboradores
> **Então** eu devo ver um **Mapa de Calor** com os nomes dos colaboradores nas linhas e os dias em um calendário com formatação semanal, mensal ou anual
> **E** a célula do mapa correspondente a "Marcos Rocha" na terça-feira deve estar a vermelho, mostrando uma alocação de **"130%"**.
> **E dado que** eu estou numa tarefa do Redmine e tento atribuí-la a "Marcos Rocha"
> **Quando** eu adiciono o nome dele e a tarefa tem uma duração que inclui aquela terça-feira
> **Então** o sistema deve exibir um alerta em tempo real com a mensagem: **"Atenção: Esta atribuição irá sobrecarregar o contato. Deseja continuar?"**
