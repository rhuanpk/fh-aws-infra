![Logo](https://avatars.githubusercontent.com/u/79948663?s=200&v=4)

# Tech Challenge - FIAP TECH 2024

Este repositório contém o código fonte da infraestrutura em Terraform dos recursos AWS para o projeto do Tech Challenge referente a pós-graduação da FIAP TECH no ano de 2024:

## Stack utilizada

**Infra:** Terraform e AWS Cloud (RDS).

## Rodando localmente

Clone o projeto:

```bash
  git clone https://link-para-o-projeto
```

Entre no diretório do projeto:

```bash
  cd fh-aws-infra
```

Instale as dependências e módulos do diretório com o Terraform:

```bash
  terraform init
```

Execute o comando de `plan` para criar um preview das alterações:

```bash
  terraform plan
```

Execute o comando de `apply` para aplicar as alterações e subir a aplicação:

```bash
  terraform apply
```

## Documentação

### Arquivos na raiz

-  **main.tf**: Arquivo principal do Terraform responsável pela criação dos recursos de infraestrutura AWS.
-  **variables.tf**: Arquivo com variavéis utilizadas do código principal.
-  **outputs.tf**: Arquivo com "saídas" dos componentes criados.
-  **readme.md**: Arquivo com a documentação do projeto.

## Autores

-  [@Bruno Campos](https://github.com/brunocamposousa)
-  [@Bruno Oliveira](https://github.com/bgoulart)
-  [@Diógenes Viana](https://github.com/diogenesviana)
-  [@Filipe Borba](https://www.github.com/filipexxborba)
-  [@Rhuan Patriky](https://github.com/rhuanpk)