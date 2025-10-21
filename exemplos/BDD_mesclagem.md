# BDD - Behavior Driven Development para Interface de Mesclagem de Contatos

## Visão Geral
A interface de mesclagem de contatos do plugin tem como objetivo principal transformar um processo manual e cansativo em um processo de validação rápido, inteligente e profissional, respeitando o tempo do usuário e automatizando o óbvio.

## Pilares de Design

### 1. De Escolha Manual para Validação Inteligente
- O sistema faz o "trabalho pesado" para o usuário
- Analisa dados e pré-seleciona ativamente a informação mais recente como "Recomendada"
- O usuário passa a ser um tomador de decisões, não um digitador

### 2. Foco Absoluto no Essencial
- Interface esconde o que não é importante
- Campos idênticos são mostrados como "resolvidos"
- Atenção é direcionada exclusivamente para os conflitos

### 3. Clareza de um Painel de Controle (Dashboard)
- Design abandona aparência de formulário tradicional
- Adota clareza de painel de controle de negócios (BI)

### 4. Profissionalismo e Confiança
- Estética "business core": limpa, organizada e sem elementos caricatos
- Animações suaves e feedback visual claro
- Transmite sensação de confiança e controle profissional

## História de Usuário 1: Localizar Contatos Duplicados

### Como usuário do sistema Redmine
**Quero** poder buscar e identificar contatos duplicados  
**Para** poder gerenciar e consolidar informações de forma eficiente

### Cenários:

#### Cenário 1: Buscar duplicatas com sucesso
```
Dado que estou na página de busca de contatos duplicados
Quando eu digito um termo de busca (nome, email ou empresa)
E clico em "Buscar"
Então devo ver uma lista de contatos duplicados encontrados
```

#### Cenário 2: Nenhuma duplicata encontrada
```
Dado que estou na página de busca de contatos duplicados
Quando eu digito um termo de busca que não tem duplicatas
E clico em "Buscar"
Então devo ver uma mensagem informando que não há duplicatas encontradas
```

---

## História de Usuário 2: Revisar Contatos Duplicados

### Como usuário do sistema Redmine
**Quero** poder revisar visualmente os campos conflitantes entre dois contatos duplicados  
**Para** tomar decisões informadas sobre quais informações manter

### Cenários:

#### Cenário 1: Visualizar campos em conflito
```
Dado que estou na página de revisão de contatos duplicados
Quando abro a comparação entre dois contatos
Então devo ver dois painéis: Existente e Novo 
E os campos idênticos devem estar marcados como resolvidos
E os campos diferentes devem estar destacados para decisão
```

#### Cenário 2: Selecionar campo recomendado
```
Dado que estou na página de revisão de contatos duplicados
Quando vejo um campo com recomendação do sistema
E o campo recomendado está visualmente destacado
Então posso confirmar a recomendação ou escolher outro valor
```

#### Cenário 3: Selecionar campo manualmente
```
Dado que estou na página de revisão de contatos duplicados
Quando clico em um campo de um dos contatos
Então esse campo é selecionado como o valor definitivo para o campo resultante
E o botão de seleção muda de aparência para indicar a seleção
```

#### Cenário 4: Validar campos resolvidos
```
Dado que estou na página de revisão de contatos duplicados
Quando todos os campos em conflito têm uma seleção
Então o botão de confirmação de mesclagem fica habilitado
```

---

## História de Usuário 3: Confirmar Mesclagem de Contatos

### Como usuário do sistema Redmine
**Quero** poder confirmar a mesclagem após revisar todos os campos  
**Para** consolidar definitivamente os contatos duplicados

### Cenários:

#### Cenário 1: Acessar confirmação de mesclagem
```
Dado que estou na página de revisão de contatos duplicados
Quando todos os campos conflitantes estão resolvidos
E clico no botão "Confirmar Mesclagem"
Então devo ser direcionado para a página de confirmação
```

#### Cenário 2: Ver prévia do contato resultante
```
Dado que estou na página de confirmação de mesclagem
Quando vejo o resumo do contato resultante
Então devo poder verificar todos os campos que serão mantidos
E devo poder ver de onde veio cada informação (existente ou novo)
```

#### Cenário 3: Retornar para revisão
```
Dado que estou na página de confirmação de mesclagem
Quando percebo que uma informação está incorreta
E clico em "Voltar para Revisão"
Então devo retornar à página de revisão para corrigir os campos
```

#### Cenário 4: Confirmar definitivamente
```
Dado que estou na página de confirmação de mesclagem
Quando verifico que todas as informações estão corretas
E clico em "Confirmar Mesclagem"
Então a mesclagem é executada e vejo uma mensagem de sucesso
```

---

## História de Usuário 4: Visualizar Resultado Final

### Como usuário do sistema Redmine
**Quero** poder ver o contato resultante da mesclagem  
**Para** confirmar que as informações foram consolidadas corretamente

### Cenários:

#### Cenário 1: Visualizar contato mesclado
```
Dado que a mesclagem foi concluída com sucesso
Quando vejo a página de confirmação final
Então devo ver o contato resultante com todos os campos selecionados
E devo ver de onde veio cada informação
```

#### Cenário 2: Navegar após mesclagem
```
Dado que a mesclagem foi concluída com sucesso
Quando quero ver outras duplicatas
E clico em "Ver Duplicatas"
Então devo ser direcionado para a página de busca de duplicatas
```

#### Cenário 3: Revisar novamente
```
Dado que a mesclagem foi concluída com sucesso
Quando quero rever a mesclagem
E clico em "Revisar Novamente"
Então devo retornar à página de revisão do mesmo par de contatos
```

---

## Critérios Técnicos

### Requisitos de Interface:
- Layout responsivo mobile-first
- Design profissional "business core"
- Feedback visual claro para seleções
- Animações suaves para transições
- Destaque visual para campos recomendados

### Requisitos de Funcionalidade:
- Sistema deve detectar automaticamente campos idênticos
- Recomendação baseada na data de atualização mais recente
- Validação de campos obrigatórios
- Persistência de seleções durante o processo

### Requisitos de Experiência:
- Foco absoluto no essencial (campos conflitantes)
- Papel de tomador de decisão, não de digitador
- Processo de validação inteligente e rápido
- Clareza visual do painel de controle

### Requisitos de Acessibilidade:
- Navegação por teclado
- Contraste adequado de cores
- Textos legíveis
- Elementos interativos com tamanho adequado para toque

### Requisitos de Performance:
- Resposta imediata às interações
- Carregamento rápido das informações
- Animações suaves sem travamentos
- Interface responsiva em dispositivos móveis
