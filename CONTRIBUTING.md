# 🧩 Guia de Contribuição — Plugin de Contatos para Redmine

Este documento define as diretrizes para contribuir com o desenvolvimento do plugin de contatos para Redmine. O objetivo é garantir consistência, segurança, clareza e foco absoluto na experiência do usuário.

---

## 1. 📦 Estrutura do Projeto

O plugin segue a estrutura padrão de plugins Redmine:

```
redmine_contacts/
├── app/
├── config/
├── db/
├── lib/
├── assets/
├── locales/
├── test/
├── init.rb
├── README.md
└── CONTRIBUTING.md
```

---

## 2. 🧠 Versionamento Semântico

Utilizamos [SemVer 2.0.0](https://semver.org/lang/pt-BR/):

- `MAJOR`: mudanças incompatíveis (breaking changes)
- `MINOR`: novas funcionalidades compatíveis
- `PATCH`: correções de bugs

Durante a fase inicial (`0.x.y`), mudanças incompatíveis incrementam `MINOR`, e mudanças compatíveis incrementam `PATCH`.

---

## 3. 🌿 Nomenclatura de Branches

Adotamos Git Flow simplificado:

| Tipo       | Padrão                     | Origem     | Destino    |
|------------|----------------------------|------------|------------|
| Principal  | `main`                     | —          | Produção   |
| Dev        | `develop`                  | —          | Pré-release|
| Feature    | `feature/<nome>`           | `develop`  | `develop`  |
| Bugfix     | `fix/<nome>`               | `develop`  | `develop`  |
| Hotfix     | `hotfix/<nome>`            | `main`     | `main` + `develop` |
| Release    | `release/vX.Y.Z`           | `develop`  | `main` + `develop` |

Exemplo: `feature/vinculo-multiplo-contato-empresa`

---

## 4. 📝 Mensagens de Commit

Utilize o padrão [Conventional Commits](https://www.conventionalcommits.org/) com as mensagens preferencialmente em português:

```
<tipo>(<escopo>): <descrição>
```

| Tipo      | Uso                          |
|-----------|------------------------------|
| `feat`    | Nova funcionalidade          |
| `fix`     | Correção de bug              |
| `docs`    | Documentação                 |
| `style`   | Formatação (sem alteração lógica) |
| `refactor`| Refatoração sem mudança externa |
| `test`    | Testes                       |
| `chore`   | Tarefas auxiliares           |

Exemplo: `feat(contact): adiciona vínculo múltiplo com empresas`

---

## 5. 🔄 Fluxo de Contribuição

1. **Crie sua branch** a partir de `develop`
2. **Desenvolva com foco em UI/UX**, segurança e integração nativa
3. **Teste localmente** (unitários, integração, responsividade)
4. **Abra um Pull Request** para `develop`
5. **Use o template de PR** e descreva claramente:
   - O que foi feito
   - Como testar
   - Quais problemas resolve
6. **Aguarde revisão** e ajuste conforme necessário

---

## 6. 🧪 Testes Obrigatórios

Antes de enviar sua contribuição:

- Execute testes unitários e de integração
- Teste em telas grandes e dispositivos móveis
- Simule base de dados vazia e dados corrompidos
- Verifique permissões e escopos de visibilidade

---

## 7. 🎨 Padrões de UI/UX

Toda contribuição deve:

- Ser responsiva e acessível
- Usar componentes visuais nativos do Redmine
- Evitar duplicidade de funcionalidades
- Prever ausência de dados com mensagens amigáveis
- Priorizar clareza, fluidez e consistência visual

---

## 8. 🛡️ Segurança e Resiliência

- Valide todos os dados recebidos
- Proteja campos sensíveis
- Respeite permissões e escopos
- Evite quebra de interface em dados nulos ou inconsistentes

---

## 9. 📚 Documentação

Toda nova funcionalidade deve vir acompanhada de:

- Atualização no `README.md`
- Instruções claras de uso
- Exemplos de entrada/saída se aplicável

---

## 10. 🤝 Código de Conduta

Respeite os colaboradores. Seja claro, objetivo e cordial nas interações. O foco é construir um plugin útil, seguro e fácil de usar para todos.
